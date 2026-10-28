/**
 * Gelateria Cremona Contact Form Database Schema
 * ═════════════════════════════════════════════════════════════
 * 
 * This file creates the database and table for storing contact
 * form submissions from the Gelateria Cremona website.
 * 
 * Steps to use:
 *   1. Open phpMyAdmin on your server (cPanel / Hostinger)
 *   2. Click "Import" and upload this .sql file
 *   OR paste this entire content into SQL tab → Execute
 */

-- Create database if it doesn't exist
CREATE DATABASE IF NOT EXISTS `gelateria_cremona` 
  CHARACTER SET utf8mb4 
  COLLATE utf8mb4_unicode_ci;

-- Use the database
USE `gelateria_cremona`;

-- Drop table if it exists (for clean reinstall)
DROP TABLE IF EXISTS `contact_submissions`;

-- Create the contact submissions table
CREATE TABLE `contact_submissions` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  
  -- Form fields from contact.html
  `name` VARCHAR(150) NOT NULL COMMENT 'Visitor full name',
  `email` VARCHAR(150) NOT NULL COMMENT 'Visitor email address',
  `message` LONGTEXT COMMENT 'Visitor message',
  
  -- Metadata
  `ip_address` VARCHAR(45) COMMENT 'Visitor IP address (IPv4 or IPv6)',
  `user_agent` VARCHAR(255) COMMENT 'Browser user agent string',
  `email_sent` TINYINT(1) DEFAULT 0 COMMENT 'Was notification email sent (1=yes, 0=no)',
  
  -- Timestamps
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'When form was submitted',
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update time',
  
  -- Indexes for faster queries
  KEY `idx_email` (`email`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_email_sent` (`email_sent`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Contact form submissions from Gelateria Cremona website';

-- Optional: Create a summary view (for quick dashboard stats)
DROP VIEW IF EXISTS `contact_summary`;
CREATE VIEW `contact_summary` AS
  SELECT 
    COUNT(*) as total_submissions,
    SUM(CASE WHEN email_sent = 1 THEN 1 ELSE 0 END) as emails_sent,
    SUM(CASE WHEN email_sent = 0 THEN 1 ELSE 0 END) as emails_failed,
    DATE(created_at) as submission_date
  FROM contact_submissions
  GROUP BY DATE(created_at)
  ORDER BY submission_date DESC;

-- Optional: Create an admin user table for future dashboard access
DROP TABLE IF EXISTS `admin_users`;
CREATE TABLE `admin_users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `username` VARCHAR(100) UNIQUE NOT NULL,
  `email` VARCHAR(150) UNIQUE NOT NULL,
  `password_hash` VARCHAR(255) NOT NULL COMMENT 'Use password_hash() in PHP',
  `role` ENUM('admin', 'staff') DEFAULT 'staff',
  `active` TINYINT(1) DEFAULT 1,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Display what was created
SELECT 'Database and tables created successfully!' as status;
