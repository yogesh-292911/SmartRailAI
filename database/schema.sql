CREATE DATABASE IF NOT EXISTS smartrail
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE smartrail;

CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  employee_id VARCHAR(32) NOT NULL UNIQUE,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(160) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('ADMIN', 'INSPECTOR', 'MAINTENANCE') NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS assets (
  id INT AUTO_INCREMENT PRIMARY KEY,
  asset_code VARCHAR(32) NOT NULL UNIQUE,
  asset_type VARCHAR(80) NOT NULL,
  railway_zone VARCHAR(80) NOT NULL,
  section VARCHAR(80) DEFAULT NULL,
  location VARCHAR(160) NOT NULL,
  manufacturer VARCHAR(120) DEFAULT NULL,
  installation_date DATE NOT NULL,
  expected_life INT NOT NULL DEFAULT 20,
  status ENUM('ACTIVE', 'INACTIVE', 'REPLACED') NOT NULL DEFAULT 'ACTIVE',
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS qr_codes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  asset_id INT NOT NULL,
  qr_code VARCHAR(64) NOT NULL UNIQUE,
  generated_date DATE NOT NULL,
  status ENUM('ACTIVE', 'INACTIVE') NOT NULL DEFAULT 'ACTIVE',
  FOREIGN KEY (asset_id) REFERENCES assets(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS inspections (
  id INT AUTO_INCREMENT PRIMARY KEY,
  asset_id INT NOT NULL,
  inspector_id INT NOT NULL,
  inspection_date DATE NOT NULL,
  condition_rating ENUM('Good', 'Moderate', 'Poor') NOT NULL,
  severity ENUM('Low', 'Medium', 'High') NOT NULL,
  damage_type VARCHAR(40) NOT NULL,
  remarks TEXT,
  image_path VARCHAR(255) DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (asset_id) REFERENCES assets(id) ON DELETE CASCADE,
  FOREIGN KEY (inspector_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS ai_predictions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  asset_id INT NOT NULL,
  inspection_id INT NOT NULL,
  risk_score DECIMAL(5,2) NOT NULL,
  risk_level ENUM('LOW', 'MEDIUM', 'HIGH') NOT NULL,
  prediction TEXT,
  recommendation TEXT,
  contributing_factors JSON DEFAULT NULL,
  model_name VARCHAR(80) NOT NULL DEFAULT 'RandomForestClassifier',
  model_version VARCHAR(20) NOT NULL DEFAULT '1.0',
  prediction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (asset_id) REFERENCES assets(id) ON DELETE CASCADE,
  FOREIGN KEY (inspection_id) REFERENCES inspections(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS maintenance (
  id INT AUTO_INCREMENT PRIMARY KEY,
  asset_id INT NOT NULL,
  prediction_id INT DEFAULT NULL,
  assigned_to INT DEFAULT NULL,
  priority ENUM('LOW', 'MEDIUM', 'HIGH') NOT NULL DEFAULT 'MEDIUM',
  action VARCHAR(255) DEFAULT NULL,
  scheduled_date DATE DEFAULT NULL,
  completed_date DATE DEFAULT NULL,
  status ENUM('PENDING', 'ASSIGNED', 'IN_PROGRESS', 'COMPLETED') NOT NULL DEFAULT 'PENDING',
  remarks TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (asset_id) REFERENCES assets(id) ON DELETE CASCADE,
  FOREIGN KEY (prediction_id) REFERENCES ai_predictions(id) ON DELETE SET NULL,
  FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX idx_assets_type ON assets(asset_type);
CREATE INDEX idx_inspections_asset ON inspections(asset_id);
CREATE INDEX idx_predictions_asset ON ai_predictions(asset_id);
CREATE INDEX idx_predictions_level ON ai_predictions(risk_level);
CREATE INDEX idx_maintenance_status ON maintenance(status);
