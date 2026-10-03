-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: fashion_chatbot
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `fashion_chatbot`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `fashion_chatbot` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;

USE `fashion_chatbot`;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES (6,'Áo khoác'),(1,'Áo nam'),(2,'Áo nữ'),(7,'Phụ kiện'),(3,'Quần nam'),(4,'Quần nữ'),(5,'Váy nữ');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chat_history`
--

DROP TABLE IF EXISTS `chat_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `chat_history` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_message` text NOT NULL,
  `bot_message` text NOT NULL,
  `intent_code` varchar(50) DEFAULT NULL,
  `similarity` decimal(6,4) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=70 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `colors`
--

DROP TABLE IF EXISTS `colors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `colors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `colors`
--

LOCK TABLES `colors` WRITE;
/*!40000 ALTER TABLE `colors` DISABLE KEYS */;
INSERT INTO `colors` VALUES (6,'Be'),(4,'Hồng'),(7,'Nâu'),(2,'Trắng'),(5,'Xám'),(3,'Xanh'),(1,'Đen'),(8,'Đỏ');
/*!40000 ALTER TABLE `colors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `faq_keywords`
--

DROP TABLE IF EXISTS `faq_keywords`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `faq_keywords` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `faq_id` int(11) NOT NULL,
  `keyword` varchar(120) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_faq_keyword` (`faq_id`,`keyword`),
  KEY `idx_faq_keyword` (`keyword`),
  CONSTRAINT `faq_keywords_ibfk_1` FOREIGN KEY (`faq_id`) REFERENCES `store_faqs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `faq_keywords`
--

LOCK TABLES `faq_keywords` WRITE;
/*!40000 ALTER TABLE `faq_keywords` DISABLE KEYS */;
INSERT INTO `faq_keywords` VALUES (22,1,'Shop có giao hàng không?'),(28,2,'Shop có ship không?'),(15,3,'Phí giao hàng là bao nhiêu?'),(16,4,'Phí ship bao nhiêu?'),(36,5,'Thời gian giao hàng bao lâu?'),(7,6,'Đơn hàng khi nào tới?'),(23,7,'Shop có giao hàng toàn quốc không?'),(21,8,'Shop có giao hàng hỏa tốc không?'),(40,9,'Tôi kiểm tra đơn hàng ở đâu?'),(41,10,'Tôi muốn đổi địa chỉ giao hàng'),(33,11,'Shop hỗ trợ thanh toán bằng cách nào?'),(4,12,'Có được thanh toán khi nhận hàng không?'),(27,13,'Shop có nhận chuyển khoản không?'),(29,14,'Shop có thanh toán bằng thẻ không?'),(25,15,'Shop có hỗ trợ trả góp không?'),(38,16,'Tôi có thể trả tiền sau khi nhận hàng không?'),(31,17,'Shop có xuất hóa đơn không?'),(5,18,'Cửa hàng ở đâu?'),(6,19,'Địa chỉ shop là gì?'),(11,20,'Mở cửa lúc mấy giờ?'),(34,21,'Shop mở cửa ngày chủ nhật không?'),(13,22,'Ngày lễ shop có mở cửa không?'),(35,23,'Số điện thoại của shop là gì?'),(20,24,'Shop có email không?'),(10,25,'Làm sao để liên hệ với shop?'),(19,26,'Shop có cửa hàng trực tiếp không?'),(2,27,'Chính sách đổi trả của shop thế nào?'),(39,28,'Tôi đổi sang size khác được không?'),(37,29,'Thời hạn đổi trả là bao lâu?'),(17,30,'Sản phẩm lỗi thì xử lý thế nào?'),(1,31,'Bao lâu tôi được hoàn tiền?'),(42,32,'Tôi muốn hủy đơn hàng'),(14,33,'Phí đổi trả do ai chịu?'),(32,34,'Shop đang có khuyến mãi gì?'),(26,35,'Shop có mã giảm giá không?'),(3,36,'Có được miễn phí giao hàng không?'),(30,37,'Shop có tích điểm thành viên không?'),(12,38,'Mua nhiều có được giảm giá không?'),(18,39,'Shop có ảnh sản phẩm không?'),(43,40,'Tư vấn size giúp tôi'),(8,41,'Làm sao biết sản phẩm còn hàng?'),(9,42,'Làm sao đặt mua sản phẩm?'),(24,43,'Shop có gói quà không?');
/*!40000 ALTER TABLE `faq_keywords` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `intents`
--

DROP TABLE IF EXISTS `intents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `intents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `intent_code` varchar(50) NOT NULL,
  `sample_question` text NOT NULL,
  `answer` text NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `intent_code` (`intent_code`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `intents`
--

LOCK TABLES `intents` WRITE;
/*!40000 ALTER TABLE `intents` DISABLE KEYS */;
INSERT INTO `intents` VALUES (1,'greeting','xin chào','Xin chào! Mình là trợ lý thời trang. Bạn muốn tìm sản phẩm nào?'),(2,'greeting2','chào shop','Chào bạn! Mình có thể tư vấn áo, quần, váy, áo khoác và phụ kiện.'),(3,'catalog','shop có những sản phẩm nào','Shop hiện có áo nam, áo nữ, quần, váy, áo khoác và phụ kiện.'),(4,'shipping','shop có giao hàng không','Shop có hỗ trợ giao hàng. Bạn có thể cho mình biết sản phẩm cần mua để mình tư vấn.'),(5,'payment','shop thanh toán như thế nào','Shop hỗ trợ thanh toán khi nhận hàng và chuyển khoản ngân hàng.'),(6,'thanks','cảm ơn','Không có gì! Rất vui được hỗ trợ bạn.'),(7,'bye','tạm biệt','Cảm ơn bạn đã ghé shop. Chúc bạn mua sắm vui vẻ!');
/*!40000 ALTER TABLE `intents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_variants`
--

DROP TABLE IF EXISTS `product_variants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_variants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `sku` varchar(80) NOT NULL,
  `color_id` int(11) NOT NULL,
  `size` varchar(30) NOT NULL,
  `price` decimal(12,0) DEFAULT NULL,
  `stock` int(11) NOT NULL DEFAULT 0,
  `status` tinyint(4) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `sku` (`sku`),
  KEY `color_id` (`color_id`),
  KEY `idx_variant_product` (`product_id`),
  KEY `idx_variant_size` (`size`),
  KEY `idx_variant_stock` (`stock`),
  CONSTRAINT `product_variants_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `product_variants_ibfk_2` FOREIGN KEY (`color_id`) REFERENCES `colors` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=159 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_variants`
--

LOCK TABLES `product_variants` WRITE;
/*!40000 ALTER TABLE `product_variants` DISABLE KEYS */;
INSERT INTO `product_variants` VALUES (1,1,'LEGACY-1',1,'S,M,L,XL',199000,25,1,'2026-09-27 14:41:03'),(2,2,'LEGACY-2',2,'M,L,XL',399000,18,1,'2026-09-27 14:41:03'),(3,3,'LEGACY-3',3,'M,L,XL,XXL',329000,22,1,'2026-09-27 14:41:03'),(4,4,'LEGACY-4',5,'M,L,XL',279000,20,1,'2026-09-27 14:41:03'),(5,5,'LEGACY-5',4,'S,M,L,XL',449000,15,1,'2026-09-27 14:41:03'),(6,6,'LEGACY-6',2,'S,M,L',359000,14,1,'2026-09-27 14:41:03'),(7,7,'LEGACY-7',4,'S,M,L',299000,19,1,'2026-09-27 14:41:03'),(8,8,'LEGACY-8',3,'29,30,31,32,33',499000,12,1,'2026-09-27 14:41:03'),(9,9,'LEGACY-9',7,'29,30,31,32,33',429000,16,1,'2026-09-27 14:41:03'),(10,10,'LEGACY-10',5,'M,L,XL',259000,24,1,'2026-09-27 14:41:03'),(11,11,'LEGACY-11',3,'26,27,28,29,30',459000,13,1,'2026-09-27 14:41:03'),(12,12,'LEGACY-12',2,'S,M,L',399000,17,1,'2026-09-27 14:41:03'),(13,13,'LEGACY-13',1,'S,M,L',599000,10,1,'2026-09-27 14:41:03'),(14,14,'LEGACY-14',4,'S,M,L',529000,9,1,'2026-09-27 14:41:03'),(15,15,'LEGACY-15',8,'S,M,L',899000,7,1,'2026-09-27 14:41:03'),(16,16,'LEGACY-16',5,'M,L,XL',699000,11,1,'2026-09-27 14:41:03'),(17,17,'LEGACY-17',3,'M,L,XL',649000,13,1,'2026-09-27 14:41:03'),(18,18,'LEGACY-18',7,'S,M,L',799000,8,1,'2026-09-27 14:41:03'),(19,19,'LEGACY-19',1,'Free Size',149000,30,1,'2026-09-27 14:41:03'),(20,20,'LEGACY-20',4,'Free Size',189000,27,1,'2026-09-27 14:41:03'),(32,148,'DEMO-148',1,'S,M,L,XL',149000,6,1,'2026-09-27 15:15:01'),(33,149,'DEMO-149',2,'S,M,L,XL',209000,7,1,'2026-09-27 15:15:01'),(34,150,'DEMO-150',3,'29,30,31,32,33',269000,8,1,'2026-09-27 15:15:01'),(35,151,'DEMO-151',4,'29,30,31,32,33',329000,9,1,'2026-09-27 15:15:01'),(36,152,'DEMO-152',5,'S,M,L,XL',389000,10,1,'2026-09-27 15:15:01'),(37,153,'DEMO-153',6,'S,M,L,XL',449000,11,1,'2026-09-27 15:15:01'),(38,154,'DEMO-154',7,'Free Size',509000,12,1,'2026-09-27 15:15:01'),(39,155,'DEMO-155',8,'S,M,L,XL',569000,13,1,'2026-09-27 15:15:01'),(40,156,'DEMO-156',1,'S,M,L,XL',629000,14,1,'2026-09-27 15:15:01'),(41,157,'DEMO-157',2,'29,30,31,32,33',689000,15,1,'2026-09-27 15:15:01'),(42,158,'DEMO-158',3,'29,30,31,32,33',749000,16,1,'2026-09-27 15:15:01'),(43,159,'DEMO-159',4,'S,M,L,XL',809000,17,1,'2026-09-27 15:15:01'),(44,160,'DEMO-160',5,'S,M,L,XL',869000,18,1,'2026-09-27 15:15:01'),(45,161,'DEMO-161',6,'Free Size',929000,19,1,'2026-09-27 15:15:01'),(46,162,'DEMO-162',7,'S,M,L,XL',989000,20,1,'2026-09-27 15:15:01'),(47,163,'DEMO-163',8,'S,M,L,XL',1049000,21,1,'2026-09-27 15:15:01'),(48,164,'DEMO-164',1,'29,30,31,32,33',1109000,22,1,'2026-09-27 15:15:01'),(49,165,'DEMO-165',2,'29,30,31,32,33',1169000,23,1,'2026-09-27 15:15:01'),(50,166,'DEMO-166',3,'S,M,L,XL',1229000,24,1,'2026-09-27 15:15:01'),(51,167,'DEMO-167',4,'S,M,L,XL',1289000,25,1,'2026-09-27 15:15:01'),(52,168,'DEMO-168',5,'Free Size',149000,26,1,'2026-09-27 15:15:01'),(53,169,'DEMO-169',6,'S,M,L,XL',209000,27,1,'2026-09-27 15:15:01'),(54,170,'DEMO-170',7,'S,M,L,XL',269000,28,1,'2026-09-27 15:15:01'),(55,171,'DEMO-171',8,'29,30,31,32,33',329000,29,1,'2026-09-27 15:15:01'),(56,172,'DEMO-172',1,'29,30,31,32,33',389000,30,1,'2026-09-27 15:15:01'),(57,173,'DEMO-173',2,'S,M,L,XL',449000,5,1,'2026-09-27 15:15:01'),(58,174,'DEMO-174',3,'S,M,L,XL',509000,6,1,'2026-09-27 15:15:01'),(59,175,'DEMO-175',4,'Free Size',569000,7,1,'2026-09-27 15:15:01'),(60,176,'DEMO-176',5,'S,M,L,XL',629000,8,1,'2026-09-27 15:15:01'),(61,177,'DEMO-177',6,'S,M,L,XL',689000,9,1,'2026-09-27 15:15:01'),(62,178,'DEMO-178',7,'29,30,31,32,33',749000,10,1,'2026-09-27 15:15:01'),(63,179,'DEMO-179',8,'29,30,31,32,33',809000,11,1,'2026-09-27 15:15:01'),(64,180,'DEMO-180',1,'S,M,L,XL',869000,12,1,'2026-09-27 15:15:01'),(65,181,'DEMO-181',2,'S,M,L,XL',929000,13,1,'2026-09-27 15:15:01'),(66,182,'DEMO-182',3,'Free Size',989000,14,1,'2026-09-27 15:15:01'),(67,183,'DEMO-183',4,'S,M,L,XL',1049000,15,1,'2026-09-27 15:15:01'),(68,184,'DEMO-184',5,'S,M,L,XL',1109000,16,1,'2026-09-27 15:15:01'),(69,185,'DEMO-185',6,'29,30,31,32,33',1169000,17,1,'2026-09-27 15:15:01'),(70,186,'DEMO-186',7,'29,30,31,32,33',1229000,18,1,'2026-09-27 15:15:01'),(71,187,'DEMO-187',8,'S,M,L,XL',1289000,19,1,'2026-09-27 15:15:01'),(72,188,'DEMO-188',1,'S,M,L,XL',149000,20,1,'2026-09-27 15:15:01'),(73,189,'DEMO-189',2,'Free Size',209000,21,1,'2026-09-27 15:15:01'),(74,190,'DEMO-190',3,'S,M,L,XL',269000,22,1,'2026-09-27 15:15:01'),(75,191,'DEMO-191',4,'S,M,L,XL',329000,23,1,'2026-09-27 15:15:01'),(76,192,'DEMO-192',5,'29,30,31,32,33',389000,24,1,'2026-09-27 15:15:01'),(77,193,'DEMO-193',6,'29,30,31,32,33',449000,25,1,'2026-09-27 15:15:01'),(78,194,'DEMO-194',7,'S,M,L,XL',509000,26,1,'2026-09-27 15:15:01'),(79,195,'DEMO-195',8,'S,M,L,XL',569000,27,1,'2026-09-27 15:15:01'),(80,196,'DEMO-196',1,'Free Size',629000,28,1,'2026-09-27 15:15:01'),(81,197,'DEMO-197',2,'S,M,L,XL',689000,29,1,'2026-09-27 15:15:01'),(82,198,'DEMO-198',3,'S,M,L,XL',749000,30,1,'2026-09-27 15:15:01'),(83,199,'DEMO-199',4,'29,30,31,32,33',809000,5,1,'2026-09-27 15:15:01'),(84,200,'DEMO-200',5,'29,30,31,32,33',869000,6,1,'2026-09-27 15:15:01'),(85,201,'DEMO-201',6,'S,M,L,XL',929000,7,1,'2026-09-27 15:15:01'),(86,202,'DEMO-202',7,'S,M,L,XL',989000,8,1,'2026-09-27 15:15:01'),(87,203,'DEMO-203',8,'Free Size',1049000,9,1,'2026-09-27 15:15:01'),(88,204,'DEMO-204',1,'S,M,L,XL',1109000,10,1,'2026-09-27 15:15:01'),(89,205,'DEMO-205',2,'S,M,L,XL',1169000,11,1,'2026-09-27 15:15:01'),(90,206,'DEMO-206',3,'29,30,31,32,33',1229000,12,1,'2026-09-27 15:15:01'),(91,207,'DEMO-207',4,'29,30,31,32,33',1289000,13,1,'2026-09-27 15:15:01'),(92,208,'DEMO-208',5,'S,M,L,XL',149000,14,1,'2026-09-27 15:15:01'),(93,209,'DEMO-209',6,'S,M,L,XL',209000,15,1,'2026-09-27 15:15:01'),(94,210,'DEMO-210',7,'Free Size',269000,16,1,'2026-09-27 15:15:01'),(95,211,'DEMO-211',8,'S,M,L,XL',329000,17,1,'2026-09-27 15:15:01'),(96,212,'DEMO-212',1,'S,M,L,XL',389000,18,1,'2026-09-27 15:15:01'),(97,213,'DEMO-213',2,'29,30,31,32,33',449000,19,1,'2026-09-27 15:15:01'),(98,214,'DEMO-214',3,'29,30,31,32,33',509000,20,1,'2026-09-27 15:15:01'),(99,215,'DEMO-215',4,'S,M,L,XL',569000,21,1,'2026-09-27 15:15:01'),(100,216,'DEMO-216',5,'S,M,L,XL',629000,22,1,'2026-09-27 15:15:01'),(101,217,'DEMO-217',6,'Free Size',689000,23,1,'2026-09-27 15:15:01'),(102,218,'DEMO-218',7,'S,M,L,XL',749000,24,1,'2026-09-27 15:15:01'),(103,219,'DEMO-219',8,'S,M,L,XL',809000,25,1,'2026-09-27 15:15:01'),(104,220,'DEMO-220',1,'29,30,31,32,33',869000,26,1,'2026-09-27 15:15:01'),(105,221,'DEMO-221',2,'29,30,31,32,33',929000,27,1,'2026-09-27 15:15:01'),(106,222,'DEMO-222',3,'S,M,L,XL',989000,28,1,'2026-09-27 15:15:01'),(107,223,'DEMO-223',4,'S,M,L,XL',1049000,29,1,'2026-09-27 15:15:01'),(108,224,'DEMO-224',5,'Free Size',1109000,30,1,'2026-09-27 15:15:01'),(109,225,'DEMO-225',6,'S,M,L,XL',1169000,5,1,'2026-09-27 15:15:01'),(110,226,'DEMO-226',7,'S,M,L,XL',1229000,6,1,'2026-09-27 15:15:01'),(111,227,'DEMO-227',8,'29,30,31,32,33',1289000,7,1,'2026-09-27 15:15:01'),(112,228,'DEMO-228',1,'29,30,31,32,33',149000,8,1,'2026-09-27 15:15:01'),(113,229,'DEMO-229',2,'S,M,L,XL',209000,9,1,'2026-09-27 15:15:01'),(114,230,'DEMO-230',3,'S,M,L,XL',269000,10,1,'2026-09-27 15:15:01'),(115,231,'DEMO-231',4,'Free Size',329000,11,1,'2026-09-27 15:15:01'),(116,232,'DEMO-232',5,'S,M,L,XL',389000,12,1,'2026-09-27 15:15:01'),(117,233,'DEMO-233',6,'S,M,L,XL',449000,13,1,'2026-09-27 15:15:01'),(118,234,'DEMO-234',7,'29,30,31,32,33',509000,14,1,'2026-09-27 15:15:01'),(119,235,'DEMO-235',8,'29,30,31,32,33',569000,15,1,'2026-09-27 15:15:01'),(120,236,'DEMO-236',1,'S,M,L,XL',629000,16,1,'2026-09-27 15:15:01'),(121,237,'DEMO-237',2,'S,M,L,XL',689000,17,1,'2026-09-27 15:15:01'),(122,238,'DEMO-238',3,'Free Size',749000,18,1,'2026-09-27 15:15:01'),(123,239,'DEMO-239',4,'S,M,L,XL',809000,19,1,'2026-09-27 15:15:01'),(124,240,'DEMO-240',5,'S,M,L,XL',869000,20,1,'2026-09-27 15:15:01'),(125,241,'DEMO-241',6,'29,30,31,32,33',929000,21,1,'2026-09-27 15:15:01'),(126,242,'DEMO-242',7,'29,30,31,32,33',989000,22,1,'2026-09-27 15:15:01'),(127,243,'DEMO-243',8,'S,M,L,XL',1049000,23,1,'2026-09-27 15:15:01'),(128,244,'DEMO-244',1,'S,M,L,XL',1109000,24,1,'2026-09-27 15:15:01'),(129,245,'DEMO-245',2,'Free Size',1169000,25,1,'2026-09-27 15:15:01'),(130,246,'DEMO-246',3,'S,M,L,XL',1229000,26,1,'2026-09-27 15:15:01'),(131,247,'DEMO-247',4,'S,M,L,XL',1289000,27,1,'2026-09-27 15:15:01');
/*!40000 ALTER TABLE `product_variants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `products` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(200) NOT NULL,
  `category_id` int(11) NOT NULL,
  `gender` enum('Nam','Nữ','Unisex') NOT NULL,
  `color_id` int(11) NOT NULL,
  `price` decimal(12,0) NOT NULL,
  `size` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `stock` int(11) DEFAULT 0,
  `status` tinyint(4) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `category_id` (`category_id`),
  KEY `color_id` (`color_id`),
  KEY `idx_product_price` (`price`),
  KEY `idx_product_gender` (`gender`),
  KEY `idx_product_status` (`status`),
  CONSTRAINT `products_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`),
  CONSTRAINT `products_ibfk_2` FOREIGN KEY (`color_id`) REFERENCES `colors` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=275 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (1,'Áo thun nam Basic',1,'Nam',1,199000,'S,M,L,XL','Áo thun cotton mềm, kiểu basic dễ phối đồ.',25,1,'2026-09-26 15:05:07'),(2,'Áo sơ mi nam công sở',1,'Nam',2,399000,'M,L,XL','Áo sơ mi lịch sự, phù hợp đi học và đi làm.',18,1,'2026-09-26 15:05:07'),(3,'Áo polo nam Classic',1,'Nam',3,329000,'M,L,XL,XXL','Áo polo nam trẻ trung, chất liệu thoáng mát.',22,1,'2026-09-26 15:05:07'),(4,'Áo thun nam Oversize',1,'Nam',5,279000,'M,L,XL','Kiểu oversize năng động, phù hợp đi chơi.',20,1,'2026-09-26 15:05:07'),(5,'Áo hoodie nữ',2,'Nữ',4,449000,'S,M,L,XL','Hoodie nữ phong cách trẻ trung, giữ ấm tốt.',15,1,'2026-09-26 15:05:07'),(6,'Áo kiểu nữ thanh lịch',2,'Nữ',2,359000,'S,M,L','Áo nữ thanh lịch phù hợp công sở.',14,1,'2026-09-26 15:05:07'),(7,'Áo croptop nữ',2,'Nữ',4,299000,'S,M,L','Croptop trẻ trung, phù hợp phong cách năng động.',19,1,'2026-09-26 15:05:07'),(8,'Quần jean nam Slim Fit',3,'Nam',3,499000,'29,30,31,32,33','Quần jean nam dáng slim fit, dễ phối áo.',12,1,'2026-09-26 15:05:07'),(9,'Quần kaki nam',3,'Nam',7,429000,'29,30,31,32,33','Quần kaki nam lịch sự và thoải mái.',16,1,'2026-09-26 15:05:07'),(10,'Quần short nam',3,'Nam',5,259000,'M,L,XL','Quần short nam thích hợp đi chơi và du lịch.',24,1,'2026-09-26 15:05:07'),(11,'Quần jean nữ Skinny',4,'Nữ',3,459000,'26,27,28,29,30','Quần jean nữ dáng skinny tôn dáng.',13,1,'2026-09-26 15:05:07'),(12,'Quần ống rộng nữ',4,'Nữ',2,399000,'S,M,L','Quần ống rộng phong cách hiện đại.',17,1,'2026-09-26 15:05:07'),(13,'Váy nữ công sở',5,'Nữ',1,599000,'S,M,L','Váy công sở thanh lịch, thiết kế đơn giản.',10,1,'2026-09-26 15:05:07'),(14,'Váy hoa nữ',5,'Nữ',4,529000,'S,M,L','Váy hoa nữ nhẹ nhàng, phù hợp đi chơi.',9,1,'2026-09-26 15:05:07'),(15,'Váy dự tiệc',5,'Nữ',8,899000,'S,M,L','Đầm dự tiệc sang trọng, kiểu dáng nổi bật.',7,1,'2026-09-26 15:05:07'),(16,'Áo khoác Bomber',6,'Unisex',5,699000,'M,L,XL','Áo khoác bomber unisex phong cách hiện đại.',11,1,'2026-09-26 15:05:07'),(17,'Áo khoác Denim',6,'Unisex',3,649000,'M,L,XL','Áo khoác denim dễ phối với nhiều trang phục.',13,1,'2026-09-26 15:05:07'),(18,'Áo khoác nữ dáng dài',6,'Nữ',7,799000,'S,M,L','Áo khoác dáng dài thanh lịch.',8,1,'2026-09-26 15:05:07'),(19,'Mũ lưỡi trai',7,'Unisex',1,149000,'Free Size','Mũ lưỡi trai đơn giản, dễ phối đồ.',30,1,'2026-09-26 15:05:07'),(20,'Túi tote thời trang',7,'Nữ',4,189000,'Free Size','Túi tote tiện dụng cho đi học và đi chơi.',27,1,'2026-09-26 15:05:07'),(148,'Mẫu demo 001 - Áo nam',1,'Nam',1,149000,'S,M,L,XL','Sản phẩm mẫu số 001, thiết kế thời trang dễ phối đồ.',6,1,'2026-09-27 15:15:01'),(149,'Mẫu demo 002 - Áo nữ',2,'Nữ',2,209000,'S,M,L,XL','Sản phẩm mẫu số 002, thiết kế thời trang dễ phối đồ.',7,1,'2026-09-27 15:15:01'),(150,'Mẫu demo 003 - Quần nam',3,'Nam',3,269000,'29,30,31,32,33','Sản phẩm mẫu số 003, thiết kế thời trang dễ phối đồ.',8,1,'2026-09-27 15:15:01'),(151,'Mẫu demo 004 - Quần nữ',4,'Nữ',4,329000,'29,30,31,32,33','Sản phẩm mẫu số 004, thiết kế thời trang dễ phối đồ.',9,1,'2026-09-27 15:15:01'),(152,'Mẫu demo 005 - Váy nữ',5,'Nữ',5,389000,'S,M,L,XL','Sản phẩm mẫu số 005, thiết kế thời trang dễ phối đồ.',10,1,'2026-09-27 15:15:01'),(153,'Mẫu demo 006 - Áo khoác',6,'Unisex',6,449000,'S,M,L,XL','Sản phẩm mẫu số 006, thiết kế thời trang dễ phối đồ.',11,1,'2026-09-27 15:15:01'),(154,'Mẫu demo 007 - Phụ kiện',7,'Unisex',7,509000,'Free Size','Sản phẩm mẫu số 007, thiết kế thời trang dễ phối đồ.',12,1,'2026-09-27 15:15:01'),(155,'Mẫu demo 008 - Áo nam',1,'Nam',8,569000,'S,M,L,XL','Sản phẩm mẫu số 008, thiết kế thời trang dễ phối đồ.',13,1,'2026-09-27 15:15:01'),(156,'Mẫu demo 009 - Áo nữ',2,'Nữ',1,629000,'S,M,L,XL','Sản phẩm mẫu số 009, thiết kế thời trang dễ phối đồ.',14,1,'2026-09-27 15:15:01'),(157,'Mẫu demo 010 - Quần nam',3,'Nam',2,689000,'29,30,31,32,33','Sản phẩm mẫu số 010, thiết kế thời trang dễ phối đồ.',15,1,'2026-09-27 15:15:01'),(158,'Mẫu demo 011 - Quần nữ',4,'Nữ',3,749000,'29,30,31,32,33','Sản phẩm mẫu số 011, thiết kế thời trang dễ phối đồ.',16,1,'2026-09-27 15:15:01'),(159,'Mẫu demo 012 - Váy nữ',5,'Nữ',4,809000,'S,M,L,XL','Sản phẩm mẫu số 012, thiết kế thời trang dễ phối đồ.',17,1,'2026-09-27 15:15:01'),(160,'Mẫu demo 013 - Áo khoác',6,'Unisex',5,869000,'S,M,L,XL','Sản phẩm mẫu số 013, thiết kế thời trang dễ phối đồ.',18,1,'2026-09-27 15:15:01'),(161,'Mẫu demo 014 - Phụ kiện',7,'Unisex',6,929000,'Free Size','Sản phẩm mẫu số 014, thiết kế thời trang dễ phối đồ.',19,1,'2026-09-27 15:15:01'),(162,'Mẫu demo 015 - Áo nam',1,'Nam',7,989000,'S,M,L,XL','Sản phẩm mẫu số 015, thiết kế thời trang dễ phối đồ.',20,1,'2026-09-27 15:15:01'),(163,'Mẫu demo 016 - Áo nữ',2,'Nữ',8,1049000,'S,M,L,XL','Sản phẩm mẫu số 016, thiết kế thời trang dễ phối đồ.',21,1,'2026-09-27 15:15:01'),(164,'Mẫu demo 017 - Quần nam',3,'Nam',1,1109000,'29,30,31,32,33','Sản phẩm mẫu số 017, thiết kế thời trang dễ phối đồ.',22,1,'2026-09-27 15:15:01'),(165,'Mẫu demo 018 - Quần nữ',4,'Nữ',2,1169000,'29,30,31,32,33','Sản phẩm mẫu số 018, thiết kế thời trang dễ phối đồ.',23,1,'2026-09-27 15:15:01'),(166,'Mẫu demo 019 - Váy nữ',5,'Nữ',3,1229000,'S,M,L,XL','Sản phẩm mẫu số 019, thiết kế thời trang dễ phối đồ.',24,1,'2026-09-27 15:15:01'),(167,'Mẫu demo 020 - Áo khoác',6,'Unisex',4,1289000,'S,M,L,XL','Sản phẩm mẫu số 020, thiết kế thời trang dễ phối đồ.',25,1,'2026-09-27 15:15:01'),(168,'Mẫu demo 021 - Phụ kiện',7,'Unisex',5,149000,'Free Size','Sản phẩm mẫu số 021, thiết kế thời trang dễ phối đồ.',26,1,'2026-09-27 15:15:01'),(169,'Mẫu demo 022 - Áo nam',1,'Nam',6,209000,'S,M,L,XL','Sản phẩm mẫu số 022, thiết kế thời trang dễ phối đồ.',27,1,'2026-09-27 15:15:01'),(170,'Mẫu demo 023 - Áo nữ',2,'Nữ',7,269000,'S,M,L,XL','Sản phẩm mẫu số 023, thiết kế thời trang dễ phối đồ.',28,1,'2026-09-27 15:15:01'),(171,'Mẫu demo 024 - Quần nam',3,'Nam',8,329000,'29,30,31,32,33','Sản phẩm mẫu số 024, thiết kế thời trang dễ phối đồ.',29,1,'2026-09-27 15:15:01'),(172,'Mẫu demo 025 - Quần nữ',4,'Nữ',1,389000,'29,30,31,32,33','Sản phẩm mẫu số 025, thiết kế thời trang dễ phối đồ.',30,1,'2026-09-27 15:15:01'),(173,'Mẫu demo 026 - Váy nữ',5,'Nữ',2,449000,'S,M,L,XL','Sản phẩm mẫu số 026, thiết kế thời trang dễ phối đồ.',5,1,'2026-09-27 15:15:01'),(174,'Mẫu demo 027 - Áo khoác',6,'Unisex',3,509000,'S,M,L,XL','Sản phẩm mẫu số 027, thiết kế thời trang dễ phối đồ.',6,1,'2026-09-27 15:15:01'),(175,'Mẫu demo 028 - Phụ kiện',7,'Unisex',4,569000,'Free Size','Sản phẩm mẫu số 028, thiết kế thời trang dễ phối đồ.',7,1,'2026-09-27 15:15:01'),(176,'Mẫu demo 029 - Áo nam',1,'Nam',5,629000,'S,M,L,XL','Sản phẩm mẫu số 029, thiết kế thời trang dễ phối đồ.',8,1,'2026-09-27 15:15:01'),(177,'Mẫu demo 030 - Áo nữ',2,'Nữ',6,689000,'S,M,L,XL','Sản phẩm mẫu số 030, thiết kế thời trang dễ phối đồ.',9,1,'2026-09-27 15:15:01'),(178,'Mẫu demo 031 - Quần nam',3,'Nam',7,749000,'29,30,31,32,33','Sản phẩm mẫu số 031, thiết kế thời trang dễ phối đồ.',10,1,'2026-09-27 15:15:01'),(179,'Mẫu demo 032 - Quần nữ',4,'Nữ',8,809000,'29,30,31,32,33','Sản phẩm mẫu số 032, thiết kế thời trang dễ phối đồ.',11,1,'2026-09-27 15:15:01'),(180,'Mẫu demo 033 - Váy nữ',5,'Nữ',1,869000,'S,M,L,XL','Sản phẩm mẫu số 033, thiết kế thời trang dễ phối đồ.',12,1,'2026-09-27 15:15:01'),(181,'Mẫu demo 034 - Áo khoác',6,'Unisex',2,929000,'S,M,L,XL','Sản phẩm mẫu số 034, thiết kế thời trang dễ phối đồ.',13,1,'2026-09-27 15:15:01'),(182,'Mẫu demo 035 - Phụ kiện',7,'Unisex',3,989000,'Free Size','Sản phẩm mẫu số 035, thiết kế thời trang dễ phối đồ.',14,1,'2026-09-27 15:15:01'),(183,'Mẫu demo 036 - Áo nam',1,'Nam',4,1049000,'S,M,L,XL','Sản phẩm mẫu số 036, thiết kế thời trang dễ phối đồ.',15,1,'2026-09-27 15:15:01'),(184,'Mẫu demo 037 - Áo nữ',2,'Nữ',5,1109000,'S,M,L,XL','Sản phẩm mẫu số 037, thiết kế thời trang dễ phối đồ.',16,1,'2026-09-27 15:15:01'),(185,'Mẫu demo 038 - Quần nam',3,'Nam',6,1169000,'29,30,31,32,33','Sản phẩm mẫu số 038, thiết kế thời trang dễ phối đồ.',17,1,'2026-09-27 15:15:01'),(186,'Mẫu demo 039 - Quần nữ',4,'Nữ',7,1229000,'29,30,31,32,33','Sản phẩm mẫu số 039, thiết kế thời trang dễ phối đồ.',18,1,'2026-09-27 15:15:01'),(187,'Mẫu demo 040 - Váy nữ',5,'Nữ',8,1289000,'S,M,L,XL','Sản phẩm mẫu số 040, thiết kế thời trang dễ phối đồ.',19,1,'2026-09-27 15:15:01'),(188,'Mẫu demo 041 - Áo khoác',6,'Unisex',1,149000,'S,M,L,XL','Sản phẩm mẫu số 041, thiết kế thời trang dễ phối đồ.',20,1,'2026-09-27 15:15:01'),(189,'Mẫu demo 042 - Phụ kiện',7,'Unisex',2,209000,'Free Size','Sản phẩm mẫu số 042, thiết kế thời trang dễ phối đồ.',21,1,'2026-09-27 15:15:01'),(190,'Mẫu demo 043 - Áo nam',1,'Nam',3,269000,'S,M,L,XL','Sản phẩm mẫu số 043, thiết kế thời trang dễ phối đồ.',22,1,'2026-09-27 15:15:01'),(191,'Mẫu demo 044 - Áo nữ',2,'Nữ',4,329000,'S,M,L,XL','Sản phẩm mẫu số 044, thiết kế thời trang dễ phối đồ.',23,1,'2026-09-27 15:15:01'),(192,'Mẫu demo 045 - Quần nam',3,'Nam',5,389000,'29,30,31,32,33','Sản phẩm mẫu số 045, thiết kế thời trang dễ phối đồ.',24,1,'2026-09-27 15:15:01'),(193,'Mẫu demo 046 - Quần nữ',4,'Nữ',6,449000,'29,30,31,32,33','Sản phẩm mẫu số 046, thiết kế thời trang dễ phối đồ.',25,1,'2026-09-27 15:15:01'),(194,'Mẫu demo 047 - Váy nữ',5,'Nữ',7,509000,'S,M,L,XL','Sản phẩm mẫu số 047, thiết kế thời trang dễ phối đồ.',26,1,'2026-09-27 15:15:01'),(195,'Mẫu demo 048 - Áo khoác',6,'Unisex',8,569000,'S,M,L,XL','Sản phẩm mẫu số 048, thiết kế thời trang dễ phối đồ.',27,1,'2026-09-27 15:15:01'),(196,'Mẫu demo 049 - Phụ kiện',7,'Unisex',1,629000,'Free Size','Sản phẩm mẫu số 049, thiết kế thời trang dễ phối đồ.',28,1,'2026-09-27 15:15:01'),(197,'Mẫu demo 050 - Áo nam',1,'Nam',2,689000,'S,M,L,XL','Sản phẩm mẫu số 050, thiết kế thời trang dễ phối đồ.',29,1,'2026-09-27 15:15:01'),(198,'Mẫu demo 051 - Áo nữ',2,'Nữ',3,749000,'S,M,L,XL','Sản phẩm mẫu số 051, thiết kế thời trang dễ phối đồ.',30,1,'2026-09-27 15:15:01'),(199,'Mẫu demo 052 - Quần nam',3,'Nam',4,809000,'29,30,31,32,33','Sản phẩm mẫu số 052, thiết kế thời trang dễ phối đồ.',5,1,'2026-09-27 15:15:01'),(200,'Mẫu demo 053 - Quần nữ',4,'Nữ',5,869000,'29,30,31,32,33','Sản phẩm mẫu số 053, thiết kế thời trang dễ phối đồ.',6,1,'2026-09-27 15:15:01'),(201,'Mẫu demo 054 - Váy nữ',5,'Nữ',6,929000,'S,M,L,XL','Sản phẩm mẫu số 054, thiết kế thời trang dễ phối đồ.',7,1,'2026-09-27 15:15:01'),(202,'Mẫu demo 055 - Áo khoác',6,'Unisex',7,989000,'S,M,L,XL','Sản phẩm mẫu số 055, thiết kế thời trang dễ phối đồ.',8,1,'2026-09-27 15:15:01'),(203,'Mẫu demo 056 - Phụ kiện',7,'Unisex',8,1049000,'Free Size','Sản phẩm mẫu số 056, thiết kế thời trang dễ phối đồ.',9,1,'2026-09-27 15:15:01'),(204,'Mẫu demo 057 - Áo nam',1,'Nam',1,1109000,'S,M,L,XL','Sản phẩm mẫu số 057, thiết kế thời trang dễ phối đồ.',10,1,'2026-09-27 15:15:01'),(205,'Mẫu demo 058 - Áo nữ',2,'Nữ',2,1169000,'S,M,L,XL','Sản phẩm mẫu số 058, thiết kế thời trang dễ phối đồ.',11,1,'2026-09-27 15:15:01'),(206,'Mẫu demo 059 - Quần nam',3,'Nam',3,1229000,'29,30,31,32,33','Sản phẩm mẫu số 059, thiết kế thời trang dễ phối đồ.',12,1,'2026-09-27 15:15:01'),(207,'Mẫu demo 060 - Quần nữ',4,'Nữ',4,1289000,'29,30,31,32,33','Sản phẩm mẫu số 060, thiết kế thời trang dễ phối đồ.',13,1,'2026-09-27 15:15:01'),(208,'Mẫu demo 061 - Váy nữ',5,'Nữ',5,149000,'S,M,L,XL','Sản phẩm mẫu số 061, thiết kế thời trang dễ phối đồ.',14,1,'2026-09-27 15:15:01'),(209,'Mẫu demo 062 - Áo khoác',6,'Unisex',6,209000,'S,M,L,XL','Sản phẩm mẫu số 062, thiết kế thời trang dễ phối đồ.',15,1,'2026-09-27 15:15:01'),(210,'Mẫu demo 063 - Phụ kiện',7,'Unisex',7,269000,'Free Size','Sản phẩm mẫu số 063, thiết kế thời trang dễ phối đồ.',16,1,'2026-09-27 15:15:01'),(211,'Mẫu demo 064 - Áo nam',1,'Nam',8,329000,'S,M,L,XL','Sản phẩm mẫu số 064, thiết kế thời trang dễ phối đồ.',17,1,'2026-09-27 15:15:01'),(212,'Mẫu demo 065 - Áo nữ',2,'Nữ',1,389000,'S,M,L,XL','Sản phẩm mẫu số 065, thiết kế thời trang dễ phối đồ.',18,1,'2026-09-27 15:15:01'),(213,'Mẫu demo 066 - Quần nam',3,'Nam',2,449000,'29,30,31,32,33','Sản phẩm mẫu số 066, thiết kế thời trang dễ phối đồ.',19,1,'2026-09-27 15:15:01'),(214,'Mẫu demo 067 - Quần nữ',4,'Nữ',3,509000,'29,30,31,32,33','Sản phẩm mẫu số 067, thiết kế thời trang dễ phối đồ.',20,1,'2026-09-27 15:15:01'),(215,'Mẫu demo 068 - Váy nữ',5,'Nữ',4,569000,'S,M,L,XL','Sản phẩm mẫu số 068, thiết kế thời trang dễ phối đồ.',21,1,'2026-09-27 15:15:01'),(216,'Mẫu demo 069 - Áo khoác',6,'Unisex',5,629000,'S,M,L,XL','Sản phẩm mẫu số 069, thiết kế thời trang dễ phối đồ.',22,1,'2026-09-27 15:15:01'),(217,'Mẫu demo 070 - Phụ kiện',7,'Unisex',6,689000,'Free Size','Sản phẩm mẫu số 070, thiết kế thời trang dễ phối đồ.',23,1,'2026-09-27 15:15:01'),(218,'Mẫu demo 071 - Áo nam',1,'Nam',7,749000,'S,M,L,XL','Sản phẩm mẫu số 071, thiết kế thời trang dễ phối đồ.',24,1,'2026-09-27 15:15:01'),(219,'Mẫu demo 072 - Áo nữ',2,'Nữ',8,809000,'S,M,L,XL','Sản phẩm mẫu số 072, thiết kế thời trang dễ phối đồ.',25,1,'2026-09-27 15:15:01'),(220,'Mẫu demo 073 - Quần nam',3,'Nam',1,869000,'29,30,31,32,33','Sản phẩm mẫu số 073, thiết kế thời trang dễ phối đồ.',26,1,'2026-09-27 15:15:01'),(221,'Mẫu demo 074 - Quần nữ',4,'Nữ',2,929000,'29,30,31,32,33','Sản phẩm mẫu số 074, thiết kế thời trang dễ phối đồ.',27,1,'2026-09-27 15:15:01'),(222,'Mẫu demo 075 - Váy nữ',5,'Nữ',3,989000,'S,M,L,XL','Sản phẩm mẫu số 075, thiết kế thời trang dễ phối đồ.',28,1,'2026-09-27 15:15:01'),(223,'Mẫu demo 076 - Áo khoác',6,'Unisex',4,1049000,'S,M,L,XL','Sản phẩm mẫu số 076, thiết kế thời trang dễ phối đồ.',29,1,'2026-09-27 15:15:01'),(224,'Mẫu demo 077 - Phụ kiện',7,'Unisex',5,1109000,'Free Size','Sản phẩm mẫu số 077, thiết kế thời trang dễ phối đồ.',30,1,'2026-09-27 15:15:01'),(225,'Mẫu demo 078 - Áo nam',1,'Nam',6,1169000,'S,M,L,XL','Sản phẩm mẫu số 078, thiết kế thời trang dễ phối đồ.',5,1,'2026-09-27 15:15:01'),(226,'Mẫu demo 079 - Áo nữ',2,'Nữ',7,1229000,'S,M,L,XL','Sản phẩm mẫu số 079, thiết kế thời trang dễ phối đồ.',6,1,'2026-09-27 15:15:01'),(227,'Mẫu demo 080 - Quần nam',3,'Nam',8,1289000,'29,30,31,32,33','Sản phẩm mẫu số 080, thiết kế thời trang dễ phối đồ.',7,1,'2026-09-27 15:15:01'),(228,'Mẫu demo 081 - Quần nữ',4,'Nữ',1,149000,'29,30,31,32,33','Sản phẩm mẫu số 081, thiết kế thời trang dễ phối đồ.',8,1,'2026-09-27 15:15:01'),(229,'Mẫu demo 082 - Váy nữ',5,'Nữ',2,209000,'S,M,L,XL','Sản phẩm mẫu số 082, thiết kế thời trang dễ phối đồ.',9,1,'2026-09-27 15:15:01'),(230,'Mẫu demo 083 - Áo khoác',6,'Unisex',3,269000,'S,M,L,XL','Sản phẩm mẫu số 083, thiết kế thời trang dễ phối đồ.',10,1,'2026-09-27 15:15:01'),(231,'Mẫu demo 084 - Phụ kiện',7,'Unisex',4,329000,'Free Size','Sản phẩm mẫu số 084, thiết kế thời trang dễ phối đồ.',11,1,'2026-09-27 15:15:01'),(232,'Mẫu demo 085 - Áo nam',1,'Nam',5,389000,'S,M,L,XL','Sản phẩm mẫu số 085, thiết kế thời trang dễ phối đồ.',12,1,'2026-09-27 15:15:01'),(233,'Mẫu demo 086 - Áo nữ',2,'Nữ',6,449000,'S,M,L,XL','Sản phẩm mẫu số 086, thiết kế thời trang dễ phối đồ.',13,1,'2026-09-27 15:15:01'),(234,'Mẫu demo 087 - Quần nam',3,'Nam',7,509000,'29,30,31,32,33','Sản phẩm mẫu số 087, thiết kế thời trang dễ phối đồ.',14,1,'2026-09-27 15:15:01'),(235,'Mẫu demo 088 - Quần nữ',4,'Nữ',8,569000,'29,30,31,32,33','Sản phẩm mẫu số 088, thiết kế thời trang dễ phối đồ.',15,1,'2026-09-27 15:15:01'),(236,'Mẫu demo 089 - Váy nữ',5,'Nữ',1,629000,'S,M,L,XL','Sản phẩm mẫu số 089, thiết kế thời trang dễ phối đồ.',16,1,'2026-09-27 15:15:01'),(237,'Mẫu demo 090 - Áo khoác',6,'Unisex',2,689000,'S,M,L,XL','Sản phẩm mẫu số 090, thiết kế thời trang dễ phối đồ.',17,1,'2026-09-27 15:15:01'),(238,'Mẫu demo 091 - Phụ kiện',7,'Unisex',3,749000,'Free Size','Sản phẩm mẫu số 091, thiết kế thời trang dễ phối đồ.',18,1,'2026-09-27 15:15:01'),(239,'Mẫu demo 092 - Áo nam',1,'Nam',4,809000,'S,M,L,XL','Sản phẩm mẫu số 092, thiết kế thời trang dễ phối đồ.',19,1,'2026-09-27 15:15:01'),(240,'Mẫu demo 093 - Áo nữ',2,'Nữ',5,869000,'S,M,L,XL','Sản phẩm mẫu số 093, thiết kế thời trang dễ phối đồ.',20,1,'2026-09-27 15:15:01'),(241,'Mẫu demo 094 - Quần nam',3,'Nam',6,929000,'29,30,31,32,33','Sản phẩm mẫu số 094, thiết kế thời trang dễ phối đồ.',21,1,'2026-09-27 15:15:01'),(242,'Mẫu demo 095 - Quần nữ',4,'Nữ',7,989000,'29,30,31,32,33','Sản phẩm mẫu số 095, thiết kế thời trang dễ phối đồ.',22,1,'2026-09-27 15:15:01'),(243,'Mẫu demo 096 - Váy nữ',5,'Nữ',8,1049000,'S,M,L,XL','Sản phẩm mẫu số 096, thiết kế thời trang dễ phối đồ.',23,1,'2026-09-27 15:15:01'),(244,'Mẫu demo 097 - Áo khoác',6,'Unisex',1,1109000,'S,M,L,XL','Sản phẩm mẫu số 097, thiết kế thời trang dễ phối đồ.',24,1,'2026-09-27 15:15:01'),(245,'Mẫu demo 098 - Phụ kiện',7,'Unisex',2,1169000,'Free Size','Sản phẩm mẫu số 098, thiết kế thời trang dễ phối đồ.',25,1,'2026-09-27 15:15:01'),(246,'Mẫu demo 099 - Áo nam',1,'Nam',3,1229000,'S,M,L,XL','Sản phẩm mẫu số 099, thiết kế thời trang dễ phối đồ.',26,1,'2026-09-27 15:15:01'),(247,'Mẫu demo 100 - Áo nữ',2,'Nữ',4,1289000,'S,M,L,XL','Sản phẩm mẫu số 100, thiết kế thời trang dễ phối đồ.',27,1,'2026-09-27 15:15:01');
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shipping_rules`
--

DROP TABLE IF EXISTS `shipping_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `shipping_rules` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `area` varchar(100) NOT NULL,
  `fee` decimal(12,0) NOT NULL DEFAULT 0,
  `free_shipping_min` decimal(12,0) DEFAULT NULL,
  `min_days` tinyint(4) NOT NULL,
  `max_days` tinyint(4) NOT NULL,
  `active` tinyint(4) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `area` (`area`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shipping_rules`
--

LOCK TABLES `shipping_rules` WRITE;
/*!40000 ALTER TABLE `shipping_rules` DISABLE KEYS */;
INSERT INTO `shipping_rules` VALUES (1,'Nội thành',25000,500000,1,2,1),(2,'Ngoại tỉnh',35000,500000,3,5,1);
/*!40000 ALTER TABLE `shipping_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `size_chart`
--

DROP TABLE IF EXISTS `size_chart`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `size_chart` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `gender` enum('Nam','Nữ','Unisex') NOT NULL,
  `size` varchar(20) NOT NULL,
  `min_height_cm` decimal(5,1) NOT NULL,
  `max_height_cm` decimal(5,1) NOT NULL,
  `min_weight_kg` decimal(5,1) NOT NULL,
  `max_weight_kg` decimal(5,1) NOT NULL,
  `note` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_size_chart` (`gender`,`size`),
  KEY `idx_size_gender` (`gender`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `size_chart`
--

LOCK TABLES `size_chart` WRITE;
/*!40000 ALTER TABLE `size_chart` DISABLE KEYS */;
INSERT INTO `size_chart` VALUES (1,'Nam','S',155.0,165.0,45.0,55.0,'Dáng người nhỏ hoặc gọn'),(2,'Nam','M',160.0,172.0,55.0,65.0,'Dáng người trung bình'),(3,'Nam','L',168.0,178.0,65.0,75.0,'Dáng người cao vừa'),(4,'Nam','XL',175.0,185.0,75.0,90.0,'Dáng người lớn hoặc cao'),(5,'Nam','XXL',180.0,195.0,90.0,110.0,'Dáng người cao và lớn'),(6,'Nữ','S',150.0,160.0,40.0,50.0,'Dáng người nhỏ hoặc gọn'),(7,'Nữ','M',155.0,165.0,50.0,60.0,'Dáng người trung bình'),(8,'Nữ','L',160.0,172.0,60.0,70.0,'Dáng người cao vừa'),(9,'Nữ','XL',165.0,180.0,70.0,85.0,'Dáng người lớn hoặc cao'),(10,'Unisex','S',150.0,165.0,45.0,55.0,'Dáng người nhỏ hoặc gọn'),(11,'Unisex','M',160.0,172.0,55.0,68.0,'Dáng người trung bình'),(12,'Unisex','L',168.0,180.0,68.0,80.0,'Dáng người cao vừa'),(13,'Unisex','XL',175.0,190.0,80.0,100.0,'Dáng người lớn hoặc cao');
/*!40000 ALTER TABLE `size_chart` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `store_faqs`
--

DROP TABLE IF EXISTS `store_faqs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `store_faqs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category` varchar(50) NOT NULL,
  `sample_question` varchar(255) NOT NULL,
  `keywords` varchar(500) NOT NULL,
  `answer` text NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sample_question` (`sample_question`),
  KEY `idx_store_faq_category` (`category`)
) ENGINE=InnoDB AUTO_INCREMENT=130 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `store_faqs`
--

LOCK TABLES `store_faqs` WRITE;
/*!40000 ALTER TABLE `store_faqs` DISABLE KEYS */;
INSERT INTO `store_faqs` VALUES (1,'shipping','Shop có giao hàng không?','shop co giao hang khong|giao hang|co ship khong|shop co ship|ship','Shop có hỗ trợ giao hàng. Bạn cho mình biết sản phẩm cần mua để được tư vấn tiếp nhé.'),(2,'shipping','Shop có ship không?','shop co ship khong|ship khong|van chuyen khong|ship','Shop có hỗ trợ giao hàng. Bạn cho mình biết sản phẩm cần mua để được tư vấn tiếp nhé.'),(3,'shipping_fee','Phí giao hàng là bao nhiêu?','phi giao hang la bao nhieu|phi giao hang|phi ship|cuoc van chuyen|tien ship|phi','Thông tin mẫu của đồ án: phí giao hàng là 25.000đ nội thành, 35.000đ ngoại tỉnh, miễn phí đơn từ 500.000đ. Hãy thay mức phí này bằng chính sách thật của shop trước khi sử dụng.'),(4,'shipping_fee','Phí ship bao nhiêu?','phi ship bao nhieu|phi ship|tien ship|cuoc ship|phi','Thông tin mẫu của đồ án: phí giao hàng là 25.000đ nội thành, 35.000đ ngoại tỉnh, miễn phí đơn từ 500.000đ. Hãy thay mức phí này bằng chính sách thật của shop trước khi sử dụng.'),(5,'shipping_time','Thời gian giao hàng bao lâu?','thoi gian giao hang bao lau|giao hang mat bao lau|giao hang bao lau|bao lau nhan hang','Thông tin mẫu của đồ án: đơn nội thành giao khoảng 1–2 ngày làm việc, đơn tỉnh khoảng 3–5 ngày làm việc. Thời gian có thể thay đổi theo khu vực.'),(6,'shipping_time','Đơn hàng khi nào tới?','don hang khi nao toi|khi nao nhan duoc hang|bao gio nhan hang|thoi gian nhan hang','Thông tin mẫu của đồ án: đơn nội thành giao khoảng 1–2 ngày làm việc, đơn tỉnh khoảng 3–5 ngày làm việc. Thời gian có thể thay đổi theo khu vực.'),(7,'shipping_area','Shop có giao hàng toàn quốc không?','giao hang toan quoc|ship toan quoc|giao toan quoc|pham vi giao hang','Thông tin mẫu của đồ án: shop nhận giao hàng trên toàn quốc. Hãy xác nhận lại phạm vi giao hàng thật của shop.'),(8,'shipping_area','Shop có giao hàng hỏa tốc không?','giao hang hoa toc|ship hoa toc|giao nhanh|hoa toc','Thông tin giao hàng hỏa tốc chưa được cập nhật. Bạn vui lòng liên hệ shop để xác nhận dịch vụ hiện có.'),(9,'order_tracking','Tôi kiểm tra đơn hàng ở đâu?','kiem tra don hang|tra cuu don hang|theo doi don hang|trang thai don hang','Chatbot hiện chưa kết nối chức năng tra cứu đơn hàng. Bạn vui lòng liên hệ shop và cung cấp mã đơn để được hỗ trợ.'),(10,'shipping_address','Tôi muốn đổi địa chỉ giao hàng','doi dia chi giao hang|sua dia chi nhan hang|thay doi dia chi giao hang','Chatbot chưa hỗ trợ tự sửa địa chỉ đơn hàng. Bạn vui lòng liên hệ shop sớm và cung cấp mã đơn.'),(11,'payment','Shop hỗ trợ thanh toán bằng cách nào?','shop ho tro thanh toan bang cach nao|phuong thuc thanh toan|thanh toan nhu the nao','Shop hiện hỗ trợ thanh toán khi nhận hàng và chuyển khoản ngân hàng.'),(12,'payment','Có được thanh toán khi nhận hàng không?','thanh toan khi nhan hang|cod|tra tien khi nhan hang|nhan hang moi tra tien','Có. Shop hỗ trợ thanh toán khi nhận hàng.'),(13,'payment','Shop có nhận chuyển khoản không?','chuyen khoan|thanh toan qua ngan hang|so tai khoan','Có. Shop hỗ trợ chuyển khoản ngân hàng. Vui lòng liên hệ shop để nhận thông tin chuyển khoản chính xác.'),(14,'payment','Shop có thanh toán bằng thẻ không?','thanh toan bang the|the tin dung|the ngan hang|visa|mastercard','Thông tin thanh toán bằng thẻ chưa được cập nhật. Bạn vui lòng liên hệ shop để xác nhận.'),(15,'payment','Shop có hỗ trợ trả góp không?','tra gop|mua tra gop|thanh toan tra gop','Thông tin trả góp chưa được cập nhật trong hệ thống. Bạn vui lòng liên hệ shop để xác nhận.'),(16,'payment','Tôi có thể trả tiền sau khi nhận hàng không?','tra tien sau khi nhan hang|nhan hang roi thanh toan|thanh toan sau','Có. Shop hiện có hình thức thanh toán khi nhận hàng.'),(17,'payment','Shop có xuất hóa đơn không?','xuat hoa don|hoa don mua hang|hoa don VAT|hoa don gia tri gia tang','Thông tin xuất hóa đơn chưa được cập nhật. Bạn vui lòng liên hệ shop để xác nhận trước khi đặt hàng.'),(18,'store_address','Cửa hàng ở đâu?','cua hang o dau|dia chi cua hang|dia chi shop|shop o dau|chi nhanh o dau','Thông tin mẫu của đồ án: cửa hàng tại 123 Nguyễn Trãi, Quận 1, TP. Hồ Chí Minh. Đây là địa chỉ minh họa, hãy thay bằng địa chỉ thật của shop.'),(19,'store_address','Địa chỉ shop là gì?','dia chi shop la gi|shop nam o dau|cua hang nam o dau|dia diem cua hang','Thông tin mẫu của đồ án: cửa hàng tại 123 Nguyễn Trãi, Quận 1, TP. Hồ Chí Minh. Đây là địa chỉ minh họa, hãy thay bằng địa chỉ thật của shop.'),(20,'store_hours','Mở cửa lúc mấy giờ?','mo cua luc may gio|gio mo cua|gio lam viec|thoi gian mo cua','Thông tin mẫu của đồ án: shop mở cửa hằng ngày từ 09:00 đến 21:00. Hãy thay bằng giờ hoạt động thật của shop.'),(21,'store_hours','Shop mở cửa ngày chủ nhật không?','shop mo cua chu nhat|cua hang mo cua chu nhat|chu nhat co lam viec khong','Theo lịch mẫu của đồ án, shop mở cửa Chủ nhật từ 09:00 đến 21:00. Hãy thay bằng lịch thật của shop.'),(22,'store_hours','Ngày lễ shop có mở cửa không?','ngay le shop co mo cua|lich nghi le|shop nghi ngay nao','Lịch ngày lễ cần được shop xác nhận, giờ hoạt động thông thường theo dữ liệu mẫu là 09:00–21:00.'),(23,'store_contact','Số điện thoại của shop là gì?','so dien thoai shop|hotline cua hang|goi shop so nao|so lien he','Số điện thoại liên hệ chưa được cập nhật trong hệ thống. Bạn vui lòng xem thông tin liên hệ chính thức của shop.'),(24,'store_contact','Shop có email không?','email cua shop|dia chi email|gui email cho shop','Email liên hệ chưa được cập nhật trong hệ thống. Bạn vui lòng xem thông tin liên hệ chính thức của shop.'),(25,'store_contact','Làm sao để liên hệ với shop?','lien he voi shop|cach lien lac cua hang|nhan vien tu van|ket noi voi shop','Kênh liên hệ của shop chưa được cập nhật trong chatbot. Bạn vui lòng xem trang thông tin chính thức của cửa hàng.'),(26,'store_contact','Shop có cửa hàng trực tiếp không?','shop co cua hang truc tiep|co the den thu do|mua truc tiep|den cua hang','Thông tin cửa hàng trực tiếp chưa được cập nhật. Bạn vui lòng liên hệ shop để xác nhận.'),(27,'return_policy','Chính sách đổi trả của shop thế nào?','chinh sach doi tra|quy dinh doi tra|doi tra nhu the nao|doi hang tra hang','Thông tin mẫu của đồ án: hỗ trợ đổi size/đổi mẫu trong 7 ngày từ khi nhận hàng nếu sản phẩm chưa qua sử dụng, còn tem nhãn và hóa đơn. Hãy thay bằng chính sách thật của shop.'),(28,'return_policy','Tôi đổi sang size khác được không?','doi sang size khac|doi size|doi kich co|doi size ao','Theo chính sách mẫu của đồ án, bạn có thể yêu cầu đổi size trong 7 ngày nếu sản phẩm chưa qua sử dụng, còn tem nhãn và hóa đơn, vui lòng liên hệ shop để kiểm tra tồn kho.'),(29,'return_policy','Thời hạn đổi trả là bao lâu?','thoi han doi tra|doi tra trong bao lau|bao nhieu ngay duoc doi|han doi hang','Thời hạn đổi trả mẫu là 7 ngày từ khi nhận hàng. Đây là dữ liệu minh họa, cần thay theo chính sách thật của shop.'),(30,'return_policy','Sản phẩm lỗi thì xử lý thế nào?','san pham bi loi|hang bi loi|loi san pham|nhan hang bi hong','Theo chính sách mẫu, hãy chụp ảnh sản phẩm và liên hệ shop trong vòng 7 ngày từ khi nhận hàng để được kiểm tra và hỗ trợ.'),(31,'return_policy','Bao lâu tôi được hoàn tiền?','bao lau duoc hoan tien|thoi gian hoan tien|khi nao nhan lai tien','Thời gian hoàn tiền tùy phương thức thanh toán, shop cần xác nhận thời hạn cụ thể. Chính sách mẫu yêu cầu liên hệ shop sau khi yêu cầu đổi trả được duyệt.'),(32,'return_policy','Tôi muốn hủy đơn hàng','huy don hang|muon huy don|cancel don hang','Chatbot chưa hỗ trợ hủy đơn tự động. Bạn vui lòng liên hệ shop sớm và cung cấp mã đơn.'),(33,'return_policy','Phí đổi trả do ai chịu?','phi doi tra|ai chiu phi ship doi hang|phi van chuyen doi tra','Theo chính sách mẫu của đồ án, shop chịu phí nếu sản phẩm lỗi, khách chịu phí nếu đổi do nhu cầu cá nhân. Hãy thay theo chính sách thật của shop.'),(34,'promotion','Shop đang có khuyến mãi gì?','shop dang co khuyen mai gi|chuong trinh khuyen mai|uu dai hien tai|giam gia hom nay','Thông tin khuyến mãi hiện chưa được cập nhật trong chatbot. Bạn vui lòng xem thông báo mới nhất từ shop.'),(35,'promotion','Shop có mã giảm giá không?','ma giam gia|voucher cua shop|ma voucher|nhap ma giam gia|voucher','Mã giảm giá chưa được cập nhật trong hệ thống. Bạn vui lòng xem chương trình ưu đãi hiện hành của shop.'),(36,'promotion','Có được miễn phí giao hàng không?','mien phi giao hang|free ship|khong mat phi ship|uu dai van chuyen','Chương trình miễn phí giao hàng chưa được cập nhật. Bạn vui lòng liên hệ shop để xác nhận điều kiện áp dụng.'),(37,'promotion','Shop có tích điểm thành viên không?','tich diem thanh vien|the thanh vien|diem thuong|uu dai thanh vien','Thông tin chương trình thành viên chưa được cập nhật. Bạn vui lòng liên hệ shop để xác nhận.'),(38,'promotion','Mua nhiều có được giảm giá không?','mua nhieu giam gia|giam gia don hang lon|uu dai mua so luong|chiet khau','Ưu đãi theo số lượng chưa được cập nhật. Bạn vui lòng liên hệ shop để được báo giá chính xác.'),(39,'product_support','Shop có ảnh sản phẩm không?','anh san pham|hinh anh san pham|xem hinh mau|cho xem anh|anh','Cơ sở dữ liệu hiện chưa lưu ảnh sản phẩm. Bạn có thể hỏi tên, màu, size hoặc mô tả của sản phẩm để chatbot tra cứu thông tin đang có.'),(40,'product_support','Tư vấn size giúp tôi','tu van size|chon size nao|size nao phu hop|tu van kich co|size','Mình có thể hỗ trợ chọn size. Bạn cho biết sản phẩm muốn mặc, giới tính, chiều cao và cân nặng nhé.'),(41,'product_support','Làm sao biết sản phẩm còn hàng?','kiem tra con hang|san pham con hang khong|ton kho san pham|con mau va size khong','Chatbot có thể kiểm tra tồn kho từ dữ liệu sản phẩm. Bạn gửi tên sản phẩm cùng màu hoặc size muốn tìm nhé.'),(42,'product_support','Làm sao đặt mua sản phẩm?','cach dat mua san pham|dat hang nhu the nao|mua hang nhu the nao|tao don hang','Chatbot hiện hỗ trợ tư vấn và tra cứu sản phẩm, chưa tạo đơn hàng tự động. Bạn vui lòng liên hệ shop để đặt mua.'),(43,'product_support','Shop có gói quà không?','goi qua|goi lam qua tang|dong goi qua tang|hop qua','Thông tin gói quà chưa được cập nhật. Bạn vui lòng liên hệ shop để xác nhận dịch vụ hiện có.');
/*!40000 ALTER TABLE `store_faqs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `store_hours`
--

DROP TABLE IF EXISTS `store_hours`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `store_hours` (
  `day_of_week` tinyint(4) NOT NULL,
  `day_name` varchar(20) NOT NULL,
  `open_time` time DEFAULT NULL,
  `close_time` time DEFAULT NULL,
  `is_closed` tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (`day_of_week`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `store_hours`
--

LOCK TABLES `store_hours` WRITE;
/*!40000 ALTER TABLE `store_hours` DISABLE KEYS */;
INSERT INTO `store_hours` VALUES (1,'Thứ 2','09:00:00','21:00:00',0),(2,'Thứ 3','09:00:00','21:00:00',0),(3,'Thứ 4','09:00:00','21:00:00',0),(4,'Thứ 5','09:00:00','21:00:00',0),(5,'Thứ 6','09:00:00','21:00:00',0),(6,'Thứ 7','09:00:00','21:00:00',0),(7,'Chủ nhật','09:00:00','21:00:00',0);
/*!40000 ALTER TABLE `store_hours` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `store_settings`
--

DROP TABLE IF EXISTS `store_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `store_settings` (
  `setting_key` varchar(80) NOT NULL,
  `setting_value` varchar(500) NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`setting_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `store_settings`
--

LOCK TABLES `store_settings` WRITE;
/*!40000 ALTER TABLE `store_settings` DISABLE KEYS */;
INSERT INTO `store_settings` VALUES ('return_condition','Sản phẩm chưa qua sử dụng, còn tem nhãn và hóa đơn','2026-09-27 14:41:03'),('return_days','7 ngày','2026-09-27 14:41:03'),('store_address','123 Nguyễn Trãi, Quận 1, TP. Hồ Chí Minh','2026-09-27 14:41:03'),('store_email','contact@fashionai.local','2026-09-27 14:41:03'),('store_name','Fashion AI Shop','2026-09-27 14:41:03'),('store_phone','0900 000 000','2026-09-27 14:41:03');
/*!40000 ALTER TABLE `store_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'fashion_chatbot'
--

--
-- Dumping routines for database 'fashion_chatbot'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-09-27 23:29:08
