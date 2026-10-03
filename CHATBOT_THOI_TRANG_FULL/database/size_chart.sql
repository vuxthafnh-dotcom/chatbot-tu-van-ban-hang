USE fashion_chatbot;

CREATE TABLE IF NOT EXISTS size_chart (
    id INT AUTO_INCREMENT PRIMARY KEY,
    gender ENUM('Nam','Nữ','Unisex') NOT NULL,
    size VARCHAR(20) NOT NULL,
    min_height_cm DECIMAL(5,1) NOT NULL,
    max_height_cm DECIMAL(5,1) NOT NULL,
    min_weight_kg DECIMAL(5,1) NOT NULL,
    max_weight_kg DECIMAL(5,1) NOT NULL,
    note VARCHAR(255) NULL,
    UNIQUE KEY uq_size_chart (gender, size),
    INDEX idx_size_gender (gender)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

INSERT INTO size_chart(gender, size, min_height_cm, max_height_cm, min_weight_kg, max_weight_kg, note) VALUES
('Nam', 'S', 155, 165, 45, 55, 'Dáng người nhỏ hoặc gọn'),
('Nam', 'M', 160, 172, 55, 65, 'Dáng người trung bình'),
('Nam', 'L', 168, 178, 65, 75, 'Dáng người cao vừa'),
('Nam', 'XL', 175, 185, 75, 90, 'Dáng người lớn hoặc cao'),
('Nam', 'XXL', 180, 195, 90, 110, 'Dáng người cao và lớn'),
('Nữ', 'S', 150, 160, 40, 50, 'Dáng người nhỏ hoặc gọn'),
('Nữ', 'M', 155, 165, 50, 60, 'Dáng người trung bình'),
('Nữ', 'L', 160, 172, 60, 70, 'Dáng người cao vừa'),
('Nữ', 'XL', 165, 180, 70, 85, 'Dáng người lớn hoặc cao'),
('Unisex', 'S', 150, 165, 45, 55, 'Dáng người nhỏ hoặc gọn'),
('Unisex', 'M', 160, 172, 55, 68, 'Dáng người trung bình'),
('Unisex', 'L', 168, 180, 68, 80, 'Dáng người cao vừa'),
('Unisex', 'XL', 175, 190, 80, 100, 'Dáng người lớn hoặc cao')
ON DUPLICATE KEY UPDATE
    min_height_cm = VALUES(min_height_cm),
    max_height_cm = VALUES(max_height_cm),
    min_weight_kg = VALUES(min_weight_kg),
    max_weight_kg = VALUES(max_weight_kg),
    note = VALUES(note);
