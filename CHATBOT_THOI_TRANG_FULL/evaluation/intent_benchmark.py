import argparse
import csv
import time
from collections import defaultdict
from pathlib import Path

from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.metrics import accuracy_score, f1_score, precision_score, recall_score
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.pipeline import make_pipeline
from sklearn.svm import LinearSVC

from chatbot.nlp import normalize_text


DATA_PATH = Path(__file__).with_name("intent_dataset.csv")
UNKNOWN = "unknown"
REJECTION_THRESHOLD = 0.35
ALGORITHMS = ("word_cosine", "char_cosine", "hybrid_cosine", "multinomial_nb", "linear_svc")


def load_dataset(path):
    with path.open(encoding="utf-8-sig", newline="") as dataset_file:
        rows = list(csv.DictReader(dataset_file))
    required = {"partition", "dataset", "intent", "text"}
    if not rows or not required.issubset(rows[0]):
        raise ValueError(f"Dataset must contain these columns: {', '.join(sorted(required))}")
    allowed_partitions = {"train", "validation", "test"}
    for row in rows:
        if row.get("partition") not in allowed_partitions:
            raise ValueError(f"Invalid or missing partition: {row.get('partition')!r}")
        if not (row.get("intent") or "").strip() or not (row.get("text") or "").strip():
            raise ValueError("Every dataset row must have a non-empty intent and text")
        if row["partition"] == "test" and not (row.get("dataset") or "").strip():
            raise ValueError("Every test row must name its test dataset")
    partitions = {row["partition"] for row in rows}
    if partitions != allowed_partitions:
        raise ValueError("Dataset must contain train, validation, and test partitions")
    return rows


def build_predictor(algorithm, train_texts, train_labels):
    questions = [normalize_text(text) for text in train_texts]
    if algorithm == "multinomial_nb":
        model = make_pipeline(
            TfidfVectorizer(ngram_range=(1, 2)),
            MultinomialNB(alpha=0.3),
        )
        model.fit(questions, train_labels)
        classes = model.named_steps["multinomialnb"].classes_

        def predict(text):
            probabilities = model.predict_proba([normalize_text(text)])[0]
            index = probabilities.argmax()
            return classes[index], float(probabilities[index])

        return predict

    if algorithm == "linear_svc":
        model = make_pipeline(
            TfidfVectorizer(ngram_range=(1, 2)),
            LinearSVC(C=1.0, random_state=42),
        )
        model.fit(questions, train_labels)
        classes = model.named_steps["linearsvc"].classes_

        def predict(text):
            decisions = model.decision_function([normalize_text(text)])[0]
            index = decisions.argmax()
            return classes[index], float(decisions[index])

        return predict

    word_vectorizer = TfidfVectorizer(ngram_range=(1, 2))
    word_vectors = word_vectorizer.fit_transform(questions)
    char_vectorizer = TfidfVectorizer(analyzer="char_wb", ngram_range=(2, 5))
    char_vectors = char_vectorizer.fit_transform(questions)

    def predict(text):
        normalized = normalize_text(text)
        if algorithm == "char_cosine":
            query = char_vectorizer.transform([normalized])
            scores = cosine_similarity(query, char_vectors)[0]
        else:
            query = word_vectorizer.transform([normalized])
            scores = cosine_similarity(query, word_vectors)[0]
            if algorithm == "hybrid_cosine":
                char_query = char_vectorizer.transform([normalized])
                char_scores = cosine_similarity(char_query, char_vectors)[0]
                scores = 0.6 * scores + 0.4 * char_scores
        index = scores.argmax()
        return train_labels[index], float(scores[index])

    return predict


def calibrate_threshold(predict, validation_rows, labels):
    if not validation_rows:
        return REJECTION_THRESHOLD
    expected = [row["intent"] for row in validation_rows]
    raw_predictions = [predict(row["text"]) for row in validation_rows]
    confidences = [confidence for _, confidence in raw_predictions]
    candidates = sorted({0.0, *confidences, max(confidences) + 1e-9})
    best_threshold = candidates[0]
    best_score = -1.0
    for threshold in candidates:
        predictions = [
            label if confidence >= threshold else UNKNOWN
            for label, confidence in raw_predictions
        ]
        score = f1_score(expected, predictions, labels=labels, average="macro", zero_division=0)
        if score > best_score:
            best_score = score
            best_threshold = threshold
    return best_threshold


def evaluate(rows):
    train_rows = [row for row in rows if row["partition"] == "train"]
    if not train_rows:
        raise ValueError("Dataset has no training rows")
    train_texts = [row["text"] for row in train_rows]
    train_labels = [row["intent"] for row in train_rows]
    labels = sorted(set(train_labels) | {UNKNOWN})
    validation_rows = [row for row in rows if row["partition"] == "validation"]
    datasets = defaultdict(list)
    for row in rows:
        if row["partition"] == "test":
            datasets[row["dataset"]].append(row)

    results = []
    for dataset_name, test_rows in sorted(datasets.items()):
        expected = [row["intent"] for row in test_rows]
        test_texts = [row["text"] for row in test_rows]
        for algorithm in ALGORITHMS:
            predict = build_predictor(algorithm, train_texts, train_labels)
            threshold = calibrate_threshold(predict, validation_rows, labels)
            predictions = []
            elapsed = []
            for text in test_texts:
                start = time.perf_counter()
                label, confidence = predict(text)
                elapsed.append((time.perf_counter() - start) * 1000)
                predictions.append(label if confidence >= threshold else UNKNOWN)
            results.append({
                "dataset": dataset_name,
                "algorithm": algorithm,
                "samples": len(test_rows),
                "accuracy": accuracy_score(expected, predictions),
                "macro_f1": f1_score(expected, predictions, labels=labels, average="macro", zero_division=0),
                "unknown_precision": precision_score(
                    expected, predictions, labels=[UNKNOWN], average=None, zero_division=0
                )[0],
                "unknown_recall": recall_score(
                    expected, predictions, labels=[UNKNOWN], average=None, zero_division=0
                )[0],
                "rejection_threshold": threshold,
                "avg_latency_ms": sum(elapsed) / len(elapsed),
            })
    if not results:
        raise ValueError("Dataset has no test rows")
    return results


def main():
    parser = argparse.ArgumentParser(description="Compare offline chatbot intent-matching algorithms.")
    parser.add_argument(
        "--data", type=Path, action="append",
        help="CSV file with train, validation, and test examples; may be repeated",
    )
    parser.add_argument("--output", type=Path, help="Optional path for machine-readable result CSV")
    args = parser.parse_args()

    data_paths = args.data or [DATA_PATH]
    results = []
    for data_path in data_paths:
        results.extend({"source": data_path.stem, **result} for result in evaluate(load_dataset(data_path)))
    columns = (
        "source", "dataset", "algorithm", "samples", "accuracy", "macro_f1",
        "unknown_precision", "unknown_recall", "rejection_threshold", "avg_latency_ms",
    )
    print(" | ".join(f"{column:>18}" for column in columns))
    for result in results:
        values = [
            result["source"], result["dataset"], result["algorithm"], str(result["samples"]),
            f"{result['accuracy']:.3f}", f"{result['macro_f1']:.3f}",
            f"{result['unknown_precision']:.3f}", f"{result['unknown_recall']:.3f}",
            f"{result['rejection_threshold']:.3f}",
            f"{result['avg_latency_ms']:.3f}",
        ]
        print(" | ".join(f"{value:>18}" for value in values))

    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        with args.output.open("w", encoding="utf-8", newline="") as output_file:
            writer = csv.DictWriter(output_file, fieldnames=columns)
            writer.writeheader()
            writer.writerows(results)
        print(f"\nSaved results to {args.output}")


if __name__ == "__main__":
    main()