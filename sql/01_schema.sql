-- =====================================================
-- Case Study : Car Inventory Management System
-- Student    : Aditya Wandhare
-- Database   : adityawandhare   (PostgreSQL)
-- =====================================================
CREATE DATABASE adityawandhare;
\c adityawandhare

-- 1. MANUFACTURERS
CREATE TABLE manufacturers (
    manufacturer_id   SERIAL PRIMARY KEY,
    name              VARCHAR(60)  NOT NULL UNIQUE,
    country           VARCHAR(40)  NOT NULL,
    founded_year      INTEGER      CHECK (founded_year BETWEEN 1800 AND 2026),
    website           VARCHAR(80)
);

-- 2. CAR MODELS
CREATE TABLE car_models (
    model_id          SERIAL PRIMARY KEY,
    manufacturer_id   INTEGER      NOT NULL
                      REFERENCES manufacturers(manufacturer_id)
                      ON UPDATE CASCADE ON DELETE RESTRICT,
    model_name        VARCHAR(60)  NOT NULL,
    body_type         VARCHAR(20)  NOT NULL
                      CHECK (body_type IN ('Hatchback','Sedan','SUV','MPV')),
    fuel_type         VARCHAR(15)  NOT NULL
                      CHECK (fuel_type IN ('Petrol','Diesel','CNG','Electric')),
    transmission      VARCHAR(15)  NOT NULL
                      CHECK (transmission IN ('Manual','Automatic')),
    seating_capacity  INTEGER      NOT NULL CHECK (seating_capacity BETWEEN 2 AND 9),
    base_price        NUMERIC(12,2) NOT NULL CHECK (base_price > 0),
    UNIQUE (manufacturer_id, model_name, fuel_type, transmission)
);

-- 3. SUPPLIERS
CREATE TABLE suppliers (
    supplier_id       SERIAL PRIMARY KEY,
    supplier_name     VARCHAR(80)  NOT NULL,
    contact_person    VARCHAR(60)  NOT NULL,
    phone             VARCHAR(15)  NOT NULL UNIQUE,
    email             VARCHAR(80)  UNIQUE,
    city              VARCHAR(40)  NOT NULL,
    state             VARCHAR(40)  NOT NULL
);

-- 4. EMPLOYEES
CREATE TABLE employees (
    employee_id       SERIAL PRIMARY KEY,
    full_name         VARCHAR(60)  NOT NULL,
    role              VARCHAR(30)  NOT NULL
                      CHECK (role IN ('Sales Manager','Sales Executive',
                                      'Inventory Manager','Service Advisor',
                                      'Accountant','Receptionist')),
    phone             VARCHAR(15)  NOT NULL UNIQUE,
    email             VARCHAR(80)  NOT NULL UNIQUE,
    hire_date         DATE         NOT NULL,
    salary            NUMERIC(10,2) NOT NULL CHECK (salary > 0)
);

-- 5. CUSTOMERS
CREATE TABLE customers (
    customer_id       SERIAL PRIMARY KEY,
    full_name         VARCHAR(60)  NOT NULL,
    phone             VARCHAR(15)  NOT NULL UNIQUE,
    email             VARCHAR(80)  UNIQUE,
    city              VARCHAR(40)  NOT NULL,
    state             VARCHAR(40)  NOT NULL DEFAULT 'Maharashtra',
    registered_on     DATE         NOT NULL DEFAULT CURRENT_DATE
);

-- 6. CARS (the physical inventory)
CREATE TABLE cars (
    car_id            SERIAL PRIMARY KEY,
    vin               CHAR(17)     NOT NULL UNIQUE,
    model_id          INTEGER      NOT NULL
                      REFERENCES car_models(model_id)
                      ON UPDATE CASCADE ON DELETE RESTRICT,
    supplier_id       INTEGER      NOT NULL
                      REFERENCES suppliers(supplier_id)
                      ON UPDATE CASCADE ON DELETE RESTRICT,
    color             VARCHAR(20)  NOT NULL,
    manufacture_year  INTEGER      NOT NULL CHECK (manufacture_year BETWEEN 2000 AND 2026),
    mileage_km        INTEGER      NOT NULL DEFAULT 0 CHECK (mileage_km >= 0),
    car_condition     VARCHAR(10)  NOT NULL CHECK (car_condition IN ('New','Used')),
    purchase_price    NUMERIC(12,2) NOT NULL CHECK (purchase_price > 0),
    selling_price     NUMERIC(12,2) NOT NULL CHECK (selling_price > 0),
    status            VARCHAR(12)  NOT NULL DEFAULT 'Available'
                      CHECK (status IN ('Available','Reserved','Sold','In Service')),
    arrival_date      DATE         NOT NULL DEFAULT CURRENT_DATE
);

-- 7. SALES
CREATE TABLE sales (
    sale_id           SERIAL PRIMARY KEY,
    car_id            INTEGER      NOT NULL UNIQUE
                      REFERENCES cars(car_id)
                      ON UPDATE CASCADE ON DELETE RESTRICT,
    customer_id       INTEGER      NOT NULL
                      REFERENCES customers(customer_id)
                      ON UPDATE CASCADE ON DELETE RESTRICT,
    employee_id       INTEGER      NOT NULL
                      REFERENCES employees(employee_id)
                      ON UPDATE CASCADE ON DELETE RESTRICT,
    sale_date         DATE         NOT NULL DEFAULT CURRENT_DATE,
    sale_price        NUMERIC(12,2) NOT NULL CHECK (sale_price > 0),
    payment_mode      VARCHAR(15)  NOT NULL
                      CHECK (payment_mode IN ('Cash','Loan','UPI','Cheque','Bank Transfer'))
);

-- 8. SERVICE RECORDS
CREATE TABLE service_records (
    service_id        SERIAL PRIMARY KEY,
    car_id            INTEGER      NOT NULL
                      REFERENCES cars(car_id)
                      ON UPDATE CASCADE ON DELETE CASCADE,
    employee_id       INTEGER      NOT NULL
                      REFERENCES employees(employee_id)
                      ON UPDATE CASCADE ON DELETE RESTRICT,
    service_date      DATE         NOT NULL,
    service_type      VARCHAR(40)  NOT NULL,
    cost              NUMERIC(10,2) NOT NULL CHECK (cost >= 0),
    service_status    VARCHAR(12)  NOT NULL DEFAULT 'Completed'
                      CHECK (service_status IN ('Pending','In Progress','Completed'))
);
