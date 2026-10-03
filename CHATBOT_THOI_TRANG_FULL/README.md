# CHATBOT TƯ VẤN BÁN HÀNG THỜI TRANG

## Cài đặt
1. Bật MySQL trong XAMPP.
2. Kiểm tra tài khoản MySQL trong `database/connection.py`.
3. Import `database/fashion_chatbot.sql` vào phpMyAdmin để tạo dữ liệu nền.
4. Import `database/fashion_faq.sql` để nạp 43 câu hỏi thường gặp của cửa hàng.
5. Import `database/schema_upgrade.sql` để tạo cấu trúc biến thể, giờ mở cửa và quy tắc giao hàng.
6. Import `database/seed_100_products.sql` nếu cần thêm 100 sản phẩm demo.
7. Import `database/size_chart.sql` để tạo bảng size theo chiều cao/cân nặng.
8. Chạy: `python -m pip install -r requirements.txt`
9. Chạy: `python main.py`

Nếu cơ sở dữ liệu đã có sẵn, chỉ import `database/fashion_faq.sql`. Không import lại `fashion_chatbot.sql` vì file này tạo lại dữ liệu mẫu.

`schema_upgrade.sql` là migration an toàn, không xóa sản phẩm hoặc lịch sử chat. Nó tạo `product_variants`, `store_settings`, `store_hours`, `shipping_rules` và `faq_keywords`.

## Cập nhật dữ liệu cửa hàng

- Địa chỉ, số điện thoại: sửa bảng `store_settings`.
- Giờ mở cửa từng ngày: sửa bảng `store_hours`.
- Phí và thời gian giao: sửa bảng `shipping_rules`.
- Câu hỏi và từ khóa FAQ: sửa bảng `store_faqs`.
- Size/màu/tồn kho thực tế: thêm từng biến thể vào `product_variants` với `sku`, `product_id`, `color_id`, `size`, `price` và `stock`.
- Khoảng chiều cao/cân nặng theo size: sửa bảng `size_chart`.

Ví dụ cập nhật dữ liệu cửa hàng:

```sql
UPDATE store_settings
SET setting_value = 'Địa chỉ thật của cửa hàng'
WHERE setting_key = 'store_address';

UPDATE shipping_rules
SET fee = 30000, free_shipping_min = 600000
WHERE area = 'Nội thành';
```

Sau khi sửa dữ liệu, chỉ cần khởi động lại `python main.py`; không cần sửa code chatbot.

`seed_100_products.sql` thêm 100 sản phẩm demo và 100 biến thể tương ứng. File có thể chạy lại, các dòng có mã `DEMO-` sẽ được thay mới.

`size_chart.sql` thêm bảng size mẫu cho Nam, Nữ và Unisex. Chatbot hiểu các câu như `size`, `Nam cao 1m65 nặng 55kg` hoặc `Nữ cao 160cm nặng 52kg`.

## Bật AI ngoài (tùy chọn)

Mặc định chatbot dùng NLP nội bộ và dữ liệu trực tiếp từ MySQL. Nếu muốn AI diễn đạt câu trả lời tự nhiên hơn, đặt biến môi trường trước khi chạy:

PowerShell:
```powershell
$env:OPENAI_API_KEY="your-api-key"
$env:OPENAI_MODEL="gpt-4o-mini"
python main.py
```

Hoặc tạo file `.env` ở thư mục gốc dựa trên `.env.example`, sau đó chạy lại ứng dụng. Không đưa API key vào Git hoặc gửi lên kho mã nguồn.

AI ngoài chỉ nhận danh sách sản phẩm đã được lọc từ CSDL, không tự truy cập hoặc tự bịa dữ liệu sản phẩm. Nếu API lỗi hoặc chưa có key, chatbot tự động dùng câu trả lời nội bộ.

## Dùng AI miễn phí không cần API key

Có thể dùng Ollama để chạy mô hình ngay trên máy:

1. Cài Ollama từ `https://ollama.com/download`.
2. Mở PowerShell và chạy:

```powershell
ollama pull llama3.2:3b
ollama serve
```

3. Mở cửa sổ PowerShell khác và chạy `python main.py`.

Ứng dụng sẽ ưu tiên OpenAI nếu có `OPENAI_API_KEY`; nếu không có, nó sẽ thử Ollama tại `localhost:11434`. Ollama không cần API key và dữ liệu sản phẩm vẫn được lấy từ MySQL trước khi gửi vào model cục bộ.

## Công nghệ
Python, CustomTkinter, MySQL, PyMySQL, scikit-learn TF-IDF + Cosine Similarity, underthesea.

## Chức năng
Chatbot đọc dữ liệu sản phẩm trực tiếp từ MySQL, tìm theo loại, giới tính, màu, size, giá; hỗ trợ tách yêu cầu nhiều mặt hàng/màu trong cùng câu (ví dụ áo trắng và quần đen); nhận diện câu hỏi bằng TF-IDF/Cosine Similarity; lưu lịch sử chat. Các loại sản phẩm được tư vấn phải có trong danh mục database; nếu danh mục không có (ví dụ database mẫu hiện chưa có Giày), chatbot sẽ báo không tìm thấy thay vì gợi ý loại khác.

## Thực nghiệm nhận diện ý định

Chatbot so khớp intent bằng TF-IDF ký tự (character n-gram, độ dài 2-5). TF-IDF ký tự có thể giúp nhận diện câu có lỗi gõ hoặc khác biệt nhỏ trong cách viết. Ngưỡng điểm 0,35 được giữ để từ chối câu quá khác dữ liệu mẫu. Lựa chọn này dựa trên benchmark nhỏ bên dưới; cần xác nhận lại với dữ liệu hội thoại thực tế.

Chạy benchmark offline, không cần MySQL hoặc API:

```powershell
python -m evaluation.intent_benchmark
```

Bộ dữ liệu `evaluation/intent_dataset.csv` tách train, validation và hai tập test paraphrase/noisy. Benchmark so sánh năm phương án: TF-IDF từ/ngữ + cosine, TF-IDF ký tự + cosine, cosine kết hợp, Multinomial Naive Bayes và Linear SVM. Ngưỡng từ chối được chọn trên validation riêng cho từng phương án. Báo cáo gồm Accuracy, Macro-F1, precision/recall cho lớp `unknown`, ngưỡng đã chọn và độ trễ trung bình. Có thể xuất kết quả CSV bằng `--output evaluation/results.csv`.

Có thể chạy cùng benchmark trên bộ FAQ riêng (các nhãn và câu mẫu được lấy từ `database/fashion_faq.sql`):

```powershell
python -m evaluation.intent_benchmark --data evaluation/faq_dataset.csv
```

Chạy đồng thời cả hai bộ và lưu bảng tổng hợp:

```powershell
python -m evaluation.intent_benchmark --data evaluation/intent_dataset.csv --data evaluation/faq_dataset.csv --output evaluation/results.csv
python -m unittest evaluation.test_intent_benchmark
```

`evaluation/results.csv` là kết quả benchmark offline do lệnh trên sinh ra từ các hàng train/validation/test trong hai file CSV. Đây không phải lịch sử chạy giao diện chatbot và cũng chưa phải kết quả trên hội thoại khách hàng thật.

Các tập hiện tại nhỏ và gồm câu tự biên soạn cùng câu mẫu FAQ, chưa đại diện cho hội thoại thật hoặc dữ liệu độc lập bên ngoài. Trước khi kết luận mô hình nào tốt hơn, cần thu thập câu hỏi thực tế đã ẩn thông tin cá nhân, gán nhãn thủ công, tăng số mẫu mỗi intent và giữ một tập test độc lập. Ngưỡng từ chối được chọn trên validation, không điều chỉnh theo test.
