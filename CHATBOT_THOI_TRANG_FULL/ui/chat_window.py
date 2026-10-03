import customtkinter as ctk
from chatbot.chatbot import FashionChatbot
from chatbot.nlp import extract_keywords, normalize_text

ctk.set_appearance_mode("light")
ctk.set_default_color_theme("blue")


def get_follow_up_questions(text, offset=0):
    normalized = normalize_text(text)
    keywords = extract_keywords(text)

    if "size" in normalized:
        questions = [
            "Tư vấn size áo cho tôi",
            "Quần size 30 còn mẫu nào?",
            "Tôi cao 1m65, nặng 55kg mặc size gì?",
            "Có áo size M màu trắng không?",
            "Size của váy có những loại nào?",
            "Tôi muốn xem bảng size",
        ]
    elif any(term in normalized for term in ("giao hang", "ship", "van chuyen", "dia chi", "mo cua", "doi tra")):
        questions = [
            "Shop giao hàng mất bao lâu?",
            "Phí giao hàng là bao nhiêu?",
            "Shop có giao hàng toàn quốc không?",
            "Địa chỉ cửa hàng ở đâu?",
            "Shop mở cửa đến mấy giờ?",
            "Chính sách đổi trả thế nào?",
        ]
    elif keywords.get("category_keyword"):
        category = {
            "ao": "áo",
            "ao khoac": "áo khoác",
            "quan": "quần",
            "vay": "váy",
            "phu kien": "phụ kiện",
        }[keywords["category_keyword"]]
        if keywords.get("gender"):
            category += " " + keywords["gender"].lower()
        questions = [
            f"Còn {category} màu đen không?",
            f"Có {category} dưới 500 nghìn không?",
            f"{category.capitalize()} có những size nào?",
            f"Cho tôi xem mẫu {category} bán chạy",
            f"Có {category} phù hợp đi làm không?",
            f"Mẫu {category} nào giá tốt nhất?",
        ]
    elif keywords.get("color"):
        color = keywords["color"].lower()
        questions = [
            f"Có áo màu {color} không?",
            f"Cho xem quần màu {color}",
            f"Có váy màu {color} không?",
            f"Tìm áo khoác màu {color}",
            f"Sản phẩm màu {color} giá dưới 500k",
            f"Màu {color} còn size M không?",
        ]
    else:
        questions = [
            "Tìm áo nam dưới 500 nghìn",
            "Có váy nữ màu hồng không?",
            "Tư vấn size giúp tôi",
            "Shop có giao hàng toàn quốc không?",
            "Tìm quần jean size 30",
            "Địa chỉ cửa hàng ở đâu?",
        ]

    start = offset % len(questions)
    return [questions[(start + index) % len(questions)] for index in range(3)]


class ChatWindow(ctk.CTk):
    def __init__(self):
        super().__init__()
        self.title("Fashion AI • Chatbot tư vấn thời trang")
        self.geometry("1180x760")
        self.minsize(1000, 680)
        self.configure(fg_color="#f3f5f8")
        self.bot = FashionChatbot()
        self.suggestion_offset = 0

        self.grid_columnconfigure(1, weight=1)
        self.grid_rowconfigure(1, weight=1)

        self.sidebar = ctk.CTkFrame(self, width=280, corner_radius=0, fg_color="#131c2f")
        self.sidebar.grid(row=0, column=0, rowspan=3, sticky="nsew")
        self.sidebar.grid_propagate(False)

        ctk.CTkLabel(
            self.sidebar,
            text="FASHION AI",
            font=ctk.CTkFont(size=30, weight="bold"),
            text_color="#ffffff",
        ).pack(pady=(30, 4))

        ctk.CTkLabel(
            self.sidebar,
            text="Trợ lý bán hàng thời trang",
            font=ctk.CTkFont(size=13),
            text_color="#dfe7fb",
        ).pack(pady=(0, 24))

        ctk.CTkButton(
            self.sidebar,
            text="💬 Bắt đầu tư vấn",
            height=42,
            corner_radius=14,
            fg_color="#ff7b54",
            hover_color="#ea693f",
            text_color="#ffffff",
            font=ctk.CTkFont(size=14, weight="bold"),
            command=self.focus_chat,
        ).pack(fill="x", padx=24, pady=(0, 22))

        self.quick_suggestions = ctk.CTkFrame(self.sidebar, fg_color="transparent")
        self.quick_suggestions.pack(fill="x", padx=18, pady=(8, 0))

        ctk.CTkLabel(
            self.quick_suggestions,
            text="CÂU HỎI GỢI Ý",
            font=ctk.CTkFont(size=11, weight="bold"),
            text_color="#91a5cc",
        ).pack(anchor="w", padx=4, pady=(0, 6))
        self.suggestion_buttons = []
        for _ in range(3):
            btn = ctk.CTkButton(
                self.quick_suggestions,
                text="",
                height=44,
                corner_radius=10,
                fg_color="#1f2c44",
                hover_color="#2a3b5c",
                text_color="#edf3ff",
                anchor="w",
                font=ctk.CTkFont(size=12),
                command=lambda button_index=len(self.suggestion_buttons): self.ask_suggestion(button_index),
            )
            btn.pack(fill="x", pady=6)
            self.suggestion_buttons.append(btn)

        ctk.CTkLabel(
            self.sidebar,
            text="Bạn có thể hỏi bằng tiếng Việt như: tìm sản phẩm, màu sắc, size, giá, hoặc giao hàng.",
            justify="left",
            wraplength=225,
            text_color="#bfd0ff",
            font=ctk.CTkFont(size=12),
        ).pack(anchor="w", padx=24, pady=(24, 0))

        self.header = ctk.CTkFrame(self, height=82, corner_radius=0, fg_color="#ffffff")
        self.header.grid(row=0, column=1, sticky="ew")
        self.header.grid_columnconfigure(0, weight=1)

        self.title_label = ctk.CTkLabel(
            self.header,
            text="Trợ lý tư vấn thời trang",
            font=ctk.CTkFont(size=22, weight="bold"),
            text_color="#171f2b",
        )
        self.title_label.grid(row=0, column=0, padx=26, pady=18, sticky="w")

        self.status_badge = ctk.CTkFrame(self.header, width=110, height=34, corner_radius=16, fg_color="#e8fdf2")
        self.status_badge.grid(row=0, column=1, padx=(0, 20), pady=22, sticky="e")
        ctk.CTkLabel(
            self.status_badge,
            text="● Online",
            font=ctk.CTkFont(size=12, weight="bold"),
            text_color="#0b8a5b",
        ).place(relx=0.5, rely=0.5, anchor="center")

        ctk.CTkButton(
            self.header,
            text="Cuộc trò chuyện mới",
            width=170,
            height=36,
            corner_radius=10,
            fg_color="#eef3ff",
            text_color="#1d3557",
            hover_color="#e2ebff",
            command=self.reset_chat,
        ).grid(row=0, column=2, padx=(0, 18), pady=22, sticky="e")

        self.chat = ctk.CTkScrollableFrame(self, fg_color="#f8fafc", corner_radius=18)
        self.chat.grid(row=1, column=1, sticky="nsew", padx=18, pady=(12, 10))
        self.chat.grid_columnconfigure(0, weight=1)

        bottom = ctk.CTkFrame(self, fg_color="transparent")
        bottom.grid(row=2, column=1, sticky="ew", padx=18, pady=(0, 16))
        bottom.grid_columnconfigure(0, weight=1)

        self.entry = ctk.CTkEntry(
            bottom,
            height=52,
            border_width=1,
            corner_radius=16,
            fg_color="#ffffff",
            border_color="#d9dfeb",
            placeholder_text="Nhập tin nhắn bằng tiếng Việt...",
            font=ctk.CTkFont(family="Segoe UI", size=14),
        )
        self.entry.grid(row=0, column=0, sticky="ew", padx=(0, 12))
        self.entry.bind("<Return>", self.send)

        ctk.CTkButton(
            bottom,
            text="GỬI",
            width=120,
            height=52,
            corner_radius=16,
            fg_color="#ff7b54",
            hover_color="#eb693f",
            text_color="white",
            font=ctk.CTkFont(size=14, weight="bold"),
            command=self.send,
        ).grid(row=0, column=1)

        self.add_message("FASHION AI", "Xin chào! 👋\nMình là trợ lý thời trang. Bạn có thể hỏi về sản phẩm, giá, màu sắc, size, hoặc giao hàng.")
        self.add_message("GỢI Ý", "Ví dụ: tìm áo nam dưới 500k, hoặc tư vấn size cho bạn.")
        self.update_suggestions("")

    def add_message(self, sender, text):
        is_user = sender == "BẠN"
        is_system = sender == "HỆ THỐNG"
        row = ctk.CTkFrame(self.chat, fg_color="transparent")
        row.grid(row=len(self.chat.winfo_children()), column=0, sticky="ew", padx=10, pady=(4, 8))
        row.grid_columnconfigure(0, weight=1)

        if is_user:
            bubble_color = "#ff7b54"
            text_color = "white"
            anchor = "e"
            side_pad = (110, 8)
        elif is_system:
            bubble_color = "#fce7e7"
            text_color = "#a11f1f"
            anchor = "w"
            side_pad = (8, 110)
        else:
            bubble_color = "#ffffff"
            text_color = "#1f2937"
            anchor = "w"
            side_pad = (8, 110)

        bubble = ctk.CTkFrame(row, fg_color=bubble_color, corner_radius=18)
        bubble.grid(row=0, column=0, sticky=anchor, padx=side_pad)

        ctk.CTkLabel(
            bubble,
            text=sender,
            text_color=text_color,
            font=ctk.CTkFont(size=11, weight="bold"),
            anchor="w",
        ).pack(anchor="w", padx=14, pady=(10, 2))

        ctk.CTkLabel(
            bubble,
            text=text,
            text_color=text_color,
            font=ctk.CTkFont(size=14),
            justify="left",
            anchor="w",
            wraplength=620,
        ).pack(anchor="w", padx=14, pady=(0, 10))

        self.chat._parent_canvas.yview_moveto(1.0)

    def send(self, event=None):
        text = self.entry.get().strip()
        if not text:
            return
        self.entry.delete(0, "end")
        self.add_message("BẠN", text)
        try:
            answer, intent, score = self.bot.reply(text)
            self.add_message("FASHION AI", answer)
            self.bot.save_history(text, answer, intent, score)
        except Exception as e:
            self.add_message("HỆ THỐNG", f"Lỗi kết nối/xử lý: {e}")
        self.update_suggestions(text)

    def update_suggestions(self, text):
        questions = get_follow_up_questions(text, self.suggestion_offset)
        self.suggestion_offset += 3
        for button, question in zip(self.suggestion_buttons, questions):
            button.configure(text=question)

    def ask_suggestion(self, button_index):
        question = self.suggestion_buttons[button_index].cget("text")
        self.entry.delete(0, "end")
        self.entry.insert(0, question)
        self.entry.focus_set()

    def focus_chat(self):
        self.entry.focus_set()
        self.chat._parent_canvas.yview_moveto(1.0)

    def reset_chat(self):
        self.bot.reset_conversation()
        self.suggestion_offset = 0
        for child in self.chat.winfo_children():
            child.destroy()
        self.add_message("FASHION AI", "Mình sẵn sàng tư vấn. Bạn đang tìm loại trang phục, màu, size hoặc mức giá nào?")
        self.update_suggestions("")
        self.focus_chat()


def run():
    app = ChatWindow()
    app.mainloop()
