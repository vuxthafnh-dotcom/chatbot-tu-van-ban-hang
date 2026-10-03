USE fashion_chatbot;

DELETE FROM product_variants WHERE sku LIKE 'DEMO-%';
DELETE FROM products WHERE name LIKE 'Mẫu demo %';

DROP TEMPORARY TABLE IF EXISTS seed_numbers;
CREATE TEMPORARY TABLE seed_numbers (n INT PRIMARY KEY);
INSERT INTO seed_numbers(n) VALUES
(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),
(11),(12),(13),(14),(15),(16),(17),(18),(19),(20),
(21),(22),(23),(24),(25),(26),(27),(28),(29),(30),
(31),(32),(33),(34),(35),(36),(37),(38),(39),(40),
(41),(42),(43),(44),(45),(46),(47),(48),(49),(50),
(51),(52),(53),(54),(55),(56),(57),(58),(59),(60),
(61),(62),(63),(64),(65),(66),(67),(68),(69),(70),
(71),(72),(73),(74),(75),(76),(77),(78),(79),(80),
(81),(82),(83),(84),(85),(86),(87),(88),(89),(90),
(91),(92),(93),(94),(95),(96),(97),(98),(99),(100);

INSERT INTO products(name, category_id, gender, color_id, price, size, description, stock)
SELECT
    CONCAT('Mẫu demo ', LPAD(n.n, 3, '0'), ' - ', c.name),
    c.id,
    CASE
        WHEN c.id IN (1, 3) THEN 'Nam'
        WHEN c.id IN (2, 4, 5) THEN 'Nữ'
        ELSE 'Unisex'
    END,
    MOD(n.n - 1, 8) + 1,
    149000 + MOD(n.n - 1, 20) * 60000,
    CASE
        WHEN c.id IN (3, 4) THEN '29,30,31,32,33'
        WHEN c.id = 7 THEN 'Free Size'
        ELSE 'S,M,L,XL'
    END,
    CONCAT('Sản phẩm mẫu số ', LPAD(n.n, 3, '0'), ', thiết kế thời trang dễ phối đồ.'),
    5 + MOD(n.n, 26)
FROM seed_numbers n
JOIN categories c ON c.id = MOD(n.n - 1, 7) + 1;

INSERT INTO product_variants(product_id, sku, color_id, size, price, stock)
SELECT p.id, CONCAT('DEMO-', p.id), p.color_id, p.size, p.price, p.stock
FROM products p
WHERE p.name LIKE 'Mẫu demo %'
    AND NOT EXISTS (
            SELECT 1 FROM product_variants v WHERE v.product_id = p.id
    );

DROP TEMPORARY TABLE seed_numbers;
