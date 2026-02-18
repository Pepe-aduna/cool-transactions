CREATE DATABASE  IF NOT EXISTS `transaction_data` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `transaction_data`;
-- MySQL dump 10.13  Distrib 8.0.44, for macos15 (x86_64)
--
-- Host: localhost    Database: transaction_data
-- ------------------------------------------------------
-- Server version	8.4.4

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `account`
--

DROP TABLE IF EXISTS `account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `account` (
  `id` int NOT NULL AUTO_INCREMENT,
  `account_number` varchar(45) NOT NULL,
  `status` varchar(45) NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `account_number_UNIQUE` (`account_number`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account`
--

LOCK TABLES `account` WRITE;
/*!40000 ALTER TABLE `account` DISABLE KEYS */;
INSERT INTO `account` VALUES (1,'concentrator_def','enabled','2026-02-11 15:51:16'),(2,'account-0001','enabled','2026-02-18 10:33:10');
/*!40000 ALTER TABLE `account` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `balance`
--

DROP TABLE IF EXISTS `balance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `balance` (
  `account_number` varchar(45) NOT NULL,
  `disposable` decimal(15,2) NOT NULL,
  `locked` decimal(15,2) NOT NULL,
  `total` decimal(15,2) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`account_number`),
  UNIQUE KEY `account_number_UNIQUE` (`account_number`),
  CONSTRAINT `balance_ibfk_1` FOREIGN KEY (`account_number`) REFERENCES `account` (`account_number`),
  CONSTRAINT `fk_balance_account` FOREIGN KEY (`account_number`) REFERENCES `account` (`account_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `balance`
--

LOCK TABLES `balance` WRITE;
/*!40000 ALTER TABLE `balance` DISABLE KEYS */;
INSERT INTO `balance` VALUES ('account-0001',0.00,0.00,0.00,'2026-02-18 10:35:01','2026-02-18 10:35:01'),('concentrator_def',0.00,0.00,0.00,'2026-02-17 11:19:48','2026-02-17 11:19:48');
/*!40000 ALTER TABLE `balance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ledger`
--

DROP TABLE IF EXISTS `ledger`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ledger` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `account_number` varchar(20) NOT NULL,
  `transaction_id` varchar(50) NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `currency` varchar(10) NOT NULL,
  `movement_type` enum('LOCK','SETTLE','FUND','REVERSAL') NOT NULL,
  `description` varchar(45) DEFAULT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `reference_id` (`transaction_id`,`movement_type`)
) ENGINE=InnoDB AUTO_INCREMENT=115 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ledger`
--

LOCK TABLES `ledger` WRITE;
/*!40000 ALTER TABLE `ledger` DISABLE KEYS */;
INSERT INTO `ledger` VALUES (113,'account-0001','0000103',100.00,'848','FUND',NULL,'2026-02-18 17:55:07'),(114,'account-0001','0000104',10.00,'848','FUND',NULL,'2026-02-18 17:57:34');
/*!40000 ALTER TABLE `ledger` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'transaction_data'
--
/*!50003 DROP PROCEDURE IF EXISTS `fund_account` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fund_account`(
    IN p_account_number VARCHAR(20),
    IN p_amount DECIMAL(15,2),
    IN p_transaction_id VARCHAR(50),
    IN p_currency VARCHAR(50)
)
BEGIN
	DECLARE v_disposable DECIMAL(15,2);
    
    START TRANSACTION;
    
	SELECT disposable
    INTO v_disposable
    FROM balance
    WHERE account_number = p_account_number
    FOR UPDATE;

    IF v_disposable IS NULL THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Account not found';
    END IF;

    UPDATE balance
    SET
        disposable = disposable + p_amount,
        total = total + p_amount
    WHERE account_number = p_account_number;

    INSERT INTO ledger (account_number, amount, movement_type, transaction_id,currency)
    VALUES (p_account_number, p_amount, 'FUND', p_transaction_id,p_currency);

    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `lock_funds` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `lock_funds`(
    IN p_account_number VARCHAR(20),
    IN p_amount DECIMAL(15,2),
    IN p_transaction_id VARCHAR(50),
    IN p_currency VARCHAR(10),
    OUT MESSAGE_TEXT VARCHAR(255)
)
BEGIN
    DECLARE v_disposable DECIMAL(15,2);

    IF p_amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Amount must be positive';
    END IF;

    START TRANSACTION;

    SELECT disposable
    INTO v_disposable
    FROM balance
    WHERE account_number = p_account_number
    FOR UPDATE;

    IF v_disposable IS NULL THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Account not found';
    END IF;

    IF v_disposable < p_amount THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient disposable balance';
    END IF;

    UPDATE balance
    SET
        disposable = disposable - p_amount,
        locked = locked + p_amount
    WHERE account_number = p_account_number;

    INSERT INTO ledger (account_number, amount, movement_type, transaction_id, currency)
    VALUES (p_account_number, p_amount, 'LOCK', p_transaction_id, p_currency);
	
    SET MESSAGE_TEXT = 'OK';
    
    COMMIT;
    
	IF p_transaction_id = '999999' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERROR';
	END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `reverse_charge` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `reverse_charge`(
    IN p_account_number VARCHAR(20),
    IN p_amount DECIMAL(15,2),
    IN p_transaction_id VARCHAR(50)
)
BEGIN
    DECLARE v_locked DECIMAL(15,2);
    DECLARE v_currency VARCHAR(10);

    START TRANSACTION;

    SELECT locked
    INTO v_locked
    FROM balance
    WHERE account_number = p_account_number
    FOR UPDATE;
    
	SELECT currency
    INTO v_currency
    FROM ledger
    WHERE account_number = p_account_number
    AND transaction_id = p_transaction_id;
    
	IF v_currency IS NULL THEN
		ROLLBACK;
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Original transaction not found';
    END IF;

    IF v_locked < p_amount THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient locked balance for reversal';
    END IF;

    UPDATE balance
    SET
        locked = locked - p_amount,
        disposable = disposable + p_amount
    WHERE account_number = p_account_number;

    INSERT INTO ledger (account_number, amount, movement_type, transaction_id,currency)
    VALUES (p_account_number, p_amount, 'REVERSAL', p_transaction_id, v_currency);

    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `reverse_fund` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `reverse_fund`(
    IN p_account_number VARCHAR(20),
    IN p_amount DECIMAL(15,2),
    IN p_transaction_id VARCHAR(50)
)
BEGIN
    DECLARE v_disposable DECIMAL(15,2);
    DECLARE v_currency VARCHAR(10);

    START TRANSACTION;

    SELECT disposable
    INTO v_disposable
    FROM balance
    WHERE account_number = p_account_number
    FOR UPDATE;
    
	SELECT currency
    INTO v_currency
    FROM ledger
    WHERE account_number = p_account_number
    AND transaction_id = p_transaction_id;
    
	IF v_currency IS NULL THEN
		ROLLBACK;
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Original transaction not found';
    END IF;

    IF v_disposable < p_amount THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient disposable balance for reversal';
    END IF;

    UPDATE balance
    SET
        disposable = disposable - p_amount,
        total = total - p_amount
    WHERE account_number = p_account_number;

    INSERT INTO ledger (account_number, amount, movement_type, transaction_id,currency)
    VALUES (p_account_number, p_amount, 'REVERSAL', p_transaction_id, v_currency);

    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `settle_funds` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `settle_funds`(
    IN p_account_number VARCHAR(20),
    IN p_amount DECIMAL(15,2),
    IN p_reference_id VARCHAR(50)
)
BEGIN
    DECLARE v_locked DECIMAL(15,2);

    START TRANSACTION;

    SELECT locked
    INTO v_locked
    FROM balance
    WHERE account_number = p_account_number
    FOR UPDATE;

    IF v_locked < p_amount THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient locked balance';
    END IF;

    UPDATE balance
    SET
        locked = locked - p_amount,
        total = total - p_amount
    WHERE account_number = p_account_number;

    INSERT INTO ledger (account_number, amount, movement_type, reference_id)
    VALUES (p_account_number, p_amount, 'SETTLE', p_reference_id);

    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `transfer_funds` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `transfer_funds`(
    IN p_from_account VARCHAR(20),
    IN p_to_account VARCHAR(20),
    IN p_amount DECIMAL(15,2),
    IN p_reference_id VARCHAR(50)
)
BEGIN
    -- Always lock in deterministic order
    IF p_from_account < p_to_account THEN
        CALL lock_funds(p_from_account, p_amount, p_reference_id);
        CALL settle_funds(p_from_account, p_amount, p_reference_id);
        CALL fund_account(p_to_account, p_amount, p_reference_id);
    ELSE
        CALL fund_account(p_to_account, p_amount, p_reference_id);
        CALL lock_funds(p_from_account, p_amount, p_reference_id);
        CALL settle_funds(p_from_account, p_amount, p_reference_id);
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-02-18 12:01:51
