import unittest
from pathlib import Path

from evaluation.intent_benchmark import ALGORITHMS, evaluate, load_dataset


DATASETS = (
    Path(__file__).with_name("intent_dataset.csv"),
    Path(__file__).with_name("faq_dataset.csv"),
)


class IntentBenchmarkTests(unittest.TestCase):
    def test_datasets_have_train_validation_and_test_partitions(self):
        for path in DATASETS:
            with self.subTest(dataset=path.name):
                rows = load_dataset(path)
                self.assertEqual(
                    {row["partition"] for row in rows},
                    {"train", "validation", "test"},
                )
                training_labels = {row["intent"] for row in rows if row["partition"] == "train"}
                evaluation_labels = {
                    row["intent"] for row in rows if row["partition"] != "train"
                } - {"unknown"}
                self.assertTrue(evaluation_labels.issubset(training_labels))

    def test_every_algorithm_reports_finite_metrics(self):
        for path in DATASETS:
            with self.subTest(dataset=path.name):
                results = evaluate(load_dataset(path))
                self.assertEqual({row["algorithm"] for row in results}, set(ALGORITHMS))
                for result in results:
                    for metric in (
                        "accuracy", "macro_f1", "unknown_precision", "unknown_recall",
                    ):
                        self.assertGreaterEqual(result[metric], 0.0)
                        self.assertLessEqual(result[metric], 1.0)
                    self.assertGreater(result["samples"], 0)
                    self.assertGreaterEqual(result["avg_latency_ms"], 0.0)


if __name__ == "__main__":
    unittest.main()