CREATE DATABASE IF NOT EXISTS fashion_chatbot
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE fashion_chatbot;

DROP TABLE IF EXISTS chat_history;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS intents;
DROP TABLE IF EXISTS colors;
DROP TABLE IF EXISTS categories;

CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE colors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    category_id INT NOT NULL,
    gender ENUM('Nam','Nữ','Unisex') NOT NULL,
    color_id INT NOT NULL,
    price DECIMAL(12,0) NOT NULL,
    size VARCHAR(100) NOT NULL,
    description TEXT,
    stock INT DEFAULT 0,
    status TINYINT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id),
    FOREIGN KEY (color_id) REFERENCES colors(id)
);

CREATE TABLE intents (
    id INT AUTO_INCREMENT PRIMARY KEY,
    intent_code VARCHAR(50) NOT NULL UNIQUE,
    sample_question TEXT NOT NULL,
    answer TEXT NOT NULL
);

CREATE TABLE chat_history (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_message TEXT NOT NULL,
    bot_message TEXT NOT NULL,
    intent_code VARCHAR(50),
    similarity DECIMAL(6,4),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO categories(name) VALUES
('Áo nam'),('Áo nữ'),('Quần nam'),('Quần nữ'),('Váy nữ'),('Áo khoác'),('Phụ kiện');

INSERT INTO colors(name) VALUES
('Đen'),('Trắng'),('Xanh'),('Hồng'),('Xám'),('Be'),('Nâu'),('Đỏ');

INSERT INTO products(name,category_id,gender,color_id,price,size,description,stock) VALUES
('Áo thun nam Basic',1,'Nam',1,199000,'S,M,L,XL','Áo thun cotton mềm, kiểu basic dễ phối đồ.',25),
('Áo sơ mi nam công sở',1,'Nam',2,399000,'M,L,XL','Áo sơ mi lịch sự, phù hợp đi học và đi làm.',18),
('Áo polo nam Classic',1,'Nam',3,329000,'M,L,XL,XXL','Áo polo nam trẻ trung, chất liệu thoáng mát.',22),
('Áo thun nam Oversize',1,'Nam',5,279000,'M,L,XL','Kiểu oversize năng động, phù hợp đi chơi.',20),
('Áo hoodie nữ',2,'Nữ',4,449000,'S,M,L,XL','Hoodie nữ phong cách trẻ trung, giữ ấm tốt.',15),
('Áo kiểu nữ thanh lịch',2,'Nữ',2,359000,'S,M,L','Áo nữ thanh lịch phù hợp công sở.',14),
('Áo croptop nữ',2,'Nữ',4,299000,'S,M,L','Croptop trẻ trung, phù hợp phong cách năng động.',19),
('Quần jean nam Slim Fit',3,'Nam',3,499000,'29,30,31,32,33','Quần jean nam dáng slim fit, dễ phối áo.',12),
('Quần kaki nam',3,'Nam',7,429000,'29,30,31,32,33','Quần kaki nam lịch sự và thoải mái.',16),
('Quần short nam',3,'Nam',5,259000,'M,L,XL','Quần short nam thích hợp đi chơi và du lịch.',24),
('Quần jean nữ Skinny',4,'Nữ',3,459000,'26,27,28,29,30','Quần jean nữ dáng skinny tôn dáng.',13),
('Quần ống rộng nữ',4,'Nữ',2,399000,'S,M,L','Quần ống rộng phong cách hiện đại.',17),
('Váy nữ công sở',5,'Nữ',1,599000,'S,M,L','Váy công sở thanh lịch, thiết kế đơn giản.',10),
('Váy hoa nữ',5,'Nữ',4,529000,'S,M,L','Váy hoa nữ nhẹ nhàng, phù hợp đi chơi.',9),
('Váy dự tiệc',5,'Nữ',8,899000,'S,M,L','Đầm dự tiệc sang trọng, kiểu dáng nổi bật.',7),
('Áo khoác Bomber',6,'Unisex',5,699000,'M,L,XL','Áo khoác bomber unisex phong cách hiện đại.',11),
('Áo khoác Denim',6,'Unisex',3,649000,'M,L,XL','Áo khoác denim dễ phối với nhiều trang phục.',13),
('Áo khoác nữ dáng dài',6,'Nữ',7,799000,'S,M,L','Áo khoác dáng dài thanh lịch.',8),
('Mũ lưỡi trai',7,'Unisex',1,149000,'Free Size','Mũ lưỡi trai đơn giản, dễ phối đồ.',30),
('Túi tote thời trang',7,'Nữ',4,189000,'Free Size','Túi tote tiện dụng cho đi học và đi chơi.',27);

INSERT INTO intents(intent_code,sample_question,answer) VALUES
('greeting','xin chào','Xin chào! Mình là trợ lý thời trang. Bạn muốn tìm sản phẩm nào?'),
('greeting2','chào shop','Chào bạn! Mình có thể tư vấn áo, quần, váy, áo khoác và phụ kiện.'),
('catalog','shop có những sản phẩm nào','Shop hiện có áo nam, áo nữ, quần, váy, áo khoác và phụ kiện.'),
('shipping','shop có giao hàng không','Shop có hỗ trợ giao hàng. Bạn có thể cho mình biết sản phẩm cần mua để mình tư vấn.'),
('payment','shop thanh toán như thế nào','Shop hỗ trợ thanh toán khi nhận hàng và chuyển khoản ngân hàng.'),
('thanks','cảm ơn','Không có gì! Rất vui được hỗ trợ bạn.'),
('bye','tạm biệt','Cảm ơn bạn đã ghé shop. Chúc bạn mua sắm vui vẻ!');

CREATE INDEX idx_product_price ON products(price);
CREATE INDEX idx_product_gender ON products(gender);
CREATE INDEX idx_product_status ON products(status);
