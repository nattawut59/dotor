-- MySQL dump 10.13  Distrib 8.0.41, for macos15 (x86_64)
--
-- Host: gateway01.us-west-2.prod.aws.tidbcloud.com    Database: glaucoma_management_system
-- ------------------------------------------------------
-- Server version	5.7.28-TiDB-Serverless

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
-- Table structure for table `Alerts`
--

DROP TABLE IF EXISTS `Alerts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Alerts` (
  `alert_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `patient_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `alert_type` enum('high_iop','missed_medication','appointment_missed','treatment_concern','other') COLLATE utf8mb4_unicode_ci NOT NULL,
  `severity` enum('low','medium','high','critical') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'medium',
  `alert_message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `related_entity_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `related_entity_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `acknowledged` tinyint(1) NOT NULL DEFAULT '0',
  `acknowledged_by` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `acknowledged_at` datetime DEFAULT NULL,
  `resolution_status` enum('pending','in_progress','resolved','ignored') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `resolution_notes` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `resolved_at` datetime DEFAULT NULL,
  KEY `idx_alert_patient` (`patient_id`),
  KEY `idx_alert_type` (`alert_type`),
  KEY `idx_alert_severity` (`severity`),
  KEY `idx_alert_acknowledged` (`acknowledged`),
  KEY `idx_alert_resolution` (`resolution_status`),
  PRIMARY KEY (`alert_id`) /*T![clustered_index] CLUSTERED */,
  KEY `fk_2` (`acknowledged_by`),
  CONSTRAINT `fk_1` FOREIGN KEY (`patient_id`) REFERENCES `glaucoma_management_system`.`PatientProfiles` (`patient_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_2` FOREIGN KEY (`acknowledged_by`) REFERENCES `glaucoma_management_system`.`Users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Alerts`
--

LOCK TABLES `Alerts` WRITE;
/*!40000 ALTER TABLE `Alerts` DISABLE KEYS */;
/*!40000 ALTER TABLE `Alerts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `AnalysisReports`
--

DROP TABLE IF EXISTS `AnalysisReports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `AnalysisReports` (
  `report_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `patient_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `report_type` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `report_title` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `report_date` date NOT NULL,
  `report_data` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `summary` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `file_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_shared_with_patient` tinyint(1) NOT NULL DEFAULT '0',
  KEY `idx_report_patient` (`patient_id`),
  KEY `idx_report_type` (`report_type`),
  KEY `idx_report_date` (`report_date`),
  PRIMARY KEY (`report_id`) /*T![clustered_index] CLUSTERED */,
  KEY `fk_2` (`created_by`),
  CONSTRAINT `fk_1` FOREIGN KEY (`patient_id`) REFERENCES `glaucoma_management_system`.`PatientProfiles` (`patient_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_2` FOREIGN KEY (`created_by`) REFERENCES `glaucoma_management_system`.`Users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `AnalysisReports`
--

LOCK TABLES `AnalysisReports` WRITE;
/*!40000 ALTER TABLE `AnalysisReports` DISABLE KEYS */;
/*!40000 ALTER TABLE `AnalysisReports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `AppointmentReminders`
--

DROP TABLE IF EXISTS `AppointmentReminders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `AppointmentReminders` (
  `reminder_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `appointment_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `patient_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `reminder_type` enum('1_day','3_days','1_week','custom') COLLATE utf8mb4_unicode_ci NOT NULL,
  `custom_days_before` int(11) DEFAULT NULL,
  `reminder_channels` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT 'app',
  `reminder_status` enum('pending','sent','failed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `sent_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_appt_reminder_appointment` (`appointment_id`),
  KEY `idx_appt_reminder_patient` (`patient_id`),
  KEY `idx_appt_reminder_status` (`reminder_status`),
  PRIMARY KEY (`reminder_id`) /*T![clustered_index] CLUSTERED */,
  CONSTRAINT `fk_1` FOREIGN KEY (`appointment_id`) REFERENCES `glaucoma_management_system`.`Appointments` (`appointment_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_2` FOREIGN KEY (`patient_id`) REFERENCES `glaucoma_management_system`.`PatientProfiles` (`patient_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `AppointmentReminders`
--

LOCK TABLES `AppointmentReminders` WRITE;
/*!40000 ALTER TABLE `AppointmentReminders` DISABLE KEYS */;
/*!40000 ALTER TABLE `AppointmentReminders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Appointments`
--

DROP TABLE IF EXISTS `Appointments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Appointments` (
  `appointment_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `patient_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `doctor_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `appointment_date` date NOT NULL,
  `appointment_time` time NOT NULL,
  `appointment_type` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `appointment_location` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `appointment_duration` int(11) NOT NULL,
  `appointment_status` enum('scheduled','completed','cancelled','rescheduled','no_show') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'scheduled',
  `cancellation_reason` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY `idx_appointment_patient` (`patient_id`),
  KEY `idx_appointment_doctor` (`doctor_id`),
  KEY `idx_appointment_date` (`appointment_date`,`appointment_time`),
  KEY `idx_appointment_status` (`appointment_status`),
  PRIMARY KEY (`appointment_id`) /*T![clustered_index] CLUSTERED */,
  KEY `fk_3` (`created_by`),
  CONSTRAINT `fk_1` FOREIGN KEY (`patient_id`) REFERENCES `glaucoma_management_system`.`PatientProfiles` (`patient_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_2` FOREIGN KEY (`doctor_id`) REFERENCES `glaucoma_management_system`.`DoctorProfiles` (`doctor_id`),
  CONSTRAINT `fk_3` FOREIGN KEY (`created_by`) REFERENCES `glaucoma_management_system`.`Users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Appointments`
--

LOCK TABLES `Appointments` WRITE;
/*!40000 ALTER TABLE `Appointments` DISABLE KEYS */;
/*!40000 ALTER TABLE `Appointments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `AuditLogs`
--

DROP TABLE IF EXISTS `AuditLogs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `AuditLogs` (
  `log_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `action` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_type` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `action_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `details` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('success','failed') COLLATE utf8mb4_unicode_ci NOT NULL,
  `severity` enum('info','warning','error','critical') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'info',
  KEY `idx_audit_user` (`user_id`),
  KEY `idx_audit_action` (`action`),
  KEY `idx_audit_entity` (`entity_type`,`entity_id`),
  KEY `idx_audit_time` (`action_time`),
  KEY `idx_audit_severity` (`severity`),
  PRIMARY KEY (`log_id`) /*T![clustered_index] CLUSTERED */,
  CONSTRAINT `fk_1` FOREIGN KEY (`user_id`) REFERENCES `glaucoma_management_system`.`Users` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `AuditLogs`
--

LOCK TABLES `AuditLogs` WRITE;
/*!40000 ALTER TABLE `AuditLogs` DISABLE KEYS */;
INSERT INTO `AuditLogs` VALUES ('182de3df-8539-45c3-a0f6-b40eace42704','95321832-9a29-4214-8c4f-13302fd5ed5f','USER_REGISTRATION','Users','95321832-9a29-4214-8c4f-13302fd5ed5f','2025-05-04 16:18:23','127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36','New patient registration','success','info'),('2942a257-50b0-43d8-abb7-af41189f670d','ca50d22a-ad5b-492d-9ddf-3f27a5a79782','USER_LOGIN','Users','ca50d22a-ad5b-492d-9ddf-3f27a5a79782','2025-05-06 11:15:29','::1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36',NULL,'success','info'),('2b3b0e22-95a2-4b1a-84be-8ca75d1c300f','ca50d22a-ad5b-492d-9ddf-3f27a5a79782','USER_LOGIN','Users','ca50d22a-ad5b-492d-9ddf-3f27a5a79782','2025-05-07 12:04:31','::1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36',NULL,'success','info'),('322fedc5-82b6-4493-b561-63d525b6539b','711e7c46-f791-4260-9af6-14c305492780','USER_LOGIN','Users','711e7c46-f791-4260-9af6-14c305492780','2025-05-04 15:47:15','127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36',NULL,'success','info'),('4d7e67b2-fb03-4bc2-b818-c24b2d7f2f95','ca50d22a-ad5b-492d-9ddf-3f27a5a79782','USER_LOGIN','Users','ca50d22a-ad5b-492d-9ddf-3f27a5a79782','2025-05-07 11:29:16','::1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36',NULL,'success','info'),('51e73b66-0314-46ee-ac27-cadf5a03cf50','937260e1-9513-4840-8098-b7c13bbdfc1c','USER_LOGIN','Users','937260e1-9513-4840-8098-b7c13bbdfc1c','2025-05-05 09:49:38','127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36',NULL,'success','info'),('5b9dee47-dbd8-454e-977e-bf8327b0b619','937260e1-9513-4840-8098-b7c13bbdfc1c','USER_LOGIN','Users','937260e1-9513-4840-8098-b7c13bbdfc1c','2025-05-05 14:05:34','::1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36',NULL,'success','info'),('6ff75b4d-1c00-40c9-ab7e-cec9d2a58801','937260e1-9513-4840-8098-b7c13bbdfc1c','USER_REGISTRATION','Users','937260e1-9513-4840-8098-b7c13bbdfc1c','2025-05-05 09:49:02','127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36','New patient registration','success','info'),('91937277-26c5-477e-9758-884852ffaf8f','95321832-9a29-4214-8c4f-13302fd5ed5f','USER_LOGIN','Users','95321832-9a29-4214-8c4f-13302fd5ed5f','2025-05-04 16:19:03','127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36',NULL,'success','info'),('98a3db2a-dbdd-4998-bd24-33240aa7b231','937260e1-9513-4840-8098-b7c13bbdfc1c','USER_LOGIN','Users','937260e1-9513-4840-8098-b7c13bbdfc1c','2025-05-05 09:59:03','127.0.0.1','PostmanRuntime/7.43.4',NULL,'success','info'),('98c8f8b6-9178-4ffc-80f3-d8ebbfad6313','ca50d22a-ad5b-492d-9ddf-3f27a5a79782','USER_LOGIN','Users','ca50d22a-ad5b-492d-9ddf-3f27a5a79782','2025-05-08 06:22:39','::1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36',NULL,'success','info'),('99a923ed-8773-4814-be4d-f41d7676cd15','711e7c46-f791-4260-9af6-14c305492780','USER_LOGIN','Users','711e7c46-f791-4260-9af6-14c305492780','2025-05-04 13:02:43','127.0.0.1','PostmanRuntime/7.43.4',NULL,'success','info'),('9fc5c4a9-11da-4d11-baa4-3b0b16d110b5','711e7c46-f791-4260-9af6-14c305492780','USER_LOGIN','Users','711e7c46-f791-4260-9af6-14c305492780','2025-05-04 12:47:54','127.0.0.1','PostmanRuntime/7.43.4',NULL,'success','info'),('a4459b0b-a07c-498d-948d-16ed6e22f21c','711e7c46-f791-4260-9af6-14c305492780','USER_LOGIN','Users','711e7c46-f791-4260-9af6-14c305492780','2025-05-04 12:55:38','127.0.0.1','PostmanRuntime/7.43.4',NULL,'success','info'),('aec99f41-aa04-4c6c-8c08-060fd1b52c9d','711e7c46-f791-4260-9af6-14c305492780','USER_LOGIN','Users','711e7c46-f791-4260-9af6-14c305492780','2025-05-04 12:39:54','127.0.0.1','PostmanRuntime/7.43.4',NULL,'success','info'),('b6ed3c7d-bc27-48e7-af74-1dbbbf7c1f1c','711e7c46-f791-4260-9af6-14c305492780','USER_LOGIN','Users','711e7c46-f791-4260-9af6-14c305492780','2025-05-04 13:01:55','127.0.0.1','PostmanRuntime/7.43.4',NULL,'success','info'),('b84016ee-cd40-4e6f-91b7-986e3d65b6b2','937260e1-9513-4840-8098-b7c13bbdfc1c','USER_LOGIN','Users','937260e1-9513-4840-8098-b7c13bbdfc1c','2025-05-05 10:33:21','127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36',NULL,'success','info'),('bba6542c-5ea1-4ea9-bbe2-d56ee8cb43d3','711e7c46-f791-4260-9af6-14c305492780','PASSWORD_CHANGE','Users','711e7c46-f791-4260-9af6-14c305492780','2025-05-04 13:04:19','127.0.0.1','PostmanRuntime/7.43.4',NULL,'success','info'),('d5b124c6-f1e4-49f5-b9d2-b4fdcb3e96de','937260e1-9513-4840-8098-b7c13bbdfc1c','USER_LOGIN','Users','937260e1-9513-4840-8098-b7c13bbdfc1c','2025-05-05 11:45:53','127.0.0.1','PostmanRuntime/7.43.4',NULL,'success','info'),('d7356c82-eb7e-49be-84bf-2e44d27918cb','ca50d22a-ad5b-492d-9ddf-3f27a5a79782','USER_REGISTRATION','Users','ca50d22a-ad5b-492d-9ddf-3f27a5a79782','2025-05-06 11:14:35','::1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36','New patient registration','success','info'),('da776cb9-5037-4077-a83d-f6ff57e12ce2','ca50d22a-ad5b-492d-9ddf-3f27a5a79782','USER_LOGIN','Users','ca50d22a-ad5b-492d-9ddf-3f27a5a79782','2025-05-09 06:20:48','::1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36',NULL,'success','info'),('ddbc2b7a-9feb-41db-a6fe-ca18f3319bd0','711e7c46-f791-4260-9af6-14c305492780','USER_REGISTRATION','Users','711e7c46-f791-4260-9af6-14c305492780','2025-05-04 12:26:26','127.0.0.1','PostmanRuntime/7.43.4','New patient registration','success','info'),('ea69aa3f-92de-46e8-9f82-4d9ec1751246','937260e1-9513-4840-8098-b7c13bbdfc1c','USER_LOGIN','Users','937260e1-9513-4840-8098-b7c13bbdfc1c','2025-05-06 02:49:10','::1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36',NULL,'success','info'),('ead14382-af19-4346-a122-11b42c5810dc','937260e1-9513-4840-8098-b7c13bbdfc1c','USER_LOGIN','Users','937260e1-9513-4840-8098-b7c13bbdfc1c','2025-05-06 02:52:22','::1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36',NULL,'success','info'),('f186a3ae-9f3e-4c07-a802-4afb12c0c9c4','711e7c46-f791-4260-9af6-14c305492780','USER_LOGIN','Users','711e7c46-f791-4260-9af6-14c305492780','2025-05-04 15:35:50','127.0.0.1','Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Mobile Safari/537.36',NULL,'success','info'),('f9b561c6-19cb-4dcd-8443-42eed1599829','937260e1-9513-4840-8098-b7c13bbdfc1c','USER_LOGIN','Users','937260e1-9513-4840-8098-b7c13bbdfc1c','2025-05-05 09:54:21','127.0.0.1','PostmanRuntime/7.43.4',NULL,'success','info'),('faa6e48b-3894-4ec2-bdb4-ea0d49a548ae','ca50d22a-ad5b-492d-9ddf-3f27a5a79782','USER_LOGIN','Users','ca50d22a-ad5b-492d-9ddf-3f27a5a79782','2025-05-09 07:12:18','::1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36',NULL,'success','info');
/*!40000 ALTER TABLE `AuditLogs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ConsentHistory`
--

DROP TABLE IF EXISTS `ConsentHistory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ConsentHistory` (
  `history_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `consent_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `patient_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `previous_status` tinyint(1) DEFAULT NULL,
  `new_status` tinyint(1) NOT NULL,
  `changed_by` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `changed_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`history_id`) /*T![clustered_index] CLUSTERED */,
  KEY `fk_1` (`consent_id`),
  KEY `fk_2` (`patient_id`),
  KEY `fk_3` (`changed_by`),
  CONSTRAINT `fk_1` FOREIGN KEY (`consent_id`) REFERENCES `glaucoma_management_system`.`UserConsents` (`consent_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_2` FOREIGN KEY (`patient_id`) REFERENCES `glaucoma_management_system`.`PatientProfiles` (`patient_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_3` FOREIGN KEY (`changed_by`) REFERENCES `glaucoma_management_system`.`Users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ConsentHistory`
--

LOCK TABLES `ConsentHistory` WRITE;
/*!40000 ALTER TABLE `ConsentHistory` DISABLE KEYS */;
/*!40000 ALTER TABLE `ConsentHistory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `DiseaseProgressionAnalysis`
--

DROP TABLE IF EXISTS `DiseaseProgressionAnalysis`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `DiseaseProgressionAnalysis` (
  `analysis_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `patient_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `analysis_date` date NOT NULL,
  `analysis_period` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `left_eye_md_change` decimal(5,2) DEFAULT NULL,
  `right_eye_md_change` decimal(5,2) DEFAULT NULL,
  `left_eye_progression_rate` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `right_eye_progression_rate` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `left_eye_rnfl_change` decimal(5,2) DEFAULT NULL,
  `right_eye_rnfl_change` decimal(5,2) DEFAULT NULL,
  `progression_factors` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `analysis_methodology` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `prediction_5year` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_progression_patient` (`patient_id`),
  KEY `idx_progression_date` (`analysis_date`),
  PRIMARY KEY (`analysis_id`) /*T![clustered_index] CLUSTERED */,
  KEY `fk_2` (`created_by`),
  CONSTRAINT `fk_1` FOREIGN KEY (`patient_id`) REFERENCES `glaucoma_management_system`.`PatientProfiles` (`patient_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_2` FOREIGN KEY (`created_by`) REFERENCES `glaucoma_management_system`.`Users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `DiseaseProgressionAnalysis`
--

LOCK TABLES `DiseaseProgressionAnalysis` WRITE;
/*!40000 ALTER TABLE `DiseaseProgressionAnalysis` DISABLE KEYS */;
/*!40000 ALTER TABLE `DiseaseProgressionAnalysis` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `DoctorPatientRelationships`
--

DROP TABLE IF EXISTS `DoctorPatientRelationships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `DoctorPatientRelationships` (
  `relationship_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `doctor_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `patient_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `status` enum('active','inactive','transferred') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `notes` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  UNIQUE KEY `unq_doctor_patient` (`doctor_id`,`patient_id`),
  KEY `idx_relationship_doctor` (`doctor_id`),
  KEY `idx_relationship_patient` (`patient_id`),
  KEY `idx_relationship_status` (`status`),
  PRIMARY KEY (`relationship_id`) /*T![clustered_index] CLUSTERED */,
  CONSTRAINT `fk_1` FOREIGN KEY (`doctor_id`) REFERENCES `glaucoma_management_system`.`DoctorProfiles` (`doctor_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_2` FOREIGN KEY (`patient_id`) REFERENCES `glaucoma_management_system`.`PatientProfiles` (`patient_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `DoctorPatientRelationships`
--

LOCK TABLES `DoctorPatientRelationships` WRITE;
/*!40000 ALTER TABLE `DoctorPatientRelationships` DISABLE KEYS */;
/*!40000 ALTER TABLE `DoctorPatientRelationships` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `DoctorProfiles`
--

DROP TABLE IF EXISTS `DoctorProfiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `DoctorProfiles` (
  `doctor_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `first_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `license_number` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `department` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `specialty` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `education` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hospital_affiliation` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `profile_image` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `consultation_hours` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bio` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `registration_date` date NOT NULL,
  `status` enum('active','inactive','on_leave') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  KEY `idx_doctor_license` (`license_number`),
  KEY `idx_doctor_name` (`first_name`,`last_name`),
  KEY `idx_doctor_department` (`department`),
  PRIMARY KEY (`doctor_id`) /*T![clustered_index] CLUSTERED */,
  UNIQUE KEY `license_number` (`license_number`),
  CONSTRAINT `fk_1` FOREIGN KEY (`doctor_id`) REFERENCES `glaucoma_management_system`.`Users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `DoctorProfiles`
--

LOCK TABLES `DoctorProfiles` WRITE;
/*!40000 ALTER TABLE `DoctorProfiles` DISABLE KEYS */;
/*!40000 ALTER TABLE `DoctorProfiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `DocumentAccess`
--

DROP TABLE IF EXISTS `DocumentAccess`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `DocumentAccess` (
  `access_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `document_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `access_type` enum('view','download','edit','delete') COLLATE utf8mb4_unicode_ci NOT NULL,
  `access_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `access_result` enum('success','denied','error') COLLATE utf8mb4_unicode_ci NOT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `device_info` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  KEY `idx_doc_access_document` (`document_id`),
  KEY `idx_doc_access_user` (`user_id`),
  KEY `idx_doc_access_time` (`access_time`),
  PRIMARY KEY (`access_id`) /*T![clustered_index] CLUSTERED */,
  CONSTRAINT `fk_1` FOREIGN KEY (`document_id`) REFERENCES `glaucoma_management_system`.`MedicalDocuments` (`document_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_2` FOREIGN KEY (`user_id`) REFERENCES `glaucoma_management_system`.`Users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `DocumentAccess`
--

LOCK TABLES `DocumentAccess` WRITE;
/*!40000 ALTER TABLE `DocumentAccess` DISABLE KEYS */;
/*!40000 ALTER TABLE `DocumentAccess` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `EyeInjuryHistory`
--

DROP TABLE IF EXISTS `EyeInjuryHistory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `EyeInjuryHistory` (
  `injury_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `patient_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `injury_date` date DEFAULT NULL,
  `eye` enum('left','right','both') COLLATE utf8mb4_unicode_ci NOT NULL,
  `injury_type` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `treatment_received` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `long_term_effects` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `image_urls` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `recorded_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_injury_patient` (`patient_id`),
  KEY `idx_injury_date` (`injury_date`),
  PRIMARY KEY (`injury_id`) /*T![clustered_index] CLUSTERED */,
  CONSTRAINT `fk_1` FOREIGN KEY (`patient_id`) REFERENCES `glaucoma_management_system`.`PatientProfiles` (`patient_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `EyeInjuryHistory`
--

LOCK TABLES `EyeInjuryHistory` WRITE;
/*!40000 ALTER TABLE `EyeInjuryHistory` DISABLE KEYS */;
/*!40000 ALTER TABLE `EyeInjuryHistory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `FamilyGlaucomaHistory`
--

DROP TABLE IF EXISTS `FamilyGlaucomaHistory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `FamilyGlaucomaHistory` (
  `family_history_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `patient_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `relationship` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `glaucoma_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `age_at_diagnosis` int(11) DEFAULT NULL,
  `severity` enum('mild','moderate','severe','unknown') COLLATE utf8mb4_unicode_ci DEFAULT 'unknown',
  `treatment` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `current_status` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `recorded_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_family_history_patient` (`patient_id`),
  PRIMARY KEY (`family_history_id`) /*T![clustered_index] CLUSTERED */,
  CONSTRAINT `fk_1` FOREIGN KEY (`patient_id`) REFERENCES `glaucoma_management_system`.`PatientProfiles` (`patient_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `FamilyGlaucomaHistory`
--

LOCK TABLES `FamilyGlaucomaHistory` WRITE;
/*!40000 ALTER TABLE `FamilyGlaucomaHistory` DISABLE KEYS */;
INSERT INTO `FamilyGlaucomaHistory` VALUES ('10dab9b8-ac1a-474e-a022-17ae0614976a','937260e1-9513-4840-8098-b7c13bbdfc1c','แม่','unknown',NULL,'unknown',NULL,NULL,'Recorded during registration','2025-05-05 09:49:02'),('4a52c52a-c20d-4cd6-87e9-c79470ee0edf','711e7c46-f791-4260-9af6-14c305492780','พ่อ','unknown',NULL,'unknown',NULL,NULL,'Recorded during registration','2025-05-04 12:26:25'),('d2562603-f43e-408c-87c0-33a10cd5ae28','937260e1-9513-4840-8098-b7c13bbdfc1c','father','Primary Open-Angle Glaucoma',65,'moderate','Eye drops, followed by surgery',NULL,'พบโรคต้อหินในวัยชรา','2025-05-06 03:56:44');
/*!40000 ALTER TABLE `FamilyGlaucomaHistory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `GlaucomaDiagnosis`
--

DROP TABLE IF EXISTS `GlaucomaDiagnosis`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `GlaucomaDiagnosis` (
  `diagnosis_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `patient_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `doctor_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `diagnosis_date` date NOT NULL,
  `glaucoma_type` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `icd_code` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `diagnosis_details` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `diagnosis_basis` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `severity` enum('early','moderate','advanced','severe') COLLATE utf8mb4_unicode_ci NOT NULL,
  `left_eye_affected` tinyint(1) NOT NULL DEFAULT '0',
  `right_eye_affected` tinyint(1) NOT NULL DEFAULT '0',
  `notes` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  KEY `idx_diagnosis_patient` (`patient_id`),
  KEY `idx_diagnosis_type` (`glaucoma_type`),
  KEY `idx_diagnosis_date` (`diagnosis_date`),
  PRIMARY KEY (`diagnosis_id`) /*T![clustered_index] CLUSTERED */,
  KEY `fk_2` (`doctor_id`),
  CONSTRAINT `fk_1` FOREIGN KEY (`patient_id`) REFERENCES `glaucoma_management_system`.`PatientProfiles` (`patient_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_2` FOREIGN KEY (`doctor_id`) REFERENCES `glaucoma_management_system`.`DoctorProfiles` (`doctor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `GlaucomaDiagnosis`
--

LOCK TABLES `GlaucomaDiagnosis` WRITE;
/*!40000 ALTER TABLE `GlaucomaDiagnosis` DISABLE KEYS */;
/*!40000 ALTER TABLE `GlaucomaDiagnosis` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `GlaucomaSurgeries`
--

DROP TABLE IF EXISTS `GlaucomaSurgeries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `GlaucomaSurgeries` (
  `surgery_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `patient_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `doctor_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `surgery_date` date NOT NULL,
  `surgery_type` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `eye` enum('left','right','both') COLLATE utf8mb4_unicode_ci NOT NULL,
  `pre_op_iop_left` decimal(5,2) DEFAULT NULL,
  `pre_op_iop_right` decimal(5,2) DEFAULT NULL,
  `procedure_details` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `complications` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `post_op_care` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `outcome` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `follow_up_plan` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `report_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  KEY `idx_surgery_patient` (`patient_id`),
  KEY `idx_surgery_date` (`surgery_date`),
  KEY `idx_surgery_type` (`surgery_type`),
  PRIMARY KEY (`surgery_id`) /*T![clustered_index] CLUSTERED */,
  KEY `fk_2` (`doctor_id`),
  CONSTRAINT `fk_1` FOREIGN KEY (`patient_id`) REFERENCES `glaucoma_management_system`.`PatientProfiles` (`patient_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_2` FOREIGN KEY (`doctor_id`) REFERENCES `glaucoma_management_system`.`DoctorProfiles` (`doctor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `GlaucomaSurgeries`
--

LOCK TABLES `GlaucomaSurgeries` WRITE;
/*!40000 ALTER TABLE `GlaucomaSurgeries` DISABLE KEYS */;
/*!40000 ALTER TABLE `GlaucomaSurgeries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `GlaucomaTreatmentPlans`
--

DROP TABLE IF EXISTS `GlaucomaTreatmentPlans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `GlaucomaTreatmentPlans` (
  `treatment_plan_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `patient_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `doctor_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `treatment_approach` enum('medication','laser','surgery','combined') COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_iop_left` decimal(5,2) DEFAULT NULL,
  `target_iop_right` decimal(5,2) DEFAULT NULL,
  `follow_up_frequency` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `visual_field_test_frequency` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('active','completed','modified') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY `idx_treatment_patient` (`patient_id`),
  KEY `idx_treatment_status` (`status`),
  KEY `idx_treatment_approach` (`treatment_approach`),
  PRIMARY KEY (`treatment_plan_id`) /*T![clustered_index] CLUSTERED */,
  KEY `fk_2` (`doctor_id`),
  CONSTRAINT `fk_1` FOREIGN KEY (`patient_id`) REFERENCES `glaucoma_management_system`.`PatientProfiles` (`patient_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_2` FOREIGN KEY (`doctor_id`) REFERENCES `glaucoma_management_system`.`DoctorProfiles` (`doctor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `GlaucomaTreatmentPlans`
--

LOCK TABLES `GlaucomaTreatmentPlans` WRITE;
/*!40000 ALTER TABLE `GlaucomaTreatmentPlans` DISABLE KEYS */;
/*!40000 ALTER TABLE `GlaucomaTreatmentPlans` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `IOP_Measurements`
--

DROP TABLE IF EXISTS `IOP_Measurements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `IOP_Measurements` (
  `measurement_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `patient_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `recorded_by` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `measurement_date` date NOT NULL,
  `measurement_time` time NOT NULL,
  `left_eye_iop` decimal(5,2) DEFAULT NULL,
  `right_eye_iop` decimal(5,2) DEFAULT NULL,
  `measurement_device` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `measurement_method` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `measured_at_hospital` tinyint(1) NOT NULL DEFAULT '1',
  `notes` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `visit_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  KEY `idx_iop_patient` (`patient_id`),
  KEY `idx_iop_date` (`measurement_date`),
  KEY `idx_iop_visit` (`visit_id`),
  PRIMARY KEY (`measurement_id`) /*T![clustered_index] CLUSTERED */,
  KEY `fk_2` (`recorded_by`),
  CONSTRAINT `fk_1` FOREIGN KEY (`patient_id`) REFERENCES `glaucoma_management_system`.`PatientProfiles` (`patient_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_2` FOREIGN KEY (`recorded_by`) REFERENCES `glaucoma_management_system`.`Users` (`user_id`),
  CONSTRAINT `fk_3` FOREIGN KEY (`visit_id`) REFERENCES `glaucoma_management_system`.`PatientVisits` (`visit_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `IOP_Measurements`
--

LOCK TABLES `IOP_Measurements` WRITE;
/*!40000 ALTER TABLE `IOP_Measurements` DISABLE KEYS */;
INSERT INTO `IOP_Measurements` VALUES ('6814c29e-7016-42b7-8bdf-a7aabb2ea5fa','937260e1-9513-4840-8098-b7c13bbdfc1c','937260e1-9513-4840-8098-b7c13bbdfc1c','2025-05-06','05:08:56',18.50,19.20,'iCare','Rebound Tonometry',0,'วัดที่บ้านช่วงเช้า',NULL),('a1e07322-ebe3-4c64-a218-f4316bde953b','711e7c46-f791-4260-9af6-14c305492780','711e7c46-f791-4260-9af6-14c305492780','2024-01-15','12:26:25',23.00,24.00,'Unknown','Applanation tonometry',1,'Target IOP: น้อยกว่า 21 mmHg',NULL),('d0e647f8-76a2-48ed-ba7a-cd4fcd6b0705','95321832-9a29-4214-8c4f-13302fd5ed5f','95321832-9a29-4214-8c4f-13302fd5ed5f','2025-05-04','16:18:23',18.00,17.00,'Unknown','Applanation tonometry',1,NULL,NULL);
/*!40000 ALTER TABLE `IOP_Measurements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `IOP_Monthly_Summary`
--

DROP TABLE IF EXISTS `IOP_Monthly_Summary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `IOP_Monthly_Summary` (
  `summary_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `patient_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `month` int(11) NOT NULL,
  `year` int(11) NOT NULL,
  `avg_left_eye_iop` decimal(5,2) DEFAULT NULL,
  `avg_right_eye_iop` decimal(5,2) DEFAULT NULL,
  `max_left_eye_iop` decimal(5,2) DEFAULT NULL,
  `max_right_eye_iop` decimal(5,2) DEFAULT NULL,
  `min_left_eye_iop` decimal(5,2) DEFAULT NULL,
  `min_right_eye_iop` decimal(5,2) DEFAULT NULL,
  `measurement_count` int(11) NOT NULL,
  UNIQUE KEY `unq_patient_month_year` (`patient_id`,`month`,`year`),
  PRIMARY KEY (`summary_id`) /*T![clustered_index] CLUSTERED */,
  CONSTRAINT `fk_1` FOREIGN KEY (`patient_id`) REFERENCES `glaucoma_management_system`.`PatientProfiles` (`patient_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `IOP_Monthly_Summary`
--

LOCK TABLES `IOP_Monthly_Summary` WRITE;
/*!40000 ALTER TABLE `IOP_Monthly_Summary` DISABLE KEYS */;
INSERT INTO `IOP_Monthly_Summary` VALUES ('1b0146e5-091f-44ab-8d23-87b040d368e1','937260e1-9513-4840-8098-b7c13bbdfc1c',5,2025,18.50,19.20,18.50,19.20,18.50,19.20,1);
/*!40000 ALTER TABLE `IOP_Monthly_Summary` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `MedicalDocuments`
--

DROP TABLE IF EXISTS `MedicalDocuments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `MedicalDocuments` (
  `document_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `patient_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `document_type` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `document_title` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_size` int(11) NOT NULL,
  `file_format` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `upload_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `uploaded_by` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tags` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `visit_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY `idx_document_patient` (`patient_id`),
  KEY `idx_document_type` (`document_type`),
  KEY `idx_document_visit` (`visit_id`),
  KEY `idx_document_archived` (`is_archived`),
  PRIMARY KEY (`document_id`) /*T![clustered_index] CLUSTERED */,
  KEY `fk_2` (`uploaded_by`),
  CONSTRAINT `fk_1` FOREIGN KEY (`patient_id`) REFERENCES `glaucoma_management_system`.`PatientProfiles` (`patient_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_2` FOREIGN KEY (`uploaded_by`) REFERENCES `glaucoma_management_system`.`Users` (`user_id`),
  CONSTRAINT `fk_3` FOREIGN KEY (`visit_id`) REFERENCES `glaucoma_management_system`.`PatientVisits` (`visit_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `MedicalDocuments`
--

LOCK TABLES `MedicalDocuments` WRITE;
/*!40000 ALTER TABLE `MedicalDocuments` DISABLE KEYS */;
/*!40000 ALTER TABLE `MedicalDocuments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `MedicationAdherenceSummary`
--

DROP TABLE IF EXISTS `MedicationAdherenceSummary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `MedicationAdherenceSummary` (
  `summary_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `patient_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `medication_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `month` int(11) NOT NULL,
  `year` int(11) NOT NULL,
  `total_scheduled` int(11) NOT NULL DEFAULT '0',
  `total_taken` int(11) NOT NULL DEFAULT '0',
  `total_skipped` int(11) NOT NULL DEFAULT '0',
  `adherence_rate` decimal(5,2) DEFAULT NULL,
  UNIQUE KEY `unq_adherence_patient_med_month_year` (`patient_id`,`medication_id`,`month`,`year`),
  PRIMARY KEY (`summary_id`) /*T![clustered_index] CLUSTERED */,
  KEY `fk_2` (`medication_id`),
  CONSTRAINT `fk_1` FOREIGN KEY (`patient_id`) REFERENCES `glaucoma_management_system`.`PatientProfiles` (`patient_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_2` FOREIGN KEY (`medication_id`) REFERENCES `glaucoma_management_system`.`Medications` (`medication_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `MedicationAdherenceSummary`
--

LOCK TABLES `MedicationAdherenceSummary` WRITE;
/*!40000 ALTER TABLE `MedicationAdherenceSummary` DISABLE KEYS */;
/*!40000 ALTER TABLE `MedicationAdherenceSummary` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `MedicationInventory`
--

DROP TABLE IF EXISTS `MedicationInventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `MedicationInventory` (
  `inventory_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `patient_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `medication_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `bottles_dispensed` int(11) NOT NULL,
  `bottle_volume_ml` decimal(5,2) NOT NULL,
  `dispensed_date` date NOT NULL,
  `expected_end_date` date DEFAULT NULL,
  `drops_per_ml` int(11) DEFAULT NULL,
  `is_depleted` tinyint(1) NOT NULL DEFAULT '0',
  `depleted_date` date DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY `idx_inventory_patient` (`patient_id`),
  KEY `idx_inventory_medication` (`medication_id`),
  KEY `idx_inventory_depleted` (`is_depleted`),
  PRIMARY KEY (`inventory_id`) /*T![clustered_index] CLUSTERED */,
  CONSTRAINT `fk_1` FOREIGN KEY (`patient_id`) REFERENCES `glaucoma_management_system`.`PatientProfiles` (`patient_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_2` FOREIGN KEY (`medication_id`) REFERENCES `glaucoma_management_system`.`Medications` (`medication_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `MedicationInventory`
--

LOCK TABLES `MedicationInventory` WRITE;
/*!40000 ALTER TABLE `MedicationInventory` DISABLE KEYS */;
/*!40000 ALTER TABLE `MedicationInventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `MedicationReminders`
--

DROP TABLE IF EXISTS `MedicationReminders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `MedicationReminders` (
  `reminder_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `patient_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `prescription_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `medication_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `reminder_time` time NOT NULL,
  `days_of_week` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `eye` enum('left','right','both') COLLATE utf8mb4_unicode_ci NOT NULL,
  `drops_count` int(11) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `notification_channels` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT 'app',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY `idx_reminder_patient` (`patient_id`),
  KEY `idx_reminder_prescription` (`prescription_id`),
  KEY `idx_reminder_time` (`reminder_time`),
  KEY `idx_reminder_active` (`is_active`),
  PRIMARY KEY (`reminder_id`) /*T![clustered_index] CLUSTERED */,
  KEY `fk_3` (`medication_id`),
  CONSTRAINT `fk_1` FOREIGN KEY (`patient_id`) REFERENCES `glaucoma_management_system`.`PatientProfiles` (`patient_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_2` FOREIGN KEY (`prescription_id`) REFERENCES `glaucoma_management_system`.`PatientMedications` (`prescription_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_3` FOREIGN KEY (`medication_id`) REFERENCES `glaucoma_management_system`.`Medications` (`medication_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `MedicationReminders`
--

LOCK TABLES `MedicationReminders` WRITE;
/*!40000 ALTER TABLE `MedicationReminders` DISABLE KEYS */;
/*!40000 ALTER TABLE `MedicationReminders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `MedicationUsageRecords`
--

DROP TABLE IF EXISTS `MedicationUsageRecords`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `MedicationUsageRecords` (
  `record_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `patient_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `reminder_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `medication_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `scheduled_time` datetime NOT NULL,
  `actual_time` datetime DEFAULT NULL,
  `status` enum('taken','skipped','delayed') COLLATE utf8mb4_unicode_ci NOT NULL,
  `eye` enum('left','right','both') COLLATE utf8mb4_unicode_ci NOT NULL,
  `drops_count` int(11) DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_usage_patient` (`patient_id`),
  KEY `idx_usage_reminder` (`reminder_id`),
  KEY `idx_usage_scheduled` (`scheduled_time`),
  KEY `idx_usage_status` (`status`),
  PRIMARY KEY (`record_id`) /*T![clustered_index] CLUSTERED */,
  KEY `fk_3` (`medication_id`),
  CONSTRAINT `fk_1` FOREIGN KEY (`patient_id`) REFERENCES `glaucoma_management_system`.`PatientProfiles` (`patient_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_2` FOREIGN KEY (`reminder_id`) REFERENCES `glaucoma_management_system`.`MedicationReminders` (`reminder_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_3` FOREIGN KEY (`medication_id`) REFERENCES `glaucoma_management_system`.`Medications` (`medication_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `MedicationUsageRecords`
--

LOCK TABLES `MedicationUsageRecords` WRITE;
/*!40000 ALTER TABLE `MedicationUsageRecords` DISABLE KEYS */;
/*!40000 ALTER TABLE `MedicationUsageRecords` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Medications`
--

DROP TABLE IF EXISTS `Medications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Medications` (
  `medication_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `generic_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `form` enum('eye drops','tablet','injection','other') COLLATE utf8mb4_unicode_ci NOT NULL,
  `strength` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `manufacturer` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dosage_instructions` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `side_effects` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contraindications` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `interactions` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `image_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `status` enum('active','discontinued','unavailable') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  KEY `idx_medication_name` (`name`),
  KEY `idx_medication_generic` (`generic_name`),
  KEY `idx_medication_category` (`category`),
  KEY `idx_medication_status` (`status`),
  PRIMARY KEY (`medication_id`) /*T![clustered_index] CLUSTERED */
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Medications`
--

LOCK TABLES `Medications` WRITE;
/*!40000 ALTER TABLE `Medications` DISABLE KEYS */;
/*!40000 ALTER TABLE `Medications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Notifications`
--

DROP TABLE IF EXISTS `Notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Notifications` (
  `notification_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `notification_type` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `body` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `related_entity_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `related_entity_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `priority` enum('low','medium','high','urgent') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'medium',
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `read_at` datetime DEFAULT NULL,
  `channels` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT 'app',
  `sent_at` datetime DEFAULT NULL,
  `status` enum('pending','sent','failed','delivered') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_notification_user` (`user_id`),
  KEY `idx_notification_type` (`notification_type`),
  KEY `idx_notification_read` (`is_read`),
  KEY `idx_notification_status` (`status`),
  PRIMARY KEY (`notification_id`) /*T![clustered_index] CLUSTERED */,
  CONSTRAINT `fk_1` FOREIGN KEY (`user_id`) REFERENCES `glaucoma_management_system`.`Users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Notifications`
--

LOCK TABLES `Notifications` WRITE;
/*!40000 ALTER TABLE `Notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `Notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `NurseProfiles`
--

DROP TABLE IF EXISTS `NurseProfiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `NurseProfiles` (
  `nurse_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `first_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `license_number` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `department` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `position` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `education` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hospital_affiliation` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `profile_image` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `working_hours` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `registration_date` date NOT NULL,
  `status` enum('active','inactive','on_leave') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  PRIMARY KEY (`nurse_id`) /*T![clustered_index] CLUSTERED */,
  UNIQUE KEY `license_number` (`license_number`),
  CONSTRAINT `fk_1` FOREIGN KEY (`nurse_id`) REFERENCES `glaucoma_management_system`.`Users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `NurseProfiles`
--

LOCK TABLES `NurseProfiles` WRITE;
/*!40000 ALTER TABLE `NurseProfiles` DISABLE KEYS */;
/*!40000 ALTER TABLE `NurseProfiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `OCT_Results`
--

DROP TABLE IF EXISTS `OCT_Results`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `OCT_Results` (
  `oct_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `test_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `left_avg_rnfl` decimal(5,2) DEFAULT NULL,
  `right_avg_rnfl` decimal(5,2) DEFAULT NULL,
  `left_superior_rnfl` decimal(5,2) DEFAULT NULL,
  `right_superior_rnfl` decimal(5,2) DEFAULT NULL,
  `left_inferior_rnfl` decimal(5,2) DEFAULT NULL,
  `right_inferior_rnfl` decimal(5,2) DEFAULT NULL,
  `left_temporal_rnfl` decimal(5,2) DEFAULT NULL,
  `right_temporal_rnfl` decimal(5,2) DEFAULT NULL,
  `left_nasal_rnfl` decimal(5,2) DEFAULT NULL,
  `right_nasal_rnfl` decimal(5,2) DEFAULT NULL,
  `left_cup_disc_ratio` decimal(4,3) DEFAULT NULL,
  `right_cup_disc_ratio` decimal(4,3) DEFAULT NULL,
  `left_rim_area` decimal(5,2) DEFAULT NULL,
  `right_rim_area` decimal(5,2) DEFAULT NULL,
  `left_image_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `right_image_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  KEY `idx_oct_test` (`test_id`),
  PRIMARY KEY (`oct_id`) /*T![clustered_index] CLUSTERED */,
  CONSTRAINT `fk_1` FOREIGN KEY (`test_id`) REFERENCES `glaucoma_management_system`.`SpecialEyeTests` (`test_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `OCT_Results`
--

LOCK TABLES `OCT_Results` WRITE;
/*!40000 ALTER TABLE `OCT_Results` DISABLE KEYS */;
/*!40000 ALTER TABLE `OCT_Results` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `PatientMedicalHistory`
--

DROP TABLE IF EXISTS `PatientMedicalHistory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `PatientMedicalHistory` (
  `history_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `patient_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `condition_type` enum('chronic','allergy','surgery','injury','other') COLLATE utf8mb4_unicode_ci NOT NULL,
  `condition_name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `diagnosis_date` date DEFAULT NULL,
  `treatment` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `current_status` enum('active','resolved','managed','unknown') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'unknown',
  `notes` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `recorded_by` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `recorded_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_med_history_patient` (`patient_id`),
  KEY `idx_med_history_condition` (`condition_type`,`condition_name`),
  PRIMARY KEY (`history_id`) /*T![clustered_index] CLUSTERED */,
  KEY `fk_2` (`recorded_by`),
  CONSTRAINT `fk_1` FOREIGN KEY (`patient_id`) REFERENCES `glaucoma_management_system`.`PatientProfiles` (`patient_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_2` FOREIGN KEY (`recorded_by`) REFERENCES `glaucoma_management_system`.`Users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `PatientMedicalHistory`
--

LOCK TABLES `PatientMedicalHistory` WRITE;
/*!40000 ALTER TABLE `PatientMedicalHistory` DISABLE KEYS */;
INSERT INTO `PatientMedicalHistory` VALUES ('4422bc41-dde4-487d-a5df-ac6947b748bb','711e7c46-f791-4260-9af6-14c305492780','chronic','เบาหวาน, ความดันโลหิตสูง',NULL,NULL,'active',NULL,'711e7c46-f791-4260-9af6-14c305492780','2025-05-04 12:26:24'),('53e0e6a3-c01b-486f-a34d-d487c95c5ce2','711e7c46-f791-4260-9af6-14c305492780','other','Glaucoma Treatment',NULL,'medication','active','medication - ผ่าตัดเลเซอร์ที่ตาขวาเมื่อ 6 เดือนก่อน','711e7c46-f791-4260-9af6-14c305492780','2025-05-04 12:26:25'),('610d6d16-c518-4eeb-87a3-dd9652388659','711e7c46-f791-4260-9af6-14c305492780','chronic','Glaucoma (open-angle)','2023-06-15','ผ่าตัดเลเซอร์ที่ตาขวาเมื่อ 6 เดือนก่อน','active','{\"symptoms\":[\"blurred-vision\",\"eye-pain\",\"headache\"],\"otherSymptoms\":\"เห็นรุ้งรอบดวงไฟ\",\"additionalNotes\":\"มีประวัติแพ้ยา Aspirin\"}','711e7c46-f791-4260-9af6-14c305492780','2025-05-04 12:26:25'),('85b94894-a18a-4b88-a96b-4197fb743809','711e7c46-f791-4260-9af6-14c305492780','allergy','Aspirin, Penicillin',NULL,NULL,'active',NULL,'711e7c46-f791-4260-9af6-14c305492780','2025-05-04 12:26:24'),('8bcb1549-9d98-4381-918d-a5a8b6070211','95321832-9a29-4214-8c4f-13302fd5ed5f','chronic','Glaucoma (open-angle)','2025-05-04',NULL,'active','{\"symptoms\":[\"eye-pain\",\"headache\"],\"otherSymptoms\":\"\",\"additionalNotes\":\"\"}','95321832-9a29-4214-8c4f-13302fd5ed5f','2025-05-04 16:18:23'),('c5f3cbdf-5d99-4188-90bb-bac577029f53','711e7c46-f791-4260-9af6-14c305492780','other','Glaucoma Treatment',NULL,'laser','active','laser - ผ่าตัดเลเซอร์ที่ตาขวาเมื่อ 6 เดือนก่อน','711e7c46-f791-4260-9af6-14c305492780','2025-05-04 12:26:25');
/*!40000 ALTER TABLE `PatientMedicalHistory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `PatientMedications`
--

DROP TABLE IF EXISTS `PatientMedications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `PatientMedications` (
  `prescription_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `patient_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `medication_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `doctor_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `prescribed_date` date NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `eye` enum('left','right','both') COLLATE utf8mb4_unicode_ci NOT NULL,
  `dosage` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `frequency` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `duration` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `quantity_dispensed` int(11) DEFAULT NULL,
  `refills` int(11) DEFAULT '0',
  `special_instructions` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('active','completed','discontinued') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `discontinued_reason` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_dispensed_date` date DEFAULT NULL,
  `visit_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY `idx_patient_med_patient` (`patient_id`),
  KEY `idx_patient_med_medication` (`medication_id`),
  KEY `idx_patient_med_status` (`status`),
  PRIMARY KEY (`prescription_id`) /*T![clustered_index] CLUSTERED */,
  KEY `fk_3` (`doctor_id`),
  KEY `fk_4` (`visit_id`),
  CONSTRAINT `fk_1` FOREIGN KEY (`patient_id`) REFERENCES `glaucoma_management_system`.`PatientProfiles` (`patient_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_2` FOREIGN KEY (`medication_id`) REFERENCES `glaucoma_management_system`.`Medications` (`medication_id`),
  CONSTRAINT `fk_3` FOREIGN KEY (`doctor_id`) REFERENCES `glaucoma_management_system`.`DoctorProfiles` (`doctor_id`),
  CONSTRAINT `fk_4` FOREIGN KEY (`visit_id`) REFERENCES `glaucoma_management_system`.`PatientVisits` (`visit_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `PatientMedications`
--

LOCK TABLES `PatientMedications` WRITE;
/*!40000 ALTER TABLE `PatientMedications` DISABLE KEYS */;
/*!40000 ALTER TABLE `PatientMedications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `PatientProfiles`
--

DROP TABLE IF EXISTS `PatientProfiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `PatientProfiles` (
  `patient_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `hn` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `first_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `date_of_birth` date NOT NULL,
  `gender` enum('male','female','other') COLLATE utf8mb4_unicode_ci NOT NULL,
  `blood_type` enum('A','B','AB','O','unknown') COLLATE utf8mb4_unicode_ci DEFAULT 'unknown',
  `weight` decimal(5,2) DEFAULT NULL,
  `height` decimal(5,2) DEFAULT NULL,
  `address` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `emergency_contact_name` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `emergency_contact_phone` varchar(15) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `emergency_contact_relation` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `primary_doctor_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `consent_to_data_usage` tinyint(1) NOT NULL DEFAULT '0',
  `registration_date` date NOT NULL,
  `insurance_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `insurance_no` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  KEY `idx_patient_hn` (`hn`),
  KEY `idx_patient_name` (`first_name`,`last_name`),
  PRIMARY KEY (`patient_id`) /*T![clustered_index] CLUSTERED */,
  UNIQUE KEY `hn` (`hn`),
  CONSTRAINT `fk_1` FOREIGN KEY (`patient_id`) REFERENCES `glaucoma_management_system`.`Users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `PatientProfiles`
--

LOCK TABLES `PatientProfiles` WRITE;
/*!40000 ALTER TABLE `PatientProfiles` DISABLE KEYS */;
INSERT INTO `PatientProfiles` VALUES ('711e7c46-f791-4260-9af6-14c305492780','HN25923449','สมชาย','ใจดี','1990-01-01','male','A',70.00,170.00,'123 หมู่ 4 ถ.สุขุมวิท แขวงคลองตัน เขตคลองเตย กรุงเทพฯ 10110','สมหญิง ใจดี','0898765432','ภรรยา',NULL,1,'2025-05-04',NULL,NULL),('937260e1-9513-4840-8098-b7c13bbdfc1c','HN25814461','ศศิกานต์','กาญจน์เจริญ','2002-09-17','female','B',45.00,156.00,NULL,'ศศิธร กำลังเกื้อ','0902181763','แม่',NULL,1,'2025-05-05',NULL,NULL),('95321832-9a29-4214-8c4f-13302fd5ed5f','HN25349356','ชามิล','วาดวงพัตร์','2004-08-30','male','O',52.00,176.00,NULL,'ปราณี','0985163680','แม่',NULL,1,'2025-05-04',NULL,NULL),('ca50d22a-ad5b-492d-9ddf-3f27a5a79782','HN25433350','ณัฐวุฒิ ','ศรีสุขใส','2004-08-30','male','O',94.00,178.00,NULL,'สุดา พยาบาล','0828198123','น้า',NULL,1,'2025-05-06',NULL,NULL);
/*!40000 ALTER TABLE `PatientProfiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `PatientRiskAssessments`
--

DROP TABLE IF EXISTS `PatientRiskAssessments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `PatientRiskAssessments` (
  `assessment_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `patient_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `assessment_date` date NOT NULL,
  `overall_risk_score` decimal(5,2) NOT NULL,
  `risk_level` enum('low','medium','high','very_high') COLLATE utf8mb4_unicode_ci NOT NULL,
  `risk_factors` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `iop_trend_analysis` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `medication_adherence_impact` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `visual_field_progression` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `recommended_actions` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY `idx_risk_patient` (`patient_id`),
  KEY `idx_risk_level` (`risk_level`),
  KEY `idx_risk_date` (`assessment_date`),
  PRIMARY KEY (`assessment_id`) /*T![clustered_index] CLUSTERED */,
  KEY `fk_2` (`created_by`),
  CONSTRAINT `fk_1` FOREIGN KEY (`patient_id`) REFERENCES `glaucoma_management_system`.`PatientProfiles` (`patient_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_2` FOREIGN KEY (`created_by`) REFERENCES `glaucoma_management_system`.`Users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `PatientRiskAssessments`
--

LOCK TABLES `PatientRiskAssessments` WRITE;
/*!40000 ALTER TABLE `PatientRiskAssessments` DISABLE KEYS */;
/*!40000 ALTER TABLE `PatientRiskAssessments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `PatientVisits`
--

DROP TABLE IF EXISTS `PatientVisits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `PatientVisits` (
  `visit_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `patient_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `doctor_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `appointment_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `visit_date` date NOT NULL,
  `visit_time` time NOT NULL,
  `visit_type` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `chief_complaint` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `visit_notes` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `diagnosis` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `visit_status` enum('in_progress','completed','cancelled') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'in_progress',
  `payment_status` enum('pending','paid','insurance') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `next_appointment_date` date DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY `idx_visit_patient` (`patient_id`),
  KEY `idx_visit_date` (`visit_date`),
  KEY `idx_visit_status` (`visit_status`),
  PRIMARY KEY (`visit_id`) /*T![clustered_index] CLUSTERED */,
  KEY `fk_2` (`doctor_id`),
  CONSTRAINT `fk_1` FOREIGN KEY (`patient_id`) REFERENCES `glaucoma_management_system`.`PatientProfiles` (`patient_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_2` FOREIGN KEY (`doctor_id`) REFERENCES `glaucoma_management_system`.`DoctorProfiles` (`doctor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `PatientVisits`
--

LOCK TABLES `PatientVisits` WRITE;
/*!40000 ALTER TABLE `PatientVisits` DISABLE KEYS */;
/*!40000 ALTER TABLE `PatientVisits` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `PostSurgeryFollowUps`
--

DROP TABLE IF EXISTS `PostSurgeryFollowUps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `PostSurgeryFollowUps` (
  `follow_up_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `surgery_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `patient_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `doctor_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `follow_up_date` date NOT NULL,
  `days_post_surgery` int(11) NOT NULL,
  `left_eye_iop` decimal(5,2) DEFAULT NULL,
  `right_eye_iop` decimal(5,2) DEFAULT NULL,
  `left_eye_status` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `right_eye_status` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `healing_progress` enum('good','fair','poor') COLLATE utf8mb4_unicode_ci NOT NULL,
  `complications` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `medications_adjusted` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `images_url` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `next_follow_up` date DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `visit_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  KEY `idx_followup_surgery` (`surgery_id`),
  KEY `idx_followup_patient` (`patient_id`),
  KEY `idx_followup_date` (`follow_up_date`),
  PRIMARY KEY (`follow_up_id`) /*T![clustered_index] CLUSTERED */,
  KEY `fk_3` (`doctor_id`),
  KEY `fk_4` (`visit_id`),
  CONSTRAINT `fk_1` FOREIGN KEY (`surgery_id`) REFERENCES `glaucoma_management_system`.`GlaucomaSurgeries` (`surgery_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_2` FOREIGN KEY (`patient_id`) REFERENCES `glaucoma_management_system`.`PatientProfiles` (`patient_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_3` FOREIGN KEY (`doctor_id`) REFERENCES `glaucoma_management_system`.`DoctorProfiles` (`doctor_id`),
  CONSTRAINT `fk_4` FOREIGN KEY (`visit_id`) REFERENCES `glaucoma_management_system`.`PatientVisits` (`visit_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `PostSurgeryFollowUps`
--

LOCK TABLES `PostSurgeryFollowUps` WRITE;
/*!40000 ALTER TABLE `PostSurgeryFollowUps` DISABLE KEYS */;
/*!40000 ALTER TABLE `PostSurgeryFollowUps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ResearchData`
--

DROP TABLE IF EXISTS `ResearchData`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ResearchData` (
  `data_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `research_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `data_category` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `data_type` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `data_content` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `anonymized` tinyint(1) NOT NULL DEFAULT '1',
  `data_date` date NOT NULL,
  `created_by` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `access_level` enum('restricted','research_team','public') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'restricted',
  KEY `idx_research_data_research` (`research_id`),
  KEY `idx_research_data_category` (`data_category`),
  KEY `idx_research_data_date` (`data_date`),
  KEY `idx_research_data_access` (`access_level`),
  PRIMARY KEY (`data_id`) /*T![clustered_index] CLUSTERED */,
  KEY `fk_1` (`created_by`),
  CONSTRAINT `fk_1` FOREIGN KEY (`created_by`) REFERENCES `glaucoma_management_system`.`Users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ResearchData`
--

LOCK TABLES `ResearchData` WRITE;
/*!40000 ALTER TABLE `ResearchData` DISABLE KEYS */;
/*!40000 ALTER TABLE `ResearchData` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `SpecialEyeTests`
--

DROP TABLE IF EXISTS `SpecialEyeTests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `SpecialEyeTests` (
  `test_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `patient_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `doctor_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `test_date` date NOT NULL,
  `test_type` enum('OCT','CTVF','Pachymetry','Gonioscopy','Other') COLLATE utf8mb4_unicode_ci NOT NULL,
  `eye` enum('left','right','both') COLLATE utf8mb4_unicode_ci NOT NULL,
  `test_details` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `results` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `test_images_url` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `report_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `visit_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  KEY `idx_special_test_patient` (`patient_id`),
  KEY `idx_special_test_type` (`test_type`),
  KEY `idx_special_test_date` (`test_date`),
  KEY `idx_special_test_visit` (`visit_id`),
  PRIMARY KEY (`test_id`) /*T![clustered_index] CLUSTERED */,
  KEY `fk_2` (`doctor_id`),
  CONSTRAINT `fk_1` FOREIGN KEY (`patient_id`) REFERENCES `glaucoma_management_system`.`PatientProfiles` (`patient_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_2` FOREIGN KEY (`doctor_id`) REFERENCES `glaucoma_management_system`.`DoctorProfiles` (`doctor_id`),
  CONSTRAINT `fk_3` FOREIGN KEY (`visit_id`) REFERENCES `glaucoma_management_system`.`PatientVisits` (`visit_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `SpecialEyeTests`
--

LOCK TABLES `SpecialEyeTests` WRITE;
/*!40000 ALTER TABLE `SpecialEyeTests` DISABLE KEYS */;
/*!40000 ALTER TABLE `SpecialEyeTests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `StatisticalReports`
--

DROP TABLE IF EXISTS `StatisticalReports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `StatisticalReports` (
  `report_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `report_type` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `report_title` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `report_period` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `report_data` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_by` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_updated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `file_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_public` tinyint(1) NOT NULL DEFAULT '0',
  `access_level` enum('admin','doctor','researcher','public') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'admin',
  KEY `idx_stat_report_type` (`report_type`),
  KEY `idx_stat_report_created` (`created_at`),
  KEY `idx_stat_report_access` (`access_level`),
  PRIMARY KEY (`report_id`) /*T![clustered_index] CLUSTERED */,
  KEY `fk_1` (`created_by`),
  CONSTRAINT `fk_1` FOREIGN KEY (`created_by`) REFERENCES `glaucoma_management_system`.`Users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `StatisticalReports`
--

LOCK TABLES `StatisticalReports` WRITE;
/*!40000 ALTER TABLE `StatisticalReports` DISABLE KEYS */;
/*!40000 ALTER TABLE `StatisticalReports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `SystemSettings`
--

DROP TABLE IF EXISTS `SystemSettings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `SystemSettings` (
  `setting_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `setting_key` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `setting_value` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `setting_description` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `setting_group` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_editable` tinyint(1) NOT NULL DEFAULT '1',
  `data_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  UNIQUE KEY `unq_setting_key` (`setting_key`),
  KEY `idx_setting_group` (`setting_group`),
  PRIMARY KEY (`setting_id`) /*T![clustered_index] CLUSTERED */,
  KEY `fk_1` (`updated_by`),
  CONSTRAINT `fk_1` FOREIGN KEY (`updated_by`) REFERENCES `glaucoma_management_system`.`Users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `SystemSettings`
--

LOCK TABLES `SystemSettings` WRITE;
/*!40000 ALTER TABLE `SystemSettings` DISABLE KEYS */;
/*!40000 ALTER TABLE `SystemSettings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `UserConsents`
--

DROP TABLE IF EXISTS `UserConsents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `UserConsents` (
  `consent_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `patient_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `consent_type` enum('data_processing','marketing','research','data_sharing','special_category') COLLATE utf8mb4_unicode_ci NOT NULL,
  `consent_given` tinyint(1) NOT NULL DEFAULT '0',
  `consent_date` datetime NOT NULL,
  `consent_expiry` datetime DEFAULT NULL,
  `consent_document_version` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `recorded_by` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  KEY `idx_consent_patient` (`patient_id`),
  KEY `idx_consent_type` (`consent_type`),
  PRIMARY KEY (`consent_id`) /*T![clustered_index] CLUSTERED */,
  KEY `fk_2` (`recorded_by`),
  CONSTRAINT `fk_1` FOREIGN KEY (`patient_id`) REFERENCES `glaucoma_management_system`.`PatientProfiles` (`patient_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_2` FOREIGN KEY (`recorded_by`) REFERENCES `glaucoma_management_system`.`Users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `UserConsents`
--

LOCK TABLES `UserConsents` WRITE;
/*!40000 ALTER TABLE `UserConsents` DISABLE KEYS */;
INSERT INTO `UserConsents` VALUES ('2113ced9-7125-4399-94e0-a85a283d4852','ca50d22a-ad5b-492d-9ddf-3f27a5a79782','data_processing',1,'2025-05-06 11:14:35',NULL,'1.0','::1','ca50d22a-ad5b-492d-9ddf-3f27a5a79782'),('45ef3fb1-73b9-43e5-9677-94922f83b7c9','95321832-9a29-4214-8c4f-13302fd5ed5f','data_processing',1,'2025-05-04 16:18:23',NULL,'1.0','127.0.0.1','95321832-9a29-4214-8c4f-13302fd5ed5f'),('557342b1-80d6-4728-9501-177efde064f5','711e7c46-f791-4260-9af6-14c305492780','data_processing',1,'2025-05-04 12:26:24',NULL,'1.0','127.0.0.1','711e7c46-f791-4260-9af6-14c305492780'),('cf45dd0c-87ce-4ccd-98ba-cbd0a8dbd75f','937260e1-9513-4840-8098-b7c13bbdfc1c','data_processing',1,'2025-05-05 09:49:01',NULL,'1.0','127.0.0.1','937260e1-9513-4840-8098-b7c13bbdfc1c');
/*!40000 ALTER TABLE `UserConsents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `UserSessions`
--

DROP TABLE IF EXISTS `UserSessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `UserSessions` (
  `session_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `device_info` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` datetime NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  KEY `idx_sessions_user` (`user_id`),
  KEY `idx_sessions_expiry` (`expires_at`),
  PRIMARY KEY (`session_id`) /*T![clustered_index] CLUSTERED */,
  KEY `idx_sessions_token` (`token`(255)),
  CONSTRAINT `fk_1` FOREIGN KEY (`user_id`) REFERENCES `glaucoma_management_system`.`Users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `UserSessions`
--

LOCK TABLES `UserSessions` WRITE;
/*!40000 ALTER TABLE `UserSessions` DISABLE KEYS */;
INSERT INTO `UserSessions` VALUES ('02e44a13-fe9e-45f5-aa20-cecafdd99915','937260e1-9513-4840-8098-b7c13bbdfc1c','8ee1b7a5-0bf9-4e82-bb23-e950a71999ef','PostmanRuntime/7.43.4','::1','2025-05-05 11:45:04','2025-05-06 18:45:04',1),('0c1cc9c0-84a1-48b9-8ff6-5878e7dd87e7','ca50d22a-ad5b-492d-9ddf-3f27a5a79782','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJjYTUwZDIyYS1hZDViLTQ5MmQtOWRkZi0zZjI3YTVhNzk3ODIiLCJyb2xlIjoicGF0aWVudCIsIm5hdGlvbmFsSWQiOiIzODAxMTAwNDI5NDY1IiwicmVxdWlyZVBhc3N3b3JkQ2hhbmdlIjowLCJpYXQiOjE3NDY3NzE2NDcsImV4cCI6MTc0Njg1ODA0N30.N7uiPoHwbXhT1laAr_9zCKIffYhQyeeJQN1YAGFCKYw','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36','::1','2025-05-09 06:20:47','2025-05-10 13:20:48',1),('1266d0aa-6528-4c9a-977b-422d716a2aba','937260e1-9513-4840-8098-b7c13bbdfc1c','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI5MzcyNjBlMS05NTEzLTQ4NDAtODA5OC1iN2MxM2JiZGZjMWMiLCJyb2xlIjoicGF0aWVudCIsIm5hdGlvbmFsSWQiOiIxODA5OTAyMTY2MjExIiwicmVxdWlyZVBhc3N3b3JkQ2hhbmdlIjowLCJpYXQiOjE3NDY0Mzg4NjEsImV4cCI6MTc0NjUyNTI2MX0.RMhAzGprcJGAF_YX9nBONaBpLulGnkUJ_w9sua3UPTc','PostmanRuntime/7.43.4','127.0.0.1','2025-05-05 09:54:21','2025-05-06 16:54:21',1),('19766bd0-3dc1-4ac6-8436-63986dc334a8','711e7c46-f791-4260-9af6-14c305492780','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI3MTFlN2M0Ni1mNzkxLTQyNjAtOWFmNi0xNGMzMDU0OTI3ODAiLCJyb2xlIjoicGF0aWVudCIsIm5hdGlvbmFsSWQiOiIxODA4MjAwMDIxMDM0IiwicmVxdWlyZVBhc3N3b3JkQ2hhbmdlIjowLCJpYXQiOjE3NDYzNzI5NDksImV4cCI6MTc0NjQ1OTM0OX0.sgECeXmYPKBMAMBqkFV-w2fQUX9rgncRnNKIU8u_bRU','Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Mobile Safari/537.36','127.0.0.1','2025-05-04 15:35:50','2025-05-05 22:35:50',1),('2028d5da-c199-42f7-9f3b-43f1b30e0a26','95321832-9a29-4214-8c4f-13302fd5ed5f','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI5NTMyMTgzMi05YTI5LTQyMTQtOGM0Zi0xMzMwMmZkNWVkNWYiLCJyb2xlIjoicGF0aWVudCIsIm5hdGlvbmFsSWQiOiIxODA5OTAyMjk2ODY3IiwicmVxdWlyZVBhc3N3b3JkQ2hhbmdlIjowLCJpYXQiOjE3NDYzNzU1NDIsImV4cCI6MTc0NjQ2MTk0Mn0.6yxSyuFk21eiHfDu1DVtSOMksphXFRl-C9gLA5Y3dSE','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36','127.0.0.1','2025-05-04 16:19:02','2025-05-05 23:19:03',1),('21902150-b0f7-4d31-b6b3-18b657db5626','937260e1-9513-4840-8098-b7c13bbdfc1c','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI5MzcyNjBlMS05NTEzLTQ4NDAtODA5OC1iN2MxM2JiZGZjMWMiLCJyb2xlIjoicGF0aWVudCIsIm5hdGlvbmFsSWQiOiIxODA5OTAyMTY2MjExIiwicmVxdWlyZVBhc3N3b3JkQ2hhbmdlIjowLCJpYXQiOjE3NDY0OTk3NTAsImV4cCI6MTc0NjU4NjE1MH0.d27mAosKBmL-G9HRVdUjptehxBVq9lC0hkat_vYsBIc','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36','::1','2025-05-06 02:49:10','2025-05-07 09:49:11',1),('341c6349-eac0-4d15-80f3-01a8fe4fa854','ca50d22a-ad5b-492d-9ddf-3f27a5a79782','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJjYTUwZDIyYS1hZDViLTQ5MmQtOWRkZi0zZjI3YTVhNzk3ODIiLCJyb2xlIjoicGF0aWVudCIsIm5hdGlvbmFsSWQiOiIzODAxMTAwNDI5NDY1IiwicmVxdWlyZVBhc3N3b3JkQ2hhbmdlIjowLCJpYXQiOjE3NDY2ODUzNTksImV4cCI6MTc0Njc3MTc1OX0.JAltTGAIapNvRbu4NmY8xS52er7N9SyYcWNYkf-pcRE','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36','::1','2025-05-08 06:22:39','2025-05-09 13:22:39',0),('353a8b8e-ba50-46c5-804c-6bde42c043da','ca50d22a-ad5b-492d-9ddf-3f27a5a79782','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJjYTUwZDIyYS1hZDViLTQ5MmQtOWRkZi0zZjI3YTVhNzk3ODIiLCJyb2xlIjoicGF0aWVudCIsIm5hdGlvbmFsSWQiOiIzODAxMTAwNDI5NDY1IiwicmVxdWlyZVBhc3N3b3JkQ2hhbmdlIjowLCJpYXQiOjE3NDY2MTk0NzAsImV4cCI6MTc0NjcwNTg3MH0.IqWQV7NnRVnbKZHaYDwtYNpvHBXv0ghtcFbIHFU0caU','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36','::1','2025-05-07 12:04:30','2025-05-08 19:04:31',0),('384a1837-19aa-4378-b98f-c6b4e2837818','ca50d22a-ad5b-492d-9ddf-3f27a5a79782','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJjYTUwZDIyYS1hZDViLTQ5MmQtOWRkZi0zZjI3YTVhNzk3ODIiLCJyb2xlIjoicGF0aWVudCIsIm5hdGlvbmFsSWQiOiIzODAxMTAwNDI5NDY1IiwicmVxdWlyZVBhc3N3b3JkQ2hhbmdlIjowLCJpYXQiOjE3NDY1MzAxMjgsImV4cCI6MTc0NjYxNjUyOH0.QGikMK9tupNwyERrRz5h9d0VULGTFgY6ZvglO0DsY9Y','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36','::1','2025-05-06 11:15:28','2025-05-07 18:15:28',1),('38ad3b72-c8df-471b-a1a4-1282d51eb18a','937260e1-9513-4840-8098-b7c13bbdfc1c','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI5MzcyNjBlMS05NTEzLTQ4NDAtODA5OC1iN2MxM2JiZGZjMWMiLCJyb2xlIjoicGF0aWVudCIsIm5hdGlvbmFsSWQiOiIxODA5OTAyMTY2MjExIiwicmVxdWlyZVBhc3N3b3JkQ2hhbmdlIjowLCJpYXQiOjE3NDY0NDU1NTMsImV4cCI6MTc0NjUzMTk1M30._G_hrWQWBYkgfLDMrQvf9pxk79yvpzWqxbzMBzPBOxc','PostmanRuntime/7.43.4','127.0.0.1','2025-05-05 11:45:53','2025-05-06 18:45:54',1),('59208a9b-8319-418c-9250-563cdb1ce0f6','711e7c46-f791-4260-9af6-14c305492780','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI3MTFlN2M0Ni1mNzkxLTQyNjAtOWFmNi0xNGMzMDU0OTI3ODAiLCJyb2xlIjoicGF0aWVudCIsIm5hdGlvbmFsSWQiOiIxODA4MjAwMDIxMDM0IiwicmVxdWlyZVBhc3N3b3JkQ2hhbmdlIjowLCJpYXQiOjE3NDYzNjM3NjMsImV4cCI6MTc0NjQ1MDE2M30.vNztqriXNQSO9Ze8rYpiYpV49XBtMCLWiAO9T7bIb_0','PostmanRuntime/7.43.4','127.0.0.1','2025-05-04 13:02:43','2025-05-05 20:02:43',1),('5f850c38-5789-4281-be6b-1bdb7e5d7228','937260e1-9513-4840-8098-b7c13bbdfc1c','23c68361-fe5b-4560-9fd4-63d618364594','PostmanRuntime/7.43.4','::1','2025-05-05 11:44:00','2025-05-06 18:44:01',1),('6a2edca6-4a42-484c-bbcd-4a4592a4fc02','ca50d22a-ad5b-492d-9ddf-3f27a5a79782','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJjYTUwZDIyYS1hZDViLTQ5MmQtOWRkZi0zZjI3YTVhNzk3ODIiLCJyb2xlIjoicGF0aWVudCIsIm5hdGlvbmFsSWQiOiIzODAxMTAwNDI5NDY1IiwicmVxdWlyZVBhc3N3b3JkQ2hhbmdlIjowLCJpYXQiOjE3NDY3NzQ3MzcsImV4cCI6MTc0Njg2MTEzN30.F9cvvBQVKHdZoxMCa9jBW-5MoNB5TH6On6bPzObnxsk','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36','::1','2025-05-09 07:12:17','2025-05-10 14:12:18',1),('710c7dc6-0355-41a4-9719-a97908e50faf','711e7c46-f791-4260-9af6-14c305492780','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI3MTFlN2M0Ni1mNzkxLTQyNjAtOWFmNi0xNGMzMDU0OTI3ODAiLCJyb2xlIjoicGF0aWVudCIsIm5hdGlvbmFsSWQiOiIxODA4MjAwMDIxMDM0IiwicmVxdWlyZVBhc3N3b3JkQ2hhbmdlIjowLCJpYXQiOjE3NDYzNjM3MTQsImV4cCI6MTc0NjQ1MDExNH0.qc3oAO4EXwgXGFAQIOLqniR4NepiMyQPvVHuixGxGAM','PostmanRuntime/7.43.4','127.0.0.1','2025-05-04 13:01:54','2025-05-05 20:01:55',0),('721a9cc3-d0b1-4634-add9-7ffa543fdeca','711e7c46-f791-4260-9af6-14c305492780','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI3MTFlN2M0Ni1mNzkxLTQyNjAtOWFmNi0xNGMzMDU0OTI3ODAiLCJyb2xlIjoicGF0aWVudCIsIm5hdGlvbmFsSWQiOiIxODA4MjAwMDIxMDM0IiwicmVxdWlyZVBhc3N3b3JkQ2hhbmdlIjowLCJpYXQiOjE3NDYzNjIzOTQsImV4cCI6MTc0NjQ0ODc5NH0.jn3RL_J28t5V5cK0rLJDVScZxL-nRJs5B67JimOnvuw','PostmanRuntime/7.43.4','127.0.0.1','2025-05-04 12:39:54','2025-05-05 19:39:54',1),('8477a8a9-6b3c-489d-8301-ed6c443a3723','711e7c46-f791-4260-9af6-14c305492780','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI3MTFlN2M0Ni1mNzkxLTQyNjAtOWFmNi0xNGMzMDU0OTI3ODAiLCJyb2xlIjoicGF0aWVudCIsIm5hdGlvbmFsSWQiOiIxODA4MjAwMDIxMDM0IiwicmVxdWlyZVBhc3N3b3JkQ2hhbmdlIjowLCJpYXQiOjE3NDYzNjMzMzcsImV4cCI6MTc0NjQ0OTczN30.yxVw-V4Z4LTeeslv5TDcCgHNpJ3FKhERujyPxYQEbhI','PostmanRuntime/7.43.4','127.0.0.1','2025-05-04 12:55:37','2025-05-05 19:55:38',1),('9e2d910e-eb12-4fd7-9ab5-2760ff18841f','711e7c46-f791-4260-9af6-14c305492780','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI3MTFlN2M0Ni1mNzkxLTQyNjAtOWFmNi0xNGMzMDU0OTI3ODAiLCJyb2xlIjoicGF0aWVudCIsIm5hdGlvbmFsSWQiOiIxODA4MjAwMDIxMDM0IiwicmVxdWlyZVBhc3N3b3JkQ2hhbmdlIjowLCJpYXQiOjE3NDYzNzM2MzQsImV4cCI6MTc0NjQ2MDAzNH0.rEnIBfmPfacb0jkfMK-w1cM1KAagtxEtXp1t_SvIXzA','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36','127.0.0.1','2025-05-04 15:47:14','2025-05-05 22:47:15',1),('a4745b71-3470-45e5-b6a9-c3b54ebef386','937260e1-9513-4840-8098-b7c13bbdfc1c','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI5MzcyNjBlMS05NTEzLTQ4NDAtODA5OC1iN2MxM2JiZGZjMWMiLCJyb2xlIjoicGF0aWVudCIsIm5hdGlvbmFsSWQiOiIxODA5OTAyMTY2MjExIiwicmVxdWlyZVBhc3N3b3JkQ2hhbmdlIjowLCJpYXQiOjE3NDY0NDEyMDAsImV4cCI6MTc0NjUyNzYwMH0.qykhIUoIfllve-xay-OdNaLFD5xyxlvmFt0DvoeK18o','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36','127.0.0.1','2025-05-05 10:33:21','2025-05-06 17:33:21',1),('aac38b8e-89c8-4440-bc74-9a92f4b04458','937260e1-9513-4840-8098-b7c13bbdfc1c','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI5MzcyNjBlMS05NTEzLTQ4NDAtODA5OC1iN2MxM2JiZGZjMWMiLCJyb2xlIjoicGF0aWVudCIsIm5hdGlvbmFsSWQiOiIxODA5OTAyMTY2MjExIiwicmVxdWlyZVBhc3N3b3JkQ2hhbmdlIjowLCJpYXQiOjE3NDY0MzkxNDMsImV4cCI6MTc0NjUyNTU0M30.8Cjt2FWu1MQF-aTr0Hp0TL2t9cDfZCjdBYnBpxUie94','PostmanRuntime/7.43.4','127.0.0.1','2025-05-05 09:59:03','2025-05-06 16:59:03',1),('b045749f-2b75-4085-8183-654fd18350b1','937260e1-9513-4840-8098-b7c13bbdfc1c','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI5MzcyNjBlMS05NTEzLTQ4NDAtODA5OC1iN2MxM2JiZGZjMWMiLCJyb2xlIjoicGF0aWVudCIsIm5hdGlvbmFsSWQiOiIxODA5OTAyMTY2MjExIiwicmVxdWlyZVBhc3N3b3JkQ2hhbmdlIjowLCJpYXQiOjE3NDY0Mzg1NzcsImV4cCI6MTc0NjUyNDk3N30.GyYFDJjNhF3muPGOhDsp5K6XBSGacCknv8DpObJ-3LU','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36','127.0.0.1','2025-05-05 09:49:37','2025-05-06 16:49:38',1),('c88289aa-f908-4385-857d-d0adb0ef5555','937260e1-9513-4840-8098-b7c13bbdfc1c','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI5MzcyNjBlMS05NTEzLTQ4NDAtODA5OC1iN2MxM2JiZGZjMWMiLCJyb2xlIjoicGF0aWVudCIsIm5hdGlvbmFsSWQiOiIxODA5OTAyMTY2MjExIiwicmVxdWlyZVBhc3N3b3JkQ2hhbmdlIjowLCJpYXQiOjE3NDY0NTM5MzQsImV4cCI6MTc0NjU0MDMzNH0.C66AIHLpmVdv3C1KWLe8HcHc_-zuhb58txdfZRjb6-E','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36','::1','2025-05-05 14:05:34','2025-05-06 21:05:34',1),('f2cc3733-fd92-4506-b1bc-2b6b09e8738b','711e7c46-f791-4260-9af6-14c305492780','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI3MTFlN2M0Ni1mNzkxLTQyNjAtOWFmNi0xNGMzMDU0OTI3ODAiLCJyb2xlIjoicGF0aWVudCIsIm5hdGlvbmFsSWQiOiIxODA4MjAwMDIxMDM0IiwicmVxdWlyZVBhc3N3b3JkQ2hhbmdlIjowLCJpYXQiOjE3NDYzNjI4NzMsImV4cCI6MTc0NjQ0OTI3M30.rahnSTT-Ksp427UTOKjgS3pqtvbe4OqaydE1dVutzZ4','PostmanRuntime/7.43.4','127.0.0.1','2025-05-04 12:47:53','2025-05-05 19:47:54',1),('fa214ea9-c13f-472f-94cc-21bebe0015ef','937260e1-9513-4840-8098-b7c13bbdfc1c','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI5MzcyNjBlMS05NTEzLTQ4NDAtODA5OC1iN2MxM2JiZGZjMWMiLCJyb2xlIjoicGF0aWVudCIsIm5hdGlvbmFsSWQiOiIxODA5OTAyMTY2MjExIiwicmVxdWlyZVBhc3N3b3JkQ2hhbmdlIjowLCJpYXQiOjE3NDY0OTk5NDEsImV4cCI6MTc0NjU4NjM0MX0.Fb-_JGDjcGmPw_7d1pqT7VCZFK8nXqm6D6jJ0fjKHTw','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36','::1','2025-05-06 02:52:21','2025-05-07 09:52:22',0),('fb6e5d69-f455-4651-b5b4-8fd1d2474e42','ca50d22a-ad5b-492d-9ddf-3f27a5a79782','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJjYTUwZDIyYS1hZDViLTQ5MmQtOWRkZi0zZjI3YTVhNzk3ODIiLCJyb2xlIjoicGF0aWVudCIsIm5hdGlvbmFsSWQiOiIzODAxMTAwNDI5NDY1IiwicmVxdWlyZVBhc3N3b3JkQ2hhbmdlIjowLCJpYXQiOjE3NDY2MTczNTYsImV4cCI6MTc0NjcwMzc1Nn0.Tq3bymAphdhXLJ2dI9wjVTLede1TfqptMDQV1siYoAk','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36','::1','2025-05-07 11:29:16','2025-05-08 18:29:17',0);
/*!40000 ALTER TABLE `UserSessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `UserSettings`
--

DROP TABLE IF EXISTS `UserSettings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `UserSettings` (
  `setting_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `language` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT 'th',
  `theme` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'light',
  `font_size` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT 'medium',
  `notification_preferences` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `privacy_settings` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `time_zone` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'Asia/Bangkok',
  `quiet_hours_start` time DEFAULT NULL,
  `quiet_hours_end` time DEFAULT NULL,
  `default_view` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `unq_user_settings` (`user_id`),
  PRIMARY KEY (`setting_id`) /*T![clustered_index] CLUSTERED */,
  CONSTRAINT `fk_1` FOREIGN KEY (`user_id`) REFERENCES `glaucoma_management_system`.`Users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `UserSettings`
--

LOCK TABLES `UserSettings` WRITE;
/*!40000 ALTER TABLE `UserSettings` DISABLE KEYS */;
INSERT INTO `UserSettings` VALUES ('16195ce1-8ae1-4631-aeb4-80cd099f4e32','ca50d22a-ad5b-492d-9ddf-3f27a5a79782','th','blue','large',NULL,NULL,'Asia/Bangkok',NULL,NULL,NULL,'2025-05-07 11:53:03','2025-05-08 09:44:43');
/*!40000 ALTER TABLE `UserSettings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Users`
--

DROP TABLE IF EXISTS `Users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Users` (
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_card` varchar(13) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` enum('patient','doctor','admin','nurse') COLLATE utf8mb4_unicode_ci NOT NULL,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(15) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_login` datetime DEFAULT NULL,
  `status` enum('active','inactive','suspended') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `require_password_change` tinyint(1) NOT NULL DEFAULT '1',
  `two_fa_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `account_locked` tinyint(1) NOT NULL DEFAULT '0',
  `account_locked_until` datetime DEFAULT NULL,
  `password_expires_at` datetime DEFAULT NULL,
  `failed_login_attempts` int(11) NOT NULL DEFAULT '0',
  `last_password_change` datetime DEFAULT NULL,
  `security_question` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `security_answer_hash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  KEY `idx_users_username` (`username`),
  KEY `idx_users_status` (`status`),
  KEY `idx_users_role` (`role`),
  PRIMARY KEY (`user_id`) /*T![clustered_index] CLUSTERED */,
  UNIQUE KEY `id_card` (`id_card`),
  UNIQUE KEY `username` (`username`),
  KEY `idx_users_account_locked` (`account_locked`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Users`
--

LOCK TABLES `Users` WRITE;
/*!40000 ALTER TABLE `Users` DISABLE KEYS */;
INSERT INTO `Users` VALUES ('711e7c46-f791-4260-9af6-14c305492780','1808200021034','patient','somchai123','$2b$10$BadcVmTtT0Cif5J5nMehJOJS1aPQ98MVXR.zqpuv8llSEECC6xDK6','somchai@example.com','0812345678','2025-05-04 12:26:24','2025-05-06 06:27:32','2025-05-04 15:47:14','active',0,0,1,'2025-05-06 13:57:32',NULL,7,'2025-05-04 13:04:19','ชื่อสัตว์เลี้ยงตัวแรกของคุณคืออะไร?','$2b$10$0qXOkQiLvgcV99KvhJCHgubvzxrRJ3z3weVITcJvRsUZiFWB5rypi'),('937260e1-9513-4840-8098-b7c13bbdfc1c','1809902166211','patient','ศศิกานต์ กาญจน์เจริญ','$2b$10$N7lDYMT/gzWAmU.gkwruz.mOn8GG9yEqGTsabrmdKk4sYClQADUKa','sasikankanjaroen@gmail.com','0639236540','2025-05-05 09:49:01','2025-05-06 02:52:21','2025-05-06 02:52:21','active',0,0,0,NULL,NULL,0,NULL,NULL,NULL),('95321832-9a29-4214-8c4f-13302fd5ed5f','1809902296867','patient','1809902296867','$2b$10$LvXPP62B69pirqDQH2APnOU2.xkpGagEsW63b.Wnu3FStCiFEpp7y',NULL,'0614915317','2025-05-04 16:18:22','2025-05-05 09:40:06','2025-05-04 16:19:02','active',0,1,1,'2025-05-05 17:10:07',NULL,7,NULL,'mother_maiden_name','$2b$10$apj9EBRpmtUKOlIC/OerJelUJOyhYb66ibqrnSTZHDNG7K5IS/XL2'),('ca50d22a-ad5b-492d-9ddf-3f27a5a79782','3801100429465','patient','3801100429465','$2b$10$7DQnQFSrLkiKiYULqcftse/tR9dqgbsfre5uZInfL.fqqhgu1ATtq',NULL,'0825303910','2025-05-06 11:14:35','2025-05-09 07:12:17','2025-05-09 07:12:17','active',0,0,0,NULL,NULL,0,NULL,'mother_maiden_name','$2b$10$zJAornK8lgw.c4pH2wyYm.uv1.Y030kcpzg1jtNBwEmGeI5eEa6Ua');
/*!40000 ALTER TABLE `Users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `VisualFieldTests`
--

DROP TABLE IF EXISTS `VisualFieldTests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `VisualFieldTests` (
  `test_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `patient_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `doctor_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `test_date` date NOT NULL,
  `test_type` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `left_eye_md` decimal(5,2) DEFAULT NULL,
  `right_eye_md` decimal(5,2) DEFAULT NULL,
  `left_eye_psd` decimal(5,2) DEFAULT NULL,
  `right_eye_psd` decimal(5,2) DEFAULT NULL,
  `left_eye_vfi` decimal(5,2) DEFAULT NULL,
  `right_eye_vfi` decimal(5,2) DEFAULT NULL,
  `left_eye_reliability` enum('high','medium','low') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `right_eye_reliability` enum('high','medium','low') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `test_strategy` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `left_eye_image_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `right_eye_image_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pdf_report_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `visit_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  KEY `idx_vf_patient` (`patient_id`),
  KEY `idx_vf_date` (`test_date`),
  KEY `idx_vf_visit` (`visit_id`),
  PRIMARY KEY (`test_id`) /*T![clustered_index] CLUSTERED */,
  KEY `fk_2` (`doctor_id`),
  CONSTRAINT `fk_1` FOREIGN KEY (`patient_id`) REFERENCES `glaucoma_management_system`.`PatientProfiles` (`patient_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_2` FOREIGN KEY (`doctor_id`) REFERENCES `glaucoma_management_system`.`DoctorProfiles` (`doctor_id`),
  CONSTRAINT `fk_3` FOREIGN KEY (`visit_id`) REFERENCES `glaucoma_management_system`.`PatientVisits` (`visit_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `VisualFieldTests`
--

LOCK TABLES `VisualFieldTests` WRITE;
/*!40000 ALTER TABLE `VisualFieldTests` DISABLE KEYS */;
/*!40000 ALTER TABLE `VisualFieldTests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `otp_codes`
--

DROP TABLE IF EXISTS `otp_codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `otp_codes` (
  `id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('email','phone') COLLATE utf8mb4_unicode_ci NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `used` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`) /*T![clustered_index] CLUSTERED */,
  KEY `fk_1` (`user_id`),
  CONSTRAINT `fk_1` FOREIGN KEY (`user_id`) REFERENCES `glaucoma_management_system`.`Users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `otp_codes`
--

LOCK TABLES `otp_codes` WRITE;
/*!40000 ALTER TABLE `otp_codes` DISABLE KEYS */;
/*!40000 ALTER TABLE `otp_codes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `used` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`) /*T![clustered_index] CLUSTERED */,
  KEY `fk_1` (`user_id`),
  CONSTRAINT `fk_1` FOREIGN KEY (`user_id`) REFERENCES `glaucoma_management_system`.`Users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `refresh_tokens`
--

DROP TABLE IF EXISTS `refresh_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `refresh_tokens` (
  `id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `is_revoked` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`) /*T![clustered_index] CLUSTERED */,
  KEY `fk_1` (`user_id`),
  CONSTRAINT `fk_1` FOREIGN KEY (`user_id`) REFERENCES `glaucoma_management_system`.`Users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `refresh_tokens`
--

LOCK TABLES `refresh_tokens` WRITE;
/*!40000 ALTER TABLE `refresh_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `refresh_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_logs`
--

DROP TABLE IF EXISTS `user_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_logs` (
  `log_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `action` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `details` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`) /*T![clustered_index] CLUSTERED */,
  KEY `fk_1` (`user_id`),
  CONSTRAINT `fk_1` FOREIGN KEY (`user_id`) REFERENCES `glaucoma_management_system`.`Users` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_logs`
--

LOCK TABLES `user_logs` WRITE;
/*!40000 ALTER TABLE `user_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_logs` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-05-13 14:42:06
