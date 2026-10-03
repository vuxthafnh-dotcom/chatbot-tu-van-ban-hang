USE fashion_chatbot;

CREATE TABLE IF NOT EXISTS product_variants (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    sku VARCHAR(80) NOT NULL UNIQUE,
    color_id INT NOT NULL,
    size VARCHAR(30) NOT NULL,
    price DECIMAL(12,0) NULL,
    stock INT NOT NULL DEFAULT 0,
    status TINYINT NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (color_id) REFERENCES colors(id),
    INDEX idx_variant_product (product_id),
    INDEX idx_variant_size (size),
    INDEX idx_variant_stock (stock)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

INSERT INTO product_variants(product_id, sku, color_id, size, price, stock)
SELECT p.id, CONCAT('LEGACY-', p.id), p.color_id, p.size, p.price, p.stock
FROM products p
LEFT JOIN product_variants v ON v.product_id = p.id
WHERE v.id IS NULL;

CREATE TABLE IF NOT EXISTS store_settings (
    setting_key VARCHAR(80) PRIMARY KEY,
    setting_value VARCHAR(500) NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

INSERT INTO store_settings(setting_key, setting_value) VALUES
('store_name', 'Fashion AI Shop'),
('store_address', '123 Nguyễn Trãi, Quận 1, TP. Hồ Chí Minh'),
('store_phone', '0900 000 000'),
('store_email', 'contact@fashionai.local'),
('return_days', '7 ngày'),
('return_condition', 'Sản phẩm chưa qua sử dụng, còn tem nhãn và hóa đơn')
ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value);

CREATE TABLE IF NOT EXISTS store_hours (
    day_of_week TINYINT PRIMARY KEY,
    day_name VARCHAR(20) NOT NULL,
    open_time TIME NULL,
    close_time TIME NULL,
    is_closed TINYINT NOT NULL DEFAULT 0
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

INSERT INTO store_hours(day_of_week, day_name, open_time, close_time, is_closed) VALUES
(1, 'Thứ 2', '09:00:00', '21:00:00', 0),
(2, 'Thứ 3', '09:00:00', '21:00:00', 0),
(3, 'Thứ 4', '09:00:00', '21:00:00', 0),
(4, 'Thứ 5', '09:00:00', '21:00:00', 0),
(5, 'Thứ 6', '09:00:00', '21:00:00', 0),
(6, 'Thứ 7', '09:00:00', '21:00:00', 0),
(7, 'Chủ nhật', '09:00:00', '21:00:00', 0)
ON DUPLICATE KEY UPDATE
    day_name = VALUES(day_name),
    open_time = VALUES(open_time),
    close_time = VALUES(close_time),
    is_closed = VALUES(is_closed);

CREATE TABLE IF NOT EXISTS shipping_rules (
    id INT AUTO_INCREMENT PRIMARY KEY,
    area VARCHAR(100) NOT NULL UNIQUE,
    fee DECIMAL(12,0) NOT NULL DEFAULT 0,
    free_shipping_min DECIMAL(12,0) NULL,
    min_days TINYINT NOT NULL,
    max_days TINYINT NOT NULL,
    active TINYINT NOT NULL DEFAULT 1
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

INSERT INTO shipping_rules(area, fee, free_shipping_min, min_days, max_days) VALUES
('Nội thành', 25000, 500000, 1, 2),
('Ngoại tỉnh', 35000, 500000, 3, 5)
ON DUPLICATE KEY UPDATE
    fee = VALUES(fee),
    free_shipping_min = VALUES(free_shipping_min),
    min_days = VALUES(min_days),
    max_days = VALUES(max_days),
    active = 1;

CREATE TABLE IF NOT EXISTS faq_keywords (
    id INT AUTO_INCREMENT PRIMARY KEY,
    faq_id INT NOT NULL,
    keyword VARCHAR(120) NOT NULL,
    UNIQUE KEY uq_faq_keyword (faq_id, keyword),
    FOREIGN KEY (faq_id) REFERENCES store_faqs(id) ON DELETE CASCADE,
    INDEX idx_faq_keyword (keyword)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

INSERT INTO faq_keywords(faq_id, keyword)
SELECT id, sample_question FROM store_faqs s
WHERE NOT EXISTS (
    SELECT 1 FROM faq_keywords k WHERE k.faq_id = s.id AND k.keyword = s.sample_question
);
