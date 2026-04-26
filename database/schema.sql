-- Urban Farming Management System Database Schema

CREATE DATABASE IF NOT EXISTS urban_farming;
USE urban_farming;

-- Users table for authentication and role management
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('farmer', 'planner', 'admin') NOT NULL,
    green_points INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Farms table
CREATE TABLE farms (
    id INT PRIMARY KEY AUTO_INCREMENT,
    farmer_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(255) NOT NULL,
    farm_type ENUM('vegetable', 'fruit', 'grain', 'mixed') NOT NULL,
    crops TEXT,
    soil_type VARCHAR(50),
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (farmer_id) REFERENCES users(id) ON DELETE CASCADE
);

-- IoT Devices table
CREATE TABLE iot_devices (
    id INT PRIMARY KEY AUTO_INCREMENT,
    farm_id INT NOT NULL,
    device_type ENUM('soil_moisture', 'temperature', 'humidity', 'light', 'water_flow', 'pump', 'fan', 'light_control') NOT NULL,
    device_name VARCHAR(100) NOT NULL,
    status ENUM('active', 'inactive', 'maintenance') DEFAULT 'active',
    last_reading DECIMAL(10,2),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (farm_id) REFERENCES farms(id) ON DELETE CASCADE
);

-- IoT Sensor Readings table
CREATE TABLE iot_readings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    device_id INT NOT NULL,
    reading_value DECIMAL(10,2) NOT NULL,
    reading_type VARCHAR(50) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (device_id) REFERENCES iot_devices(id) ON DELETE CASCADE
);

-- Drones table
CREATE TABLE drones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    drone_type ENUM('survey', 'spraying', 'monitoring', 'biological') NOT NULL,
    name VARCHAR(100) NOT NULL,
    status ENUM('available', 'assigned', 'en_route', 'active', 'completed', 'maintenance') DEFAULT 'available',
    battery_level INT DEFAULT 100,
    last_maintenance DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Drone Requests table
CREATE TABLE drone_requests (
    id INT PRIMARY KEY AUTO_INCREMENT,
    farmer_id INT NOT NULL,
    farm_id INT NOT NULL,
    drone_id INT,
    purpose ENUM('survey', 'pest_control_spraying', 'pest_control_monitoring', 'pest_control_biological') NOT NULL,
    location VARCHAR(255) NOT NULL,
    preferred_time DATETIME NOT NULL,
    status ENUM('pending', 'approved', 'rejected', 'en_route', 'active', 'completed') DEFAULT 'pending',
    approved_by INT,
    approved_at TIMESTAMP NULL,
    notes TEXT,
    result_report TEXT,
    green_points_earned INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (farmer_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (farm_id) REFERENCES farms(id) ON DELETE CASCADE,
    FOREIGN KEY (drone_id) REFERENCES drones(id) ON DELETE SET NULL,
    FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Seed Marketplace table
CREATE TABLE seed_listings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    seller_id INT NOT NULL,
    seed_type VARCHAR(100) NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    location VARCHAR(255) NOT NULL,
    is_organic BOOLEAN DEFAULT FALSE,
    is_non_gmo BOOLEAN DEFAULT FALSE,
    description TEXT,
    status ENUM('pending', 'available', 'sold') DEFAULT 'pending',
    approved_by INT,
    approved_at TIMESTAMP NULL,
    notes TEXT,
    buyer_id INT,
    green_points_earned_seller INT DEFAULT 0,
    green_points_earned_buyer INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (buyer_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Seed Sales table for tracking purchase transactions
CREATE TABLE seed_sales (
    id INT PRIMARY KEY AUTO_INCREMENT,
    listing_id INT NOT NULL,
    buyer_id INT NOT NULL,
    seller_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    green_points_earned_buyer INT DEFAULT 0,
    green_points_earned_seller INT DEFAULT 0,
    status ENUM('completed', 'pending', 'cancelled') DEFAULT 'completed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (listing_id) REFERENCES seed_listings(id) ON DELETE CASCADE,
    FOREIGN KEY (buyer_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_buyer_id (buyer_id),
    INDEX idx_seller_id (seller_id),
    INDEX idx_transaction_date (transaction_date)
);

-- Green Points Transactions table
CREATE TABLE green_points_transactions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    transaction_type ENUM('earned', 'spent', 'bonus') NOT NULL,
    amount INT NOT NULL,
    description TEXT NOT NULL,
    related_entity_type ENUM('drone_request', 'seed_sale', 'iot_optimization', 'ai_recommendation') NOT NULL,
    related_entity_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- AI Recommendations table
CREATE TABLE ai_recommendations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    recommendation_type ENUM('drone_type', 'timing', 'irrigation', 'pest_control') NOT NULL,
    recommendation_text TEXT NOT NULL,
    sensor_data JSON,
    is_followed BOOLEAN DEFAULT FALSE,
    green_points_earned INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- System Logs table
CREATE TABLE system_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    action VARCHAR(100) NOT NULL,
    details TEXT,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Drone Results table
CREATE TABLE drone_results (
    id INT PRIMARY KEY AUTO_INCREMENT,
    drone_request_id INT NOT NULL,
    drone_id INT NOT NULL,
    operation_type VARCHAR(100) NOT NULL,
    area_covered DECIMAL(10,2) NOT NULL,
    duration_minutes INT NOT NULL,
    efficiency_score DECIMAL(5,2) NOT NULL,
    coverage_percentage DECIMAL(5,2) NOT NULL,
    issues_encountered TEXT,
    recommendations TEXT,
    data_collected JSON,
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (drone_request_id) REFERENCES drone_requests(id) ON DELETE CASCADE,
    FOREIGN KEY (drone_id) REFERENCES drones(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_drone_request (drone_request_id),
    INDEX idx_created_at (created_at)
);

-- Notifications table for real-time notification system
CREATE TABLE notifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('info', 'success', 'warning', 'error') DEFAULT 'info',
    category ENUM('farm_request', 'drone_request', 'approval', 'system', 'marketplace') DEFAULT 'system',
    related_entity_type ENUM('farm', 'drone_request', 'seed_listing', 'system') DEFAULT 'system',
    related_entity_id INT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_read (user_id, is_read),
    INDEX idx_created_at (created_at)
);

-- Insert default admin user
INSERT INTO users (username, email, password_hash, role) VALUES 
('admin', 'admin@urbanfarming.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin');

-- Insert sample drones
INSERT INTO drones (drone_type, name, status) VALUES 
('survey', 'Survey Drone 1', 'available'),
('survey', 'Survey Drone 2', 'available'),
('spraying', 'Spraying Drone 1', 'available'),
('spraying', 'Spraying Drone 2', 'available'),
('monitoring', 'Monitoring Drone 1', 'available'),
('biological', 'Biological Drone 1', 'available');
