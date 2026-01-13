-- 步骤1：基础环境搭建
-- 本脚本用于创建测试数据库和表结构

-- 创建测试数据库
CREATE DATABASE IF NOT EXISTS iso_test;
USE iso_test;

-- 创建测试表
CREATE TABLE IF NOT EXISTS products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    price DECIMAL(10,2) NOT NULL,
    version INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 插入测试数据
INSERT INTO products (name, stock, price) VALUES 
('Product A', 100, 99.99),
('Product B', 200, 199.99),
('Product C', 300, 299.99);

-- 查看表结构和数据
DESCRIBE products;
SELECT * FROM products;

-- 查看当前数据库的事务隔离级别
SELECT @@global.transaction_isolation, @@transaction_isolation;
