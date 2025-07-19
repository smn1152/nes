/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-11.8.2-MariaDB, for osx10.20 (arm64)
--
-- Host: 127.0.0.1    Database: salbion_group
-- ------------------------------------------------------
-- Server version	11.8.2-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Table structure for table `activity_log`
--

DROP TABLE IF EXISTS `activity_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `activity_log` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `log_name` varchar(255) DEFAULT NULL,
  `description` text NOT NULL,
  `subject_type` varchar(255) DEFAULT NULL,
  `event` varchar(255) DEFAULT NULL,
  `subject_id` bigint(20) unsigned DEFAULT NULL,
  `causer_type` varchar(255) DEFAULT NULL,
  `causer_id` bigint(20) unsigned DEFAULT NULL,
  `properties` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`properties`)),
  `batch_uuid` char(36) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `subject` (`subject_type`,`subject_id`),
  KEY `causer` (`causer_type`,`causer_id`),
  KEY `activity_log_log_name_index` (`log_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activity_log`
--

LOCK TABLES `activity_log` WRITE;
/*!40000 ALTER TABLE `activity_log` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `activity_log` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `bans`
--

DROP TABLE IF EXISTS `bans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `bans` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `bannable_type` varchar(255) NOT NULL,
  `bannable_id` bigint(20) unsigned NOT NULL,
  `created_by_type` varchar(255) DEFAULT NULL,
  `created_by_id` bigint(20) unsigned DEFAULT NULL,
  `comment` text DEFAULT NULL,
  `expired_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `bans_bannable_type_bannable_id_index` (`bannable_type`,`bannable_id`),
  KEY `bans_created_by_type_created_by_id_index` (`created_by_type`,`created_by_id`),
  KEY `bans_expired_at_index` (`expired_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bans`
--

LOCK TABLES `bans` WRITE;
/*!40000 ALTER TABLE `bans` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `bans` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `cache_locks`
--

DROP TABLE IF EXISTS `cache_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_locks`
--

LOCK TABLES `cache_locks` WRITE;
/*!40000 ALTER TABLE `cache_locks` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `cache_locks` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `color` varchar(7) NOT NULL DEFAULT '#667eea',
  `icon` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `sort_order` int(10) unsigned NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `categories_slug_unique` (`slug`),
  KEY `categories_is_active_sort_order_index` (`is_active`,`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `company_settings`
--

DROP TABLE IF EXISTS `company_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `company_settings` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `company_settings`
--

LOCK TABLES `company_settings` WRITE;
/*!40000 ALTER TABLE `company_settings` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `company_settings` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `divisions`
--

DROP TABLE IF EXISTS `divisions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `divisions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `divisions`
--

LOCK TABLES `divisions` WRITE;
/*!40000 ALTER TABLE `divisions` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `divisions` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `failed_jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_jobs`
--

LOCK TABLES `failed_jobs` WRITE;
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `innovation_stories`
--

DROP TABLE IF EXISTS `innovation_stories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `innovation_stories` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `innovation_stories`
--

LOCK TABLES `innovation_stories` WRITE;
/*!40000 ALTER TABLE `innovation_stories` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `innovation_stories` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `job_batches`
--

DROP TABLE IF EXISTS `job_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_batches`
--

LOCK TABLES `job_batches` WRITE;
/*!40000 ALTER TABLE `job_batches` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `job_batches` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) unsigned NOT NULL,
  `reserved_at` int(10) unsigned DEFAULT NULL,
  `available_at` int(10) unsigned NOT NULL,
  `created_at` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `locations`
--

DROP TABLE IF EXISTS `locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `locations` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `locations`
--

LOCK TABLES `locations` WRITE;
/*!40000 ALTER TABLE `locations` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `locations` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `media`
--

DROP TABLE IF EXISTS `media`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `media` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `model_type` varchar(255) NOT NULL,
  `model_id` bigint(20) unsigned NOT NULL,
  `uuid` char(36) DEFAULT NULL,
  `collection_name` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `mime_type` varchar(255) DEFAULT NULL,
  `disk` varchar(255) NOT NULL,
  `conversions_disk` varchar(255) DEFAULT NULL,
  `size` bigint(20) unsigned NOT NULL,
  `manipulations` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`manipulations`)),
  `custom_properties` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`custom_properties`)),
  `generated_conversions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`generated_conversions`)),
  `responsive_images` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`responsive_images`)),
  `order_column` int(10) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `media_uuid_unique` (`uuid`),
  KEY `media_model_type_model_id_index` (`model_type`,`model_id`),
  KEY `media_order_column_index` (`order_column`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `media`
--

LOCK TABLES `media` WRITE;
/*!40000 ALTER TABLE `media` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `media` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `migrations` VALUES
(31,'0001_01_01_000000_create_users_table',1),
(32,'0001_01_01_000001_create_cache_table',1),
(33,'0001_01_01_000002_create_jobs_table',1),
(34,'2025_07_18_195022_create_categories_table',1),
(35,'2025_07_18_195022_create_products_table',1),
(36,'2025_07_18_195023_create_company_settings_table',1),
(37,'2025_07_18_195023_create_pages_table',1),
(38,'2025_07_18_195023_create_permission_tables',1),
(39,'2025_07_18_195024_create_activity_log_table',1),
(40,'2025_07_18_195024_create_media_table',1),
(41,'2025_07_18_195025_add_event_column_to_activity_log_table',2),
(42,'2025_07_18_195026_add_batch_uuid_column_to_activity_log_table',2),
(43,'2025_07_18_212221_create_divisions_table',2),
(44,'2025_07_18_212221_create_locations_table',2),
(45,'2025_07_18_212222_add_division_fields_to_products_table',2),
(46,'2025_07_18_212222_create_innovation_stories_table',2),
(47,'2017_03_04_000000_create_bans_table',3),
(48,'2025_07_18_225602_create_pulse_tables',3),
(49,'20250719_000831_create_settings_table',4);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `model_has_permissions`
--

DROP TABLE IF EXISTS `model_has_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `model_has_permissions` (
  `permission_id` bigint(20) unsigned NOT NULL,
  `model_type` varchar(255) NOT NULL,
  `model_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`permission_id`,`model_id`,`model_type`),
  KEY `model_has_permissions_model_id_model_type_index` (`model_id`,`model_type`),
  CONSTRAINT `model_has_permissions_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `model_has_permissions`
--

LOCK TABLES `model_has_permissions` WRITE;
/*!40000 ALTER TABLE `model_has_permissions` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `model_has_permissions` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `model_has_roles`
--

DROP TABLE IF EXISTS `model_has_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `model_has_roles` (
  `role_id` bigint(20) unsigned NOT NULL,
  `model_type` varchar(255) NOT NULL,
  `model_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`role_id`,`model_id`,`model_type`),
  KEY `model_has_roles_model_id_model_type_index` (`model_id`,`model_type`),
  CONSTRAINT `model_has_roles_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `model_has_roles`
--

LOCK TABLES `model_has_roles` WRITE;
/*!40000 ALTER TABLE `model_has_roles` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `model_has_roles` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `pages`
--

DROP TABLE IF EXISTS `pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pages` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `content` longtext NOT NULL,
  `excerpt` text DEFAULT NULL,
  `template` varchar(255) NOT NULL DEFAULT 'default',
  `meta_title` varchar(255) DEFAULT NULL,
  `meta_description` text DEFAULT NULL,
  `meta_keywords` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`meta_keywords`)),
  `status` enum('draft','published','archived') NOT NULL DEFAULT 'draft',
  `is_featured` tinyint(1) NOT NULL DEFAULT 0,
  `published_at` timestamp NULL DEFAULT NULL,
  `user_id` bigint(20) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pages_slug_unique` (`slug`),
  KEY `pages_user_id_foreign` (`user_id`),
  KEY `pages_status_published_at_index` (`status`,`published_at`),
  KEY `pages_is_featured_status_index` (`is_featured`,`status`),
  CONSTRAINT `pages_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pages`
--

LOCK TABLES `pages` WRITE;
/*!40000 ALTER TABLE `pages` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `pages` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `permissions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `guard_name` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `permissions_name_guard_name_unique` (`name`,`guard_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permissions`
--

LOCK TABLES `permissions` WRITE;
/*!40000 ALTER TABLE `permissions` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `permissions` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `short_description` text DEFAULT NULL,
  `description` longtext NOT NULL,
  `price` decimal(12,2) DEFAULT NULL,
  `sku` varchar(255) DEFAULT NULL,
  `specifications` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`specifications`)),
  `features` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`features`)),
  `technical_docs` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`technical_docs`)),
  `installation_notes` text DEFAULT NULL,
  `meta_title` varchar(255) DEFAULT NULL,
  `meta_description` text DEFAULT NULL,
  `keywords` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`keywords`)),
  `is_featured` tinyint(1) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `launch_date` timestamp NULL DEFAULT NULL,
  `category_id` bigint(20) unsigned NOT NULL,
  `user_id` bigint(20) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `products_slug_unique` (`slug`),
  UNIQUE KEY `products_sku_unique` (`sku`),
  KEY `products_user_id_foreign` (`user_id`),
  KEY `products_is_active_is_featured_index` (`is_active`,`is_featured`),
  KEY `products_category_id_is_active_index` (`category_id`,`is_active`),
  CONSTRAINT `products_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE,
  CONSTRAINT `products_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `pulse_aggregates`
--

DROP TABLE IF EXISTS `pulse_aggregates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pulse_aggregates` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `bucket` int(10) unsigned NOT NULL,
  `period` mediumint(8) unsigned NOT NULL,
  `type` varchar(255) NOT NULL,
  `key` mediumtext NOT NULL,
  `key_hash` binary(16) GENERATED ALWAYS AS (unhex(md5(`key`))) VIRTUAL,
  `aggregate` varchar(255) NOT NULL,
  `value` decimal(20,2) NOT NULL,
  `count` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pulse_aggregates_bucket_period_type_aggregate_key_hash_unique` (`bucket`,`period`,`type`,`aggregate`,`key_hash`),
  KEY `pulse_aggregates_period_bucket_index` (`period`,`bucket`),
  KEY `pulse_aggregates_type_index` (`type`),
  KEY `pulse_aggregates_period_type_aggregate_bucket_index` (`period`,`type`,`aggregate`,`bucket`)
) ENGINE=InnoDB AUTO_INCREMENT=465 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pulse_aggregates`
--

LOCK TABLES `pulse_aggregates` WRITE;
/*!40000 ALTER TABLE `pulse_aggregates` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `pulse_aggregates` VALUES
(1,1752879360,60,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„','count',2.00,NULL),
(2,1752879240,360,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„','count',2.00,NULL),
(3,1752878880,1440,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„','count',56.00,NULL),
(4,1752871680,10080,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„','count',56.00,NULL),
(5,1752879360,60,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„','max',1752879363.00,NULL),
(6,1752879240,360,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„','max',1752879363.00,NULL),
(7,1752878880,1440,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„','max',1752880203.00,NULL),
(8,1752871680,10080,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„','max',1752880203.00,NULL),
(9,1752880080,60,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„','count',16.00,NULL),
(10,1752879960,360,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„','count',54.00,NULL),
(13,1752880080,60,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„','max',1752880135.00,NULL),
(14,1752879960,360,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„','max',1752880203.00,NULL),
(33,1752880080,60,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"database\\/migrations\\/2025_07_18_230841_create_pulse_tables.php:18\"]','-D8èa· §º1ú◊fjç—','count',2.00,NULL),
(34,1752879960,360,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"database\\/migrations\\/2025_07_18_230841_create_pulse_tables.php:18\"]','-D8èa· §º1ú◊fjç—','count',4.00,NULL),
(35,1752878880,1440,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"database\\/migrations\\/2025_07_18_230841_create_pulse_tables.php:18\"]','-D8èa· §º1ú◊fjç—','count',4.00,NULL),
(36,1752871680,10080,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"database\\/migrations\\/2025_07_18_230841_create_pulse_tables.php:18\"]','-D8èa· §º1ú◊fjç—','count',4.00,NULL),
(41,1752880080,60,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"database\\/migrations\\/2025_07_18_230841_create_pulse_tables.php:18\"]','-D8èa· §º1ú◊fjç—','max',1752880120.00,NULL),
(42,1752879960,360,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"database\\/migrations\\/2025_07_18_230841_create_pulse_tables.php:18\"]','-D8èa· §º1ú◊fjç—','max',1752880203.00,NULL),
(43,1752878880,1440,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"database\\/migrations\\/2025_07_18_230841_create_pulse_tables.php:18\"]','-D8èa· §º1ú◊fjç—','max',1752880203.00,NULL),
(44,1752871680,10080,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"database\\/migrations\\/2025_07_18_230841_create_pulse_tables.php:18\"]','-D8èa· §º1ú◊fjç—','max',1752880203.00,NULL),
(81,1752880140,60,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„','count',28.00,NULL),
(85,1752880140,60,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„','max',1752880193.00,NULL),
(193,1752880200,60,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„','count',10.00,NULL),
(197,1752880200,60,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„','max',1752880203.00,NULL),
(209,1752880200,60,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"database\\/migrations\\/2025_07_18_230841_create_pulse_tables.php:18\"]','-D8èa· §º1ú◊fjç—','count',2.00,NULL),
(217,1752880200,60,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"database\\/migrations\\/2025_07_18_230841_create_pulse_tables.php:18\"]','-D8èa· §º1ú◊fjç—','max',1752880203.00,NULL),
(241,1752927420,60,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„','count',28.00,NULL),
(242,1752927120,360,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„','count',28.00,NULL),
(243,1752926400,1440,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„','count',50.00,NULL),
(244,1752922080,10080,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„','count',50.00,NULL),
(245,1752927420,60,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„','max',1752927478.00,NULL),
(246,1752927120,360,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„','max',1752927478.00,NULL),
(247,1752926400,1440,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„','max',1752927532.00,NULL),
(248,1752922080,10080,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„','max',1752927532.00,NULL),
(273,1752927420,60,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"database\\/migrations\\/2025_07_18_230841_create_pulse_tables.php:18\"]','-D8èa· §º1ú◊fjç—','count',4.00,NULL),
(274,1752927120,360,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"database\\/migrations\\/2025_07_18_230841_create_pulse_tables.php:18\"]','-D8èa· §º1ú◊fjç—','count',4.00,NULL),
(275,1752926400,1440,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"database\\/migrations\\/2025_07_18_230841_create_pulse_tables.php:18\"]','-D8èa· §º1ú◊fjç—','count',4.00,NULL),
(276,1752922080,10080,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"database\\/migrations\\/2025_07_18_230841_create_pulse_tables.php:18\"]','-D8èa· §º1ú◊fjç—','count',4.00,NULL),
(281,1752927420,60,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"database\\/migrations\\/2025_07_18_230841_create_pulse_tables.php:18\"]','-D8èa· §º1ú◊fjç—','max',1752927459.00,NULL),
(282,1752927120,360,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"database\\/migrations\\/2025_07_18_230841_create_pulse_tables.php:18\"]','-D8èa· §º1ú◊fjç—','max',1752927459.00,NULL),
(283,1752926400,1440,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"database\\/migrations\\/2025_07_18_230841_create_pulse_tables.php:18\"]','-D8èa· §º1ú◊fjç—','max',1752927459.00,NULL),
(284,1752922080,10080,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"database\\/migrations\\/2025_07_18_230841_create_pulse_tables.php:18\"]','-D8èa· §º1ú◊fjç—','max',1752927459.00,NULL),
(289,1752927420,60,'exception','[\"ParseError\",\"app\\/Models\\/Category.php:16\"]','f‰€1é&<í˝ÀèÑÖ','count',2.00,NULL),
(290,1752927120,360,'exception','[\"ParseError\",\"app\\/Models\\/Category.php:16\"]','f‰€1é&<í˝ÀèÑÖ','count',2.00,NULL),
(291,1752926400,1440,'exception','[\"ParseError\",\"app\\/Models\\/Category.php:16\"]','f‰€1é&<í˝ÀèÑÖ','count',2.00,NULL),
(292,1752922080,10080,'exception','[\"ParseError\",\"app\\/Models\\/Category.php:16\"]','f‰€1é&<í˝ÀèÑÖ','count',2.00,NULL),
(297,1752927420,60,'exception','[\"ParseError\",\"app\\/Models\\/Category.php:16\"]','f‰€1é&<í˝ÀèÑÖ','max',1752927435.00,NULL),
(298,1752927120,360,'exception','[\"ParseError\",\"app\\/Models\\/Category.php:16\"]','f‰€1é&<í˝ÀèÑÖ','max',1752927435.00,NULL),
(299,1752926400,1440,'exception','[\"ParseError\",\"app\\/Models\\/Category.php:16\"]','f‰€1é&<í˝ÀèÑÖ','max',1752927435.00,NULL),
(300,1752922080,10080,'exception','[\"ParseError\",\"app\\/Models\\/Category.php:16\"]','f‰€1é&<í˝ÀèÑÖ','max',1752927435.00,NULL),
(377,1752927480,60,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„','count',22.00,NULL),
(378,1752927480,360,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„','count',22.00,NULL),
(381,1752927480,60,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„','max',1752927532.00,NULL),
(382,1752927480,360,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„','max',1752927532.00,NULL);
/*!40000 ALTER TABLE `pulse_aggregates` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `pulse_entries`
--

DROP TABLE IF EXISTS `pulse_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pulse_entries` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `timestamp` int(10) unsigned NOT NULL,
  `type` varchar(255) NOT NULL,
  `key` mediumtext NOT NULL,
  `key_hash` binary(16) GENERATED ALWAYS AS (unhex(md5(`key`))) VIRTUAL,
  `value` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `pulse_entries_timestamp_index` (`timestamp`),
  KEY `pulse_entries_type_index` (`type`),
  KEY `pulse_entries_key_hash_index` (`key_hash`),
  KEY `pulse_entries_timestamp_type_key_hash_value_index` (`timestamp`,`type`,`key_hash`,`value`)
) ENGINE=InnoDB AUTO_INCREMENT=117 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pulse_entries`
--

LOCK TABLES `pulse_entries` WRITE;
/*!40000 ALTER TABLE `pulse_entries` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `pulse_entries` VALUES
(1,1752879363,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752879363),
(2,1752879363,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752879363),
(3,1752880118,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880118),
(4,1752880118,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880118),
(5,1752880119,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880119),
(6,1752880119,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880119),
(7,1752880120,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880120),
(8,1752880120,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880120),
(9,1752880120,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"database\\/migrations\\/2025_07_18_230841_create_pulse_tables.php:18\"]','-D8èa· §º1ú◊fjç—',1752880120),
(10,1752880120,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"database\\/migrations\\/2025_07_18_230841_create_pulse_tables.php:18\"]','-D8èa· §º1ú◊fjç—',1752880120),
(11,1752880120,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880120),
(12,1752880120,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880120),
(13,1752880126,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880126),
(14,1752880126,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880126),
(15,1752880127,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880127),
(16,1752880127,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880127),
(17,1752880134,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880134),
(18,1752880134,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880134),
(19,1752880135,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880135),
(20,1752880135,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880135),
(21,1752880142,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880142),
(22,1752880142,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880142),
(23,1752880143,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880143),
(24,1752880143,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880143),
(25,1752880152,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880152),
(26,1752880152,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880152),
(27,1752880152,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880152),
(28,1752880152,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880152),
(29,1752880160,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880160),
(30,1752880160,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880160),
(31,1752880161,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880161),
(32,1752880161,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880161),
(33,1752880168,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880168),
(34,1752880168,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880168),
(35,1752880169,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880169),
(36,1752880169,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880169),
(37,1752880177,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880177),
(38,1752880177,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880177),
(39,1752880177,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880177),
(40,1752880177,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880177),
(41,1752880185,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880185),
(42,1752880185,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880185),
(43,1752880185,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880185),
(44,1752880185,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880185),
(45,1752880193,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880193),
(46,1752880193,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880193),
(47,1752880193,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880193),
(48,1752880193,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880193),
(49,1752880201,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880201),
(50,1752880201,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880201),
(51,1752880201,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880201),
(52,1752880201,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880201),
(53,1752880203,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"database\\/migrations\\/2025_07_18_230841_create_pulse_tables.php:18\"]','-D8èa· §º1ú◊fjç—',1752880203),
(54,1752880203,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"database\\/migrations\\/2025_07_18_230841_create_pulse_tables.php:18\"]','-D8èa· §º1ú◊fjç—',1752880203),
(55,1752880203,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880203),
(56,1752880203,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880203),
(57,1752880203,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880203),
(58,1752880203,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880203),
(59,1752880203,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880203),
(60,1752880203,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752880203),
(61,1752927432,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927432),
(62,1752927432,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927432),
(63,1752927432,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927432),
(64,1752927432,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927432),
(65,1752927433,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927433),
(66,1752927433,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927433),
(67,1752927433,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927433),
(68,1752927433,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927433),
(69,1752927434,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"database\\/migrations\\/2025_07_18_230841_create_pulse_tables.php:18\"]','-D8èa· §º1ú◊fjç—',1752927434),
(70,1752927434,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"database\\/migrations\\/2025_07_18_230841_create_pulse_tables.php:18\"]','-D8èa· §º1ú◊fjç—',1752927434),
(71,1752927434,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927434),
(72,1752927434,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927434),
(73,1752927435,'exception','[\"ParseError\",\"app\\/Models\\/Category.php:16\"]','f‰€1é&<í˝ÀèÑÖ',1752927435),
(74,1752927435,'exception','[\"ParseError\",\"app\\/Models\\/Category.php:16\"]','f‰€1é&<í˝ÀèÑÖ',1752927435),
(75,1752927435,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927435),
(76,1752927435,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927435),
(77,1752927457,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927457),
(78,1752927457,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927457),
(79,1752927457,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927457),
(80,1752927457,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927457),
(81,1752927459,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927459),
(82,1752927459,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927459),
(83,1752927459,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"database\\/migrations\\/2025_07_18_230841_create_pulse_tables.php:18\"]','-D8èa· §º1ú◊fjç—',1752927459),
(84,1752927459,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"database\\/migrations\\/2025_07_18_230841_create_pulse_tables.php:18\"]','-D8èa· §º1ú◊fjç—',1752927459),
(85,1752927459,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927459),
(86,1752927459,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927459),
(87,1752927467,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927467),
(88,1752927467,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927467),
(89,1752927468,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927468),
(90,1752927468,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927468),
(91,1752927477,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927477),
(92,1752927477,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927477),
(93,1752927478,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927478),
(94,1752927478,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927478),
(95,1752927486,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927486),
(96,1752927486,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927486),
(97,1752927487,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927487),
(98,1752927487,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927487),
(99,1752927495,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927495),
(100,1752927495,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927495),
(101,1752927496,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927496),
(102,1752927496,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927496),
(103,1752927504,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927504),
(104,1752927504,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927504),
(105,1752927505,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927505),
(106,1752927505,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927505),
(107,1752927514,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927514),
(108,1752927514,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927514),
(109,1752927515,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927515),
(110,1752927515,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927515),
(111,1752927523,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927523),
(112,1752927523,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927523),
(113,1752927524,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927524),
(114,1752927524,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927524),
(115,1752927532,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927532),
(116,1752927532,'exception','[\"Illuminate\\\\Database\\\\QueryException\",\"vendor\\/laravel\\/framework\\/src\\/Illuminate\\/Database\\/Connection.php:822\"]','°ùü∏	´Ó}πûœœô„',1752927532);
/*!40000 ALTER TABLE `pulse_entries` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `pulse_values`
--

DROP TABLE IF EXISTS `pulse_values`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pulse_values` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `timestamp` int(10) unsigned NOT NULL,
  `type` varchar(255) NOT NULL,
  `key` mediumtext NOT NULL,
  `key_hash` binary(16) GENERATED ALWAYS AS (unhex(md5(`key`))) VIRTUAL,
  `value` mediumtext NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pulse_values_type_key_hash_unique` (`type`,`key_hash`),
  KEY `pulse_values_timestamp_index` (`timestamp`),
  KEY `pulse_values_type_index` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pulse_values`
--

LOCK TABLES `pulse_values` WRITE;
/*!40000 ALTER TABLE `pulse_values` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `pulse_values` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `role_has_permissions`
--

DROP TABLE IF EXISTS `role_has_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_has_permissions` (
  `permission_id` bigint(20) unsigned NOT NULL,
  `role_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`permission_id`,`role_id`),
  KEY `role_has_permissions_role_id_foreign` (`role_id`),
  CONSTRAINT `role_has_permissions_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `role_has_permissions_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_has_permissions`
--

LOCK TABLES `role_has_permissions` WRITE;
/*!40000 ALTER TABLE `role_has_permissions` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `role_has_permissions` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `guard_name` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `roles_name_guard_name_unique` (`name`,`guard_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `settings`
--

DROP TABLE IF EXISTS `settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `settings` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `group` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `locked` tinyint(1) NOT NULL DEFAULT 0,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`payload`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `settings_group_name_unique` (`group`,`name`),
  KEY `settings_group_index` (`group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `settings`
--

LOCK TABLES `settings` WRITE;
/*!40000 ALTER TABLE `settings` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `settings` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `users` VALUES
(1,'admin','smn.karbasi@gmail.com',NULL,'$2y$12$bdYHnZ9jKM2nL0VQDz7t9eT/pJn7wJaPvVApqvs8Sfx3Zwfb9GxuO',NULL,'2025-07-18 21:35:45','2025-07-18 21:35:45');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping routines for database 'salbion_group'
--
