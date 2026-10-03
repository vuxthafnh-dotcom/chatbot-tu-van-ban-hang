import unittest

from chatbot.chatbot import FashionChatbot
from chatbot.nlp import extract_product_requests


class ProductRequestTests(unittest.TestCase):
    def test_extracts_category_and_color_for_each_product(self):
        self.assertEqual(
            extract_product_requests("\u00e1o tr\u1eafng qu\u1ea7n \u0111en"),
            [
                {"category_keyword": "ao", "color": "Trắng"},
                {"category_keyword": "quan", "color": "Đen"},
            ],
        )

    def test_recognizes_shoes_as_a_distinct_category(self):
        self.assertEqual(
            extract_product_requests("gi\u00e0y \u0111\u1ecf"),
            [{"category_keyword": "giay", "color": "Đỏ"}],
        )

    def test_search_does_not_return_other_categories_for_shoes(self):
        chatbot = FashionChatbot.__new__(FashionChatbot)
        captured = {}

        def fake_search(keywords, price_filter, limit=8):
            captured.update(keywords)
            return []

        chatbot._search_products_by_keywords = fake_search
        self.assertEqual(chatbot.search_products("gi\u00e0y \u0111\u1ecf"), [])
        self.assertEqual(captured["category_keyword"], "giay")
        self.assertEqual(captured["color"], "Đỏ")

    def test_missing_shoes_do_not_fall_back_to_unfiltered_ai(self):
        chatbot = FashionChatbot.__new__(FashionChatbot)
        chatbot.conversation = []
        chatbot.answer_size_question = lambda text: None
        chatbot.is_size_advice_question = lambda text: False
        chatbot.should_search = lambda text: True
        chatbot.search_products = lambda text: []
        chatbot.answer_with_external_ai = lambda *args: "Gợi ý áo đỏ không liên quan"
        chatbot.answer_with_local_ai = lambda *args: "Gợi ý quần đỏ không liên quan"

        answer, intent, _ = chatbot.reply("gi\u00e0y \u0111\u1ecf")

        self.assertEqual(intent, "product_search")
        self.assertIn("chưa tìm thấy sản phẩm phù hợp", answer)
        self.assertNotIn("áo đỏ", answer)

    def test_search_uses_each_products_own_filters(self):
        chatbot = FashionChatbot.__new__(FashionChatbot)
        captured_requests = []

        def fake_search(keywords, price_filter, limit=8):
            captured_requests.append((keywords, limit))
            product_id = len(captured_requests)
            category = "Áo nữ" if keywords["category_keyword"] == "ao" else "Quần nữ"
            return [{
                "id": product_id,
                "name": f"Sản phẩm {product_id}",
                "category": category,
                "gender": "Nữ",
                "color": keywords["color"],
                "price": 100000,
                "size": "M",
                "stock": 5,
                "description": "Sản phẩm mẫu",
            }]

        chatbot._search_products_by_keywords = fake_search
        products = chatbot.search_products("\u00e1o tr\u1eafng qu\u1ea7n \u0111en")

        self.assertEqual(len(captured_requests), 2)
        self.assertEqual(captured_requests[0][0]["category_keyword"], "ao")
        self.assertEqual(captured_requests[0][0]["color"], "Trắng")
        self.assertEqual(captured_requests[1][0]["category_keyword"], "quan")
        self.assertEqual(captured_requests[1][0]["color"], "Đen")
        self.assertEqual([limit for _, limit in captured_requests], [4, 4])
        self.assertEqual([product["category"] for product in products], ["Áo nữ", "Quần nữ"])
        response = chatbot.format_products(products)
        self.assertIn("Áo nữ:", response)
        self.assertIn("Quần nữ:", response)
        self.assertIn("Màu: Trắng", response)
        self.assertIn("Màu: Đen", response)


if __name__ == "__main__":
    unittest.main()