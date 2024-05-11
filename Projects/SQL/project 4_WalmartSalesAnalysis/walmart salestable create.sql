IF NOT EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = 'salesDataWalmart')
BEGIN
    CREATE DATABASE salesDataWalmart;
END

use salesDataWalmart
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'sales')
BEGIN
    CREATE TABLE sales (
        invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
        branch VARCHAR(5) NOT NULL,
        city VARCHAR(30) NOT NULL,
        customer_type VARCHAR(30) NOT NULL,
        gender VARCHAR(30) NOT NULL,
        product_line VARCHAR(100) NOT NULL,
        unit_price DECIMAL(10,2) NOT NULL,
        quantity INT NOT NULL,
        VAT FLOAT  NOT NULL,
        total DECIMAL(12,4) NOT NULL,
        date DATETIME NOT NULL,
        time TIME NOT NULL,
        payment_method VARCHAR(15) NOT NULL,
        cogs DECIMAL(10,2) NOT NULL,
        gross_margin_pct FLOAT,
        gross_income DECIMAL(12,4) NOT NULL,
        rating FLOAT NOT NULL
    );
END

drop table sales
