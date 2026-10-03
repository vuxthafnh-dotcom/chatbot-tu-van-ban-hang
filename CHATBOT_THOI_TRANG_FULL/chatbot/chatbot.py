import json
import os
import re
from urllib import error, request

from pymysql.err import ProgrammingError
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

from chatbot.nlp import extract_keywords, extract_price_filter, extract_product_requests, normalize_text
from database.connection import get_connection

try:
    from dotenv import load_dotenv
except ImportError:
    def load_dotenv():
        env_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), ".env")
        if not os.path.exists(env_path):
            return False
        with open(env_path, encoding="utf-8") as env_file:
            for line in env_file:
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    key, value = line.split("=", 1)
                    os.environ.setdefault(key.strip(), value.strip().strip('"\''))
        return True

load_dotenv()


class FashionChatbot:
    def __init__(self):
        self.ai_api_key = os.getenv("OPENAI_API_KEY", "").strip()
        self.ai_endpoint = os.getenv(
            "OPENAI_API_ENDPOINT",
            "https://api.openai.com/v1/chat/completions",
        )
        self.ai_model = os.getenv("OPENAI_MODEL", "gpt-4o-mini")
        self.local_ai_endpoint = os.getenv("OLLAMA_API_ENDPOINT", "http://localhost:11434/api/chat")
        self.local_ai_model = os.getenv("OLLAMA_MODEL", "llama3.2:3b")
        self.conversation = []
        self.reload_intents()

    def reload_intents(self):
        conn = get_connection()
        try:
            with conn.cursor() as cur:
                cur.execute("SELECT intent_code,sample_question,answer FROM intents")
                self.intents = cur.fetchall()
                try:
                    cur.execute("SELECT category,keywords,answer FROM store_faqs ORDER BY id")
                    self.store_faqs = cur.fetchall()
                except ProgrammingError:
                    self.store_faqs = []
        finally:
            conn.close()
        self.questions = [normalize_text(item["sample_question"]) for item in self.intents]
        self.char_vectorizer = TfidfVectorizer(analyzer="char_wb", ngram_range=(2, 5))
        self.char_vectors = self.char_vectorizer.fit_transform(self.questions)

    def detect_intent(self, text):
        if not self.intents:
            return "unknown", 0.0, ""
        vector = self.char_vectorizer.transform([normalize_text(text)])
        scores = cosine_similarity(vector, self.char_vectors)[0]
        index = scores.argmax()
        item = self.intents[index]
        return item["intent_code"], float(scores[index]), item["answer"]

    def search_products(self, text):
        keywords = extract_keywords(text)
        price_filter = extract_price_filter(text)
        product_requests = extract_product_requests(text)
        if not product_requests:
            return self._search_products_by_keywords(keywords, price_filter)

        if len(product_requests) == 1:
            keywords["category_keyword"] = product_requests[0]["category_keyword"]
            if product_requests[0].get("color"):
                keywords["color"] = product_requests[0]["color"]
            return self._search_products_by_keywords(keywords, price_filter)

        rows = []
        seen_ids = set()
        limit_per_category = max(1, 8 // len(product_requests))
        for product_request in product_requests:
            request_keywords = keywords.copy()
            request_keywords["category_keyword"] = product_request["category_keyword"]
            request_keywords.pop("color", None)
            if product_request.get("color"):
                request_keywords["color"] = product_request["color"]
            matches = self._search_products_by_keywords(
                request_keywords,
                price_filter,
                limit=limit_per_category,
            )
            for product in matches:
                if product["id"] not in seen_ids:
                    rows.append(product)
                    seen_ids.add(product["id"])
        return rows[:8]

    def _search_products_by_keywords(self, keywords, price_filter, limit=8):
        sql = """SELECT p.id,p.name,c.name AS category,p.gender,co.name AS color,
                   p.price,p.size,p.description,
                   COALESCE(SUM(v.stock), p.stock) AS stock
                 FROM products p
                 JOIN categories c ON p.category_id=c.id
                 JOIN colors co ON p.color_id=co.id
               LEFT JOIN product_variants v ON v.product_id=p.id AND v.status=1
                 WHERE p.status=1"""
        params = []
        if keywords.get("gender"):
            sql += " AND p.gender IN (%s,'Unisex')"
            params.append(keywords["gender"])
        category = keywords.get("category_keyword")
        if category == "ao":
            sql += " AND c.name LIKE %s"
            params.append("Áo%")
        elif category == "quan":
            sql += " AND c.name LIKE %s"
            params.append("Quần%")
        elif category == "vay":
            sql += " AND c.name LIKE %s"
            params.append("Váy%")
        elif category == "ao khoac":
            sql += " AND c.name='Áo khoác'"
        elif category == "giay":
            sql += " AND c.name LIKE %s"
            params.append("Giày%")
        elif category == "phu kien":
            sql += " AND c.name='Phụ kiện'"
        if keywords.get("color"):
            sql += " AND co.name=%s"
            params.append(keywords["color"])
        if keywords.get("size"):
            sql += " AND EXISTS ("
            sql += "SELECT 1 FROM product_variants sv "
            sql += "WHERE sv.product_id=p.id AND sv.status=1 "
            sql += "AND FIND_IN_SET(%s, REPLACE(sv.size,' ',''))"
            sql += ")"
            params.append(keywords["size"])
        if price_filter:
            minimum = price_filter["minimum"]
            maximum = price_filter["maximum"]
            if minimum is not None:
                sql += " AND p.price " + (">=" if price_filter["minimum_inclusive"] else ">") + " %s"
                params.append(minimum)
            if maximum is not None:
                sql += " AND p.price " + ("<=" if price_filter["maximum_inclusive"] else "<") + " %s"
                params.append(maximum)
        sql += " GROUP BY p.id,p.name,c.name,p.gender,co.name,p.price,p.size,p.description,p.stock"
        sql += f" ORDER BY p.price ASC LIMIT {int(limit)}"
        conn = get_connection()
        try:
            with conn.cursor() as cur:
                cur.execute(sql, params)
                return cur.fetchall()
        finally:
            conn.close()

    def get_catalog(self):
        conn = get_connection()
        try:
            with conn.cursor() as cur:
                cur.execute("""SELECT p.id,p.name,c.name AS category,p.gender,co.name AS color,
                               p.price,p.size,p.description,p.stock
                               FROM products p
                               JOIN categories c ON p.category_id=c.id
                               JOIN colors co ON p.color_id=co.id
                               WHERE p.status=1 ORDER BY c.name,p.price ASC LIMIT 50""")
                return cur.fetchall()
        finally:
            conn.close()

    def check_database(self):
        conn = get_connection()
        try:
            with conn.cursor() as cur:
                cur.execute("SELECT 1")
                return cur.fetchone() is not None
        finally:
            conn.close()

    def get_store_setting(self, key, default=""):
        try:
            conn = get_connection()
            try:
                with conn.cursor() as cur:
                    cur.execute("SELECT setting_value FROM store_settings WHERE setting_key=%s", (key,))
                    row = cur.fetchone()
                    return row["setting_value"] if row else default
            finally:
                conn.close()
        except ProgrammingError:
            return default

    def get_store_hours(self):
        try:
            conn = get_connection()
            try:
                with conn.cursor() as cur:
                    cur.execute(
                        "SELECT day_name,open_time,close_time,is_closed FROM store_hours ORDER BY day_of_week"
                    )
                    return cur.fetchall()
            finally:
                conn.close()
        except ProgrammingError:
            return []

    def get_shipping_rules(self):
        try:
            conn = get_connection()
            try:
                with conn.cursor() as cur:
                    cur.execute(
                        "SELECT area,fee,free_shipping_min,min_days,max_days "
                        "FROM shipping_rules WHERE active=1 ORDER BY id"
                    )
                    return cur.fetchall()
            finally:
                conn.close()
        except ProgrammingError:
            return []

    def get_size_chart(self, gender=None):
        try:
            conn = get_connection()
            try:
                with conn.cursor() as cur:
                    if gender:
                        cur.execute(
                            "SELECT gender,size,min_height_cm,max_height_cm,min_weight_kg,max_weight_kg,note "
                            "FROM size_chart WHERE gender IN (%s,'Unisex') ORDER BY gender,min_height_cm",
                            (gender,),
                        )
                    else:
                        cur.execute(
                            "SELECT gender,size,min_height_cm,max_height_cm,min_weight_kg,max_weight_kg,note "
                            "FROM size_chart ORDER BY gender,min_height_cm"
                        )
                    return cur.fetchall()
            finally:
                conn.close()
        except ProgrammingError:
            return []

    @staticmethod
    def extract_body_measurements(text):
        normalized = normalize_text(text)
        height_match = re.search(
            r"(?:cao|chieu cao)\s*(\d+)\s*m\s*(\d{2,3})|"
            r"(?:cao|chieu cao)\s*(\d+(?:[.,]\d+)?)\s*(m|cm)?",
            normalized,
        )
        weight_match = re.search(r"(?:nang|can nang)\s*(\d+(?:[.,]\d+)?)\s*kg?", normalized)
        height = None
        weight = None
        if height_match:
            if height_match.group(2):
                height = float(height_match.group(1)) * 100 + float(height_match.group(2))
            else:
                height = float(height_match.group(3).replace(",", "."))
            if height_match.group(4) == "m" or height < 3:
                height *= 100
        if weight_match:
            weight = float(weight_match.group(1).replace(",", "."))
        return height, weight

    def format_size_chart(self, rows):
        if not rows:
            return "Bảng size chưa được cập nhật trong hệ thống."
        output = ["Bảng size tham khảo (dữ liệu mẫu):"]
        for row in rows:
            output.append(
                f"• {row['gender']} size {row['size']}: "
                f"cao {row['min_height_cm']:.0f}-{row['max_height_cm']:.0f}cm, "
                f"nặng {row['min_weight_kg']:.0f}-{row['max_weight_kg']:.0f}kg"
            )
        output.append("Nếu số đo nằm giữa hai size, bạn nên chọn size lớn hơn để mặc thoải mái hơn.")
        return "\n".join(output)

    def answer_size_question(self, text):
        normalized = normalize_text(text)
        height, weight = self.extract_body_measurements(text)
        if not self.is_size_advice_question(text) and "size" not in normalized and not (height and weight):
            return None
        gender = None
        keywords = extract_keywords(text)
        if keywords.get("gender"):
            gender = keywords["gender"]
        rows = self.get_size_chart(gender)
        if height is not None and weight is not None and rows:
            matches = [
                row for row in rows
                if float(row["min_height_cm"]) <= height <= float(row["max_height_cm"])
                and float(row["min_weight_kg"]) <= weight <= float(row["max_weight_kg"])
            ]
            if matches:
                options = ", ".join(f"{row['gender']} size {row['size']}" for row in matches)
                return (
                    f"Với chiều cao khoảng {height:.0f}cm và cân nặng {weight:.0f}kg, "
                    f"bạn có thể chọn {options}. Đây là bảng size tham khảo, nên ưu tiên số đo thực tế của sản phẩm.",
                    "size_advice",
                )
            return (
                "Số đo của bạn đang nằm ngoài khoảng size mẫu. Bạn nên gửi thêm giới tính, "
                "vòng ngực/vòng eo hoặc chọn size lớn hơn để được tư vấn an toàn hơn.",
                "size_advice",
            )
        if rows:
            return self.format_size_chart(rows), "size_chart"
        return None

    @staticmethod
    def format_time_value(value):
        if hasattr(value, "strftime"):
            return value.strftime("%H:%M")
        total_seconds = int(value.total_seconds())
        hours, remainder = divmod(total_seconds, 3600)
        minutes = remainder // 60
        return f"{hours:02d}:{minutes:02d}"

    def answer_store_data_question(self, text):
        normalized = normalize_text(text)

        if any(term in normalized for term in ("dia chi", "o dau", "chi nhanh")):
            address = self.get_store_setting("store_address")
            if address:
                return f"Địa chỉ cửa hàng: {address}.", "store_address"

        if any(term in normalized for term in ("mo cua", "gio lam viec", "thoi gian mo cua", "dong cua")):
            hours = self.get_store_hours()
            if hours:
                open_days = [row for row in hours if not row["is_closed"]]
                if open_days:
                    first = open_days[0]
                    same_hours = all(
                        row["open_time"] == first["open_time"] and row["close_time"] == first["close_time"]
                        for row in open_days
                    )
                    if same_hours:
                        open_time = self.format_time_value(first["open_time"])
                        close_time = self.format_time_value(first["close_time"])
                        return (
                            f"Shop mở cửa từ {open_time} đến {close_time} hằng ngày.",
                            "store_hours",
                        )
                    schedule_parts = []
                    for row in hours:
                        time_range = "đóng cửa" if row["is_closed"] else (
                            f"{self.format_time_value(row['open_time'])}-{self.format_time_value(row['close_time'])}"
                        )
                        schedule_parts.append(f"{row['day_name']}: {time_range}")
                    schedule = "; ".join(schedule_parts)
                    return f"Lịch mở cửa của shop: {schedule}.", "store_hours"

        rules = self.get_shipping_rules()
        if rules and ("giao hang" in normalized or re.search(r"\bship\b", normalized)):
            if self.is_delivery_fee_question(text):
                details = "; ".join(
                    f"{row['area'].lower()}: {row['fee']:,.0f}đ"
                    + (f", miễn phí từ {row['free_shipping_min']:,.0f}đ" if row["free_shipping_min"] else "")
                    for row in rules
                )
                return f"Phí giao hàng: {details}.", "shipping_fee"
            if any(term in normalized for term in ("bao lau", "thoi gian", "khi nao")):
                details = "; ".join(
                    f"{row['area'].lower()}: {row['min_days']}-{row['max_days']} ngày"
                    for row in rules
                )
                return f"Thời gian giao hàng dự kiến: {details}.", "shipping_time"

        return None

    def should_search(self, text):
        normalized = normalize_text(text)
        keywords = extract_keywords(text)
        search_terms = ["san pham", "con hang", "ton kho", "mua", "tim", "gia", "duoi", "khoang"]
        has_search_term = any(
            re.search(rf"\b{re.escape(term)}\b", normalized)
            for term in search_terms
        )
        return bool(keywords or extract_price_filter(text) is not None or has_search_term)

    def is_size_advice_question(self, text):
        normalized = normalize_text(text)
        return any(term in normalized for term in [
            "tu van size", "tu van ve size", "chon size", "size nao", "mac size nao",
            "size phu hop", "co the tu van size",
        ])

    def format_products(self, rows):
        if not rows:
            return "Mình chưa tìm thấy sản phẩm phù hợp. Bạn thử đổi loại sản phẩm, màu, size hoặc ngân sách nhé."
        output = ["Mình tìm thấy các sản phẩm phù hợp:"]
        multiple_categories = len({product["category"] for product in rows}) > 1
        current_category = None
        for product in rows:
            if multiple_categories and product["category"] != current_category:
                current_category = product["category"]
                output.append(f"\n{current_category}:")
            output.append(
                f"• {product['name']} — {product['price']:,.0f}đ\n"
                f"  Màu: {product['color']} | Size: {product['size']} | Tồn kho: {product['stock']}\n"
                f"  {product['description']}"
            )
        return "\n\n".join(output)

    def ai_status(self):
        if self.ai_api_key:
            return f"AI ngoài: đang bật ({self.ai_model}). Bot chỉ gửi dữ liệu sản phẩm phù hợp để AI diễn đạt lại."
        return f"AI cục bộ: {self.local_ai_model}. Nếu Ollama đang chạy, chatbot có thể trò chuyện tự nhiên mà không cần API key."

    def answer_with_local_ai(self, question, rows=None):
        product_context = ""
        if rows:
            product_context = "\n".join(
                f"- {item['name']} | {item['gender']} | {item['color']} | {item['price']:,.0f}đ | "
                f"size {item['size']} | tồn {item['stock']} | {item['description']}"
                for item in rows
            )
        messages = [{
            "role": "system",
            "content": (
                "Bạn là trợ lý thời trang thân thiện, trả lời bằng tiếng Việt. "
                "Hãy trò chuyện tự nhiên như một trợ lý AI. Khi có CONTEXT sản phẩm, chỉ dùng context "
                "cho thông tin giá, màu, size, tồn kho và tên sản phẩm; không được tự bịa dữ liệu. "
                "Nếu cần tư vấn size, hãy hỏi chiều cao, cân nặng, giới tính và loại sản phẩm."
            ),
        }]
        messages.extend(self.conversation[-8:])
        messages.append({
            "role": "user",
            "content": f"CÂU HỎI: {question}\nCONTEXT SẢN PHẨM:\n{product_context or 'Không có context sản phẩm.'}",
        })
        payload = {
            "model": self.local_ai_model,
            "stream": False,
            "messages": messages,
        }
        req = request.Request(
            self.local_ai_endpoint,
            data=json.dumps(payload, ensure_ascii=False).encode("utf-8"),
            headers={"Content-Type": "application/json"},
            method="POST",
        )
        try:
            with request.urlopen(req, timeout=45) as response:
                result = json.loads(response.read().decode("utf-8"))
            return result["message"]["content"].strip()
        except (error.URLError, error.HTTPError, TimeoutError, KeyError, TypeError, json.JSONDecodeError):
            return None

    def answer_with_external_ai(self, question, rows=None):
        if not self.ai_api_key:
            return None
        product_context = ""
        if rows:
            product_context = "\n".join(
                f"- {item['name']} | {item['gender']} | {item['color']} | {item['price']:,.0f}đ | "
                f"size {item['size']} | tồn {item['stock']} | {item['description']}"
                for item in rows
            )
        messages = [{
            "role": "system",
            "content": (
                "Bạn là tư vấn viên thời trang bằng tiếng Việt. Trả lời ngắn gọn, thân thiện. "
                "Bạn có thể trò chuyện tự nhiên, giải thích, chào hỏi và tư vấn phong cách. "
                "Khi CONTEXT có dữ liệu sản phẩm, chỉ được dùng dữ liệu đó cho giá, size, màu và tồn kho; "
                "không tự bịa thông tin sản phẩm. Nếu câu hỏi không liên quan sản phẩm, hãy trả lời như một trợ lý chat bình thường."
            ),
        }]
        messages.extend(self.conversation[-8:])
        messages.append({
            "role": "user",
            "content": f"CÂU HỎI: {question}\nCONTEXT SẢN PHẨM:\n{product_context or 'Không có - hãy trò chuyện tự nhiên, không cần tra sản phẩm.'}",
        })
        payload = {
            "model": self.ai_model,
            "temperature": 0.5,
            "messages": messages,
        }
        body = json.dumps(payload, ensure_ascii=False).encode("utf-8")
        req = request.Request(
            self.ai_endpoint,
            data=body,
            headers={
                "Authorization": f"Bearer {self.ai_api_key}",
                "Content-Type": "application/json",
            },
            method="POST",
        )
        try:
            with request.urlopen(req, timeout=12) as response:
                result = json.loads(response.read().decode("utf-8"))
            return result["choices"][0]["message"]["content"].strip()
        except (error.URLError, error.HTTPError, TimeoutError, KeyError, IndexError, json.JSONDecodeError):
            return None

    def is_delivery_fee_question(self, text):
        normalized = normalize_text(text)
        asks_about_delivery = "giao hang" in normalized or re.search(r"\bship\b", normalized)
        asks_about_fee = any(
            re.search(rf"\b{term}\b", normalized)
            for term in ("phi", "tien", "cuoc", "bao nhieu")
        )
        return bool(asks_about_delivery and asks_about_fee)

    def answer_store_question(self, text):
        normalized = normalize_text(text)
        if not self.store_faqs:
            return None

        ignored_words = {"ban", "cho", "co", "gi", "giup", "la", "minh", "muon", "shop", "toi", "ve"}
        query_words = set(re.findall(r"\b[a-z0-9]+\b", normalized)) - ignored_words
        best_faq = None
        best_score = 0.0

        for faq in self.store_faqs:
            for keyword in faq["keywords"].split("|"):
                phrase = normalize_text(keyword.strip())
                phrase_words = set(re.findall(r"\b[a-z0-9]+\b", phrase)) - ignored_words
                if not phrase_words:
                    continue

                if len(query_words) == 1:
                    if phrase_words == query_words and len(phrase_words) == 1:
                        score = 20
                    else:
                        continue
                elif re.search(rf"\b{re.escape(phrase)}\b", normalized):
                    score = 10 + len(phrase_words)
                else:
                    overlap = len(query_words & phrase_words)
                    if not overlap:
                        continue
                    score = (4 * overlap / len(phrase_words)) + (2 * overlap / max(len(query_words), 1))

                if score > best_score:
                    best_faq = faq
                    best_score = score

        if best_faq is None or best_score < 3:
            return None
        return best_faq["answer"], best_faq["category"]

    def reply(self, text):
        size_response = self.answer_size_question(text)
        if size_response:
            answer, intent = size_response
            self.remember(text, answer)
            return answer, intent, 1.0

        if self.is_size_advice_question(text):
            rows = self.search_products(text) if extract_keywords(text) or extract_price_filter(text) is not None else []
            answer = self.answer_with_external_ai(text, rows) or self.answer_with_local_ai(text, rows)
            if answer:
                self.remember(text, answer)
                return answer, "external_size_advice", 1.0
            fallback = (
                "Được chứ! Mình có thể tư vấn size cho bạn. Bạn cho mình biết chiều cao, cân nặng, giới tính "
                "và sản phẩm bạn muốn mặc (ví dụ áo thun nam hoặc váy nữ) nhé. Nếu biết số đo ngực hoặc eo thì càng chính xác."
            )
            self.remember(text, fallback)
            return fallback, "size_advice", 1.0

        if self.should_search(text):
            rows = self.search_products(text)
            if not rows:
                if extract_product_requests(text):
                    answer = self.format_products([])
                    self.remember(text, answer)
                    return answer, "product_search", 1.0
                external_answer = self.answer_with_external_ai(text)
                external_answer = external_answer or self.answer_with_local_ai(text)
                if external_answer:
                    self.remember(text, external_answer)
                    return external_answer, "external_chat", 1.0
                return self.format_products([]), "product_search", 1.0
            answer = self.answer_with_external_ai(text, rows) or self.answer_with_local_ai(text, rows) or self.format_products(rows)
            result = (answer, "external_product_search" if self.ai_api_key else "product_search", 1.0)
            self.remember(text, answer)
            return result

        store_response = self.answer_store_data_question(text) or self.answer_store_question(text)
        if store_response:
            answer, intent = store_response
            self.remember(text, answer)
            return answer, intent, 1.0

        intent, score, answer = self.detect_intent(text)
        if intent in {"shipping", "payment"} and score >= 0.35:
            self.remember(text, answer)
            return answer, intent, score

        external_answer = self.answer_with_external_ai(text) or self.answer_with_local_ai(text)
        if external_answer:
            self.remember(text, external_answer)
            return external_answer, "external_chat", 1.0
        if score >= 0.35:
            self.remember(text, answer)
            return answer, intent, score
        fallback = "Mình có thể trò chuyện và tư vấn thời trang cho bạn. Bạn đang quan tâm sản phẩm, cách phối đồ hay chọn size?"
        self.remember(text, fallback)
        return fallback, "unknown", score

    def remember(self, user_message, assistant_message):
        self.conversation.extend([
            {"role": "user", "content": user_message},
            {"role": "assistant", "content": assistant_message},
        ])

    def reset_conversation(self):
        self.conversation.clear()

    def save_history(self, user_message, bot_message, intent, score):
        conn = get_connection()
        try:
            with conn.cursor() as cur:
                cur.execute(
                    "INSERT INTO chat_history(user_message,bot_message,intent_code,similarity) VALUES(%s,%s,%s,%s)",
                    (user_message, bot_message, intent, score),
                )
            conn.commit()
        finally:
            conn.close()
