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
-- MANUFACTURERS (20 records)
INSERT INTO manufacturers (name, country, founded_year, website) VALUES
  ('Maruti Suzuki', 'India', 1981, 'www.marutisuzuki.com'),
  ('Hyundai', 'South Korea', 1967, 'www.hyundai.com'),
  ('Tata Motors', 'India', 1945, 'www.tatamotors.com'),
  ('Mahindra & Mahindra', 'India', 1945, 'www.mahindra.com'),
  ('Kia', 'South Korea', 1944, 'www.kia.com'),
  ('Toyota', 'Japan', 1937, 'www.toyota.com'),
  ('Honda', 'Japan', 1948, 'www.honda.com'),
  ('MG Motor', 'United Kingdom', 1924, 'www.mgmotor.in'),
  ('Skoda', 'Czech Republic', 1895, 'www.skoda.com'),
  ('Volkswagen', 'Germany', 1937, 'www.volkswagen.com'),
  ('Renault', 'France', 1899, 'www.renault.com'),
  ('Nissan', 'Japan', 1933, 'www.nissan.com'),
  ('Jeep', 'USA', 1941, 'www.jeep.com'),
  ('Citroen', 'France', 1919, 'www.citroen.com'),
  ('BMW', 'Germany', 1916, 'www.bmw.com'),
  ('Mercedes-Benz', 'Germany', 1926, 'www.mercedesbenz.com'),
  ('Audi', 'Germany', 1909, 'www.audi.com'),
  ('Volvo', 'Sweden', 1927, 'www.volvo.com'),
  ('Land Rover', 'United Kingdom', 1948, 'www.landrover.com'),
  ('Ford', 'USA', 1903, 'www.ford.com');

-- CAR_MODELS (25 records)
INSERT INTO car_models (manufacturer_id, model_name, body_type, fuel_type, transmission, seating_capacity, base_price) VALUES
  (1, 'Swift', 'Hatchback', 'Petrol', 'Manual', 5, 650000),
  (1, 'Brezza', 'SUV', 'Petrol', 'Automatic', 5, 1000000),
  (1, 'Ertiga', 'MPV', 'CNG', 'Manual', 7, 950000),
  (2, 'Creta', 'SUV', 'Diesel', 'Automatic', 5, 1700000),
  (2, 'i20', 'Hatchback', 'Petrol', 'Manual', 5, 800000),
  (2, 'Verna', 'Sedan', 'Petrol', 'Automatic', 5, 1200000),
  (3, 'Nexon', 'SUV', 'Petrol', 'Manual', 5, 950000),
  (3, 'Harrier', 'SUV', 'Diesel', 'Automatic', 5, 1800000),
  (3, 'Tiago EV', 'Hatchback', 'Electric', 'Automatic', 5, 1100000),
  (4, 'Thar', 'SUV', 'Diesel', 'Manual', 4, 1300000),
  (4, 'Scorpio-N', 'SUV', 'Diesel', 'Automatic', 7, 1800000),
  (4, 'XUV700', 'SUV', 'Diesel', 'Automatic', 7, 2000000),
  (5, 'Seltos', 'SUV', 'Petrol', 'Automatic', 5, 1600000),
  (5, 'Carens', 'MPV', 'Diesel', 'Manual', 7, 1150000),
  (6, 'Innova Crysta', 'MPV', 'Diesel', 'Manual', 7, 2000000),
  (6, 'Fortuner', 'SUV', 'Diesel', 'Automatic', 7, 3600000),
  (7, 'City', 'Sedan', 'Petrol', 'Automatic', 5, 1250000),
  (7, 'Amaze', 'Sedan', 'Petrol', 'Manual', 5, 800000),
  (8, 'Hector', 'SUV', 'Petrol', 'Automatic', 5, 1500000),
  (9, 'Slavia', 'Sedan', 'Petrol', 'Automatic', 5, 1350000),
  (10, 'Virtus', 'Sedan', 'Petrol', 'Automatic', 5, 1300000),
  (15, '3 Series', 'Sedan', 'Petrol', 'Automatic', 5, 5800000),
  (16, 'C-Class', 'Sedan', 'Petrol', 'Automatic', 5, 6000000),
  (17, 'Q3', 'SUV', 'Petrol', 'Automatic', 5, 4500000),
  (18, 'XC40', 'SUV', 'Petrol', 'Automatic', 5, 4700000);

-- SUPPLIERS (20 records)
INSERT INTO suppliers (supplier_name, contact_person, phone, email, city, state) VALUES
  ('Vidarbha Auto Traders', 'Rajesh Kulkarni', '9227904006', 'rajesh.kulkarni@vidarbha.in', 'Nagpur', 'Maharashtra'),
  ('Deccan Motors Pvt Ltd', 'Sandeep Joshi', '9443043868', 'sandeep.joshi@deccan.in', 'Pune', 'Maharashtra'),
  ('Western Wheels Distributors', 'Amit Shah', '9639572182', 'amit.shah@western.in', 'Mumbai', 'Maharashtra'),
  ('Orange City Cars', 'Prashant Deshmukh', '9649565454', 'prashant.deshmukh@orange.in', 'Nagpur', 'Maharashtra'),
  ('Godavari Auto Hub', 'Vikram Pawar', '9794923749', 'vikram.pawar@godavari.in', 'Nashik', 'Maharashtra'),
  ('Sahyadri Motor Mart', 'Nitin Patil', '9210205473', 'nitin.patil@sahyadri.in', 'Kolhapur', 'Maharashtra'),
  ('Central India Car Exchange', 'Manoj Tiwari', '9339749960', 'manoj.tiwari@central.in', 'Bhopal', 'Madhya Pradesh'),
  ('Narmada Auto Sales', 'Sunil Verma', '9745351751', 'sunil.verma@narmada.in', 'Jabalpur', 'Madhya Pradesh'),
  ('Gujarat Prime Motors', 'Hitesh Patel', '9767313473', 'hitesh.patel@gujarat.in', 'Ahmedabad', 'Gujarat'),
  ('Surat Car Gallery', 'Kiran Desai', '9697600698', 'kiran.desai@surat.in', 'Surat', 'Gujarat'),
  ('Pink City Autos', 'Rohit Sharma', '9551631864', 'rohit.sharma@pink.in', 'Jaipur', 'Rajasthan'),
  ('Capital Car Traders', 'Ankur Mehra', '9941140765', 'ankur.mehra@capital.in', 'New Delhi', 'Delhi'),
  ('Hyderabad Motor World', 'Srinivas Reddy', '9714791075', 'srinivas.reddy@hyderabad.in', 'Hyderabad', 'Telangana'),
  ('Garden City Autos', 'Karthik Rao', '9688208069', 'karthik.rao@garden.in', 'Bengaluru', 'Karnataka'),
  ('Chennai Auto Mart', 'Arun Kumar', '9884410270', 'arun.kumar@chennai.in', 'Chennai', 'Tamil Nadu'),
  ('Indore Car Bazaar', 'Deepak Jain', '9933838458', 'deepak.jain@indore.in', 'Indore', 'Madhya Pradesh'),
  ('Raipur Motors', 'Alok Chandra', '9924757551', 'alok.chandra@raipur.in', 'Raipur', 'Chhattisgarh'),
  ('Aurangabad Auto Point', 'Shahid Khan', '9627104586', 'shahid.khan@aurangabad.in', 'Chhatrapati Sambhajinagar', 'Maharashtra'),
  ('Konkan Car Traders', 'Sachin Naik', '9906407983', 'sachin.naik@konkan.in', 'Ratnagiri', 'Maharashtra'),
  ('Solapur Motor Co.', 'Ganesh Jadhav', '9930080574', 'ganesh.jadhav@solapur.in', 'Solapur', 'Maharashtra');

-- EMPLOYEES (20 records)
INSERT INTO employees (full_name, role, phone, email, hire_date, salary) VALUES
  ('Rahul Deshmukh', 'Sales Manager', '8357627256', 'rahul.deshmukh@autohub.in', '2023-12-12', 95000),
  ('Sneha Kulkarni', 'Sales Executive', '8759496827', 'sneha.kulkarni@autohub.in', '2019-01-11', 42000),
  ('Pooja Wankhede', 'Sales Executive', '8218902461', 'pooja.wankhede@autohub.in', '2019-11-27', 40000),
  ('Amol Bhoyar', 'Sales Executive', '8976990827', 'amol.bhoyar@autohub.in', '2022-03-22', 41000),
  ('Nikhil Gaikwad', 'Sales Executive', '8582813204', 'nikhil.gaikwad@autohub.in', '2020-02-06', 39000),
  ('Kavita Raut', 'Sales Executive', '8974844773', 'kavita.raut@autohub.in', '2019-02-17', 43000),
  ('Sagar Thakre', 'Sales Executive', '8829488324', 'sagar.thakre@autohub.in', '2024-07-01', 38000),
  ('Priya Mehta', 'Inventory Manager', '8325727008', 'priya.mehta@autohub.in', '2022-07-11', 70000),
  ('Vishal Chavan', 'Inventory Manager', '8370060143', 'vishal.chavan@autohub.in', '2023-06-16', 65000),
  ('Ritu Agrawal', 'Accountant', '8482935044', 'ritu.agrawal@autohub.in', '2022-11-25', 55000),
  ('Mohan Lokhande', 'Accountant', '8900979098', 'mohan.lokhande@autohub.in', '2023-03-22', 52000),
  ('Swati Patil', 'Receptionist', '8784743907', 'swati.patil@autohub.in', '2024-10-04', 28000),
  ('Tushar Bhagat', 'Service Advisor', '8876435574', 'tushar.bhagat@autohub.in', '2019-11-09', 36000),
  ('Anil Sonkusare', 'Service Advisor', '8196277024', 'anil.sonkusare@autohub.in', '2022-10-26', 35000),
  ('Meena Ingole', 'Service Advisor', '8677742599', 'meena.ingole@autohub.in', '2025-04-02', 34000),
  ('Yogesh Borkar', 'Sales Executive', '8408810231', 'yogesh.borkar@autohub.in', '2022-04-11', 40000),
  ('Shweta Dhoke', 'Sales Executive', '8251277718', 'shweta.dhoke@autohub.in', '2024-02-17', 41000),
  ('Akash Meshram', 'Service Advisor', '8431784839', 'akash.meshram@autohub.in', '2025-06-23', 33000),
  ('Divya Nimje', 'Receptionist', '8863282616', 'divya.nimje@autohub.in', '2019-04-12', 27000),
  ('Harshad Zade', 'Sales Executive', '8490350503', 'harshad.zade@autohub.in', '2023-02-19', 39500);

-- CUSTOMERS (25 records)
INSERT INTO customers (full_name, phone, email, city, state, registered_on) VALUES
  ('Aarav Sharma', '7553352586', 'aarav.sharma@gmail.com', 'Nagpur', 'Maharashtra', '2025-08-25'),
  ('Vedant Joshi', '7528179593', 'vedant.joshi@gmail.com', 'Nagpur', 'Maharashtra', '2025-02-16'),
  ('Ishita Bansod', '7225035027', 'ishita.bansod@gmail.com', 'Nagpur', 'Maharashtra', '2025-09-13'),
  ('Rohan Gawande', '7643698561', 'rohan.gawande@gmail.com', 'Wardha', 'Maharashtra', '2025-08-06'),
  ('Ananya Kale', '7527508601', 'ananya.kale@gmail.com', 'Pune', 'Maharashtra', '2025-09-09'),
  ('Siddharth Mishra', '7377716265', 'siddharth.mishra@gmail.com', 'Nagpur', 'Maharashtra', '2025-09-26'),
  ('Neha Pillai', '7705590520', 'neha.pillai@gmail.com', 'Mumbai', 'Maharashtra', '2025-08-04'),
  ('Omkar Bhosale', '7650775247', 'omkar.bhosale@gmail.com', 'Pune', 'Maharashtra', '2025-09-03'),
  ('Tanvi Dhote', '7964548086', 'tanvi.dhote@gmail.com', 'Amravati', 'Maharashtra', '2025-09-23'),
  ('Karan Malhotra', '7717955856', 'karan.malhotra@gmail.com', 'Nashik', 'Maharashtra', '2025-01-13'),
  ('Sakshi Wagh', '7922299757', 'sakshi.wagh@gmail.com', 'Nashik', 'Maharashtra', '2025-04-25'),
  ('Aditi Shinde', '7978462767', 'aditi.shinde@gmail.com', 'Pune', 'Maharashtra', '2025-03-08'),
  ('Yash Choudhari', '7856625749', 'yash.choudhari@gmail.com', 'Akola', 'Maharashtra', '2025-01-26'),
  ('Mrunal Tayade', '7819925699', 'mrunal.tayade@gmail.com', 'Nagpur', 'Maharashtra', '2025-09-25'),
  ('Harsh Vyas', '7870203091', 'harsh.vyas@gmail.com', 'Bhandara', 'Maharashtra', '2025-02-22'),
  ('Pranav Hedau', '7604701957', 'pranav.hedau@gmail.com', 'Nagpur', 'Maharashtra', '2025-08-08'),
  ('Komal Rathod', '7617665009', 'komal.rathod@gmail.com', 'Yavatmal', 'Maharashtra', '2025-03-14'),
  ('Gaurav Sethi', '7231010732', 'gaurav.sethi@gmail.com', 'Raipur', 'Chhattisgarh', '2025-04-28'),
  ('Rutuja Mane', '7824027511', 'rutuja.mane@gmail.com', 'Kolhapur', 'Maharashtra', '2025-08-22'),
  ('Abhishek Dubey', '7867213565', 'abhishek.dubey@gmail.com', 'Jabalpur', 'Madhya Pradesh', '2025-08-29'),
  ('Shruti Naidu', '7369516155', 'shruti.naidu@gmail.com', 'Hyderabad', 'Telangana', '2025-10-07'),
  ('Devendra Fulzele', '7819142805', 'devendra.fulzele@gmail.com', 'Gondia', 'Maharashtra', '2025-07-25'),
  ('Payal Khobragade', '7688570007', 'payal.khobragade@gmail.com', 'Nagpur', 'Maharashtra', '2025-06-07'),
  ('Sameer Qureshi', '7849819208', 'sameer.qureshi@gmail.com', 'Aurangabad', 'Maharashtra', '2025-09-14'),
  ('Bhavna Solanki', '7964248673', 'bhavna.solanki@gmail.com', 'Surat', 'Gujarat', '2025-09-03');

-- CARS (40 records)
INSERT INTO cars (vin, model_id, supplier_id, color, manufacture_year, mileage_km, car_condition, purchase_price, selling_price, status, arrival_date) VALUES
  ('MA59T5M47EU80GN3K', 14, 15, 'White', 2020, 50019, 'Used', 488000, 544000, 'Sold', '2025-12-21'),
  ('MASHCUZKAX8JR7J9V', 3, 3, 'Brown', 2026, 42, 'New', 862000, 957000, 'Reserved', '2026-02-10'),
  ('MA1AG1EDZZBB97XW5', 22, 11, 'Black', 2026, 37, 'New', 5223000, 5790000, 'Sold', '2026-02-09'),
  ('MA6RE2CNMCD5N7BJP', 16, 17, 'Silver', 2025, 14, 'New', 3274000, 3511000, 'Reserved', '2026-04-22'),
  ('MA1WMZMT683V6MX75', 6, 4, 'Red', 2021, 63114, 'Used', 607000, 663000, 'Reserved', '2025-12-11'),
  ('MA3MBZLZPHUPVUJGT', 4, 4, 'Brown', 2025, 5, 'New', 1577000, 1755000, 'In Service', '2026-04-19'),
  ('MA9XUEVXLTTEA3T3A', 6, 2, 'Black', 2025, 53, 'New', 1077000, 1193000, 'Sold', '2025-12-25'),
  ('MAX6C2XP64H09T1VZ', 8, 2, 'Brown', 2026, 12, 'New', 1592000, 1741000, 'In Service', '2026-04-29'),
  ('MAW3XBYNDHLHHCJZW', 1, 1, 'Brown', 2026, 23, 'New', 596000, 659000, 'Sold', '2026-01-02'),
  ('MARJMB2TKRBBU73TX', 19, 5, 'Black', 2026, 31, 'New', 1349000, 1449000, 'Sold', '2026-06-04'),
  ('MADAS7DR9K20RUYN0', 6, 12, 'Orange', 2020, 46763, 'Used', 510000, 557000, 'In Service', '2026-04-12'),
  ('MA3K8AZ3CMFW0TJGB', 21, 18, 'Grey', 2026, 55, 'New', 1188000, 1282000, 'Sold', '2026-01-21'),
  ('MA9GFK1YTWCNLVVVZ', 23, 5, 'Brown', 2024, 17851, 'Used', 4757000, 5151000, 'Sold', '2026-01-20'),
  ('MABMXKLBH9A0E0WPK', 7, 20, 'Grey', 2020, 74916, 'Used', 422000, 456000, 'Available', '2026-01-27'),
  ('MA1TWHZ78HSZ6ZFEF', 5, 16, 'Red', 2026, 36, 'New', 708000, 786000, 'Sold', '2025-12-08'),
  ('MAX82XMN6RZZ31PK5', 9, 19, 'Silver', 2021, 34064, 'Used', 558000, 608000, 'Sold', '2026-04-19'),
  ('MATKURYKHUV622BY3', 14, 11, 'Black', 2026, 58, 'New', 1019000, 1096000, 'Sold', '2026-06-16'),
  ('MAMAUTJY377YACRHU', 22, 11, 'White', 2026, 27, 'New', 5292000, 5629000, 'Sold', '2026-05-24'),
  ('MAAGKYR6PLWF3JGBU', 25, 14, 'White', 2024, 48295, 'Used', 3637000, 3936000, 'Sold', '2026-02-05'),
  ('MAYZX7T8XTC8JB70T', 6, 15, 'Grey', 2024, 42324, 'Used', 954000, 1063000, 'Available', '2026-04-24'),
  ('MAE9W7F9X8XY0MEMT', 12, 17, 'Brown', 2026, 24, 'New', 1782000, 1895000, 'Available', '2026-05-30'),
  ('MAJ9PU8JX02NKKKJD', 21, 2, 'Red', 2025, 6, 'New', 1174000, 1259000, 'Available', '2026-07-19'),
  ('MA6LMDMK38BWR90F6', 10, 14, 'Silver', 2025, 22, 'New', 1207000, 1330000, 'Sold', '2026-01-05'),
  ('MAYBL9NF44NLSR8P0', 11, 6, 'Brown', 2025, 35, 'New', 1585000, 1689000, 'Sold', '2026-03-12'),
  ('MA7FPNHFZLHMP4N4B', 24, 18, 'Silver', 2022, 39417, 'Used', 2787000, 3059000, 'Available', '2026-06-14'),
  ('MA6UZ8JGKRZ61DXTF', 21, 15, 'Orange', 2022, 49632, 'Used', 792000, 858000, 'Sold', '2026-07-03'),
  ('MACE5G167BKXJBG2F', 12, 6, 'Red', 2024, 24885, 'Used', 1569000, 1691000, 'Available', '2025-12-12'),
  ('MAKW7SX6S2S9X3C8S', 1, 20, 'Silver', 2025, 53, 'New', 592000, 632000, 'Sold', '2026-04-21'),
  ('MA8P1C6JVSXU4BZLH', 15, 19, 'Blue', 2025, 42, 'New', 1808000, 1958000, 'Sold', '2025-11-09'),
  ('MA32ASNDTLU0FTLCP', 7, 18, 'Black', 2020, 34290, 'Used', 407000, 451000, 'Sold', '2025-12-25'),
  ('MA9CN7DVFLEUPAVC7', 15, 9, 'Black', 2020, 58618, 'Used', 890000, 996000, 'Available', '2026-06-28'),
  ('MA26FSCA31F5MLSLN', 23, 17, 'Blue', 2025, 36, 'New', 5526000, 6037000, 'Sold', '2026-02-25'),
  ('MAS7KXM8HJA1F83Y9', 13, 12, 'Black', 2025, 34, 'New', 1415000, 1529000, 'Available', '2026-01-06'),
  ('MAMWABYM6GS7L97HE', 24, 5, 'White', 2026, 20, 'New', 3986000, 4435000, 'Available', '2026-04-05'),
  ('MAVK1A5HGRX5E1U55', 20, 10, 'Red', 2022, 31350, 'Used', 802000, 862000, 'Available', '2026-06-16'),
  ('MAGBPPV2RXLGR1JY2', 15, 7, 'Red', 2024, 65797, 'Used', 1530000, 1701000, 'Available', '2026-01-26'),
  ('MAM9WCNWL4J518DWC', 18, 20, 'Blue', 2023, 46557, 'Used', 540000, 602000, 'Available', '2026-03-05'),
  ('MA9ZZ1RA3410S1ZBG', 18, 8, 'Grey', 2026, 19, 'New', 743000, 816000, 'Available', '2026-03-27'),
  ('MA0BFGHP2H6ZG3SXW', 6, 1, 'Black', 2026, 35, 'New', 1116000, 1193000, 'Available', '2026-02-06'),
  ('MAN8YMHFZSK56G4JF', 3, 1, 'Orange', 2025, 34, 'New', 866000, 923000, 'Sold', '2025-12-25');

-- SALES (20 records)
INSERT INTO sales (car_id, customer_id, employee_id, sale_date, sale_price, payment_mode) VALUES
  (29, 9, 3, '2025-12-16', 1927000, 'Loan'),
  (40, 1, 16, '2026-01-02', 914000, 'Bank Transfer'),
  (15, 12, 2, '2026-01-18', 768000, 'Cheque'),
  (1, 14, 2, '2026-01-20', 543000, 'Loan'),
  (9, 16, 3, '2026-01-24', 642000, 'UPI'),
  (23, 20, 5, '2026-02-01', 1283000, 'Cash'),
  (7, 15, 3, '2026-02-20', 1184000, 'Bank Transfer'),
  (12, 23, 6, '2026-02-25', 1275000, 'Loan'),
  (30, 17, 16, '2026-02-26', 448000, 'Bank Transfer'),
  (19, 24, 6, '2026-03-07', 3907000, 'Loan'),
  (13, 22, 20, '2026-03-16', 5115000, 'Loan'),
  (3, 3, 6, '2026-03-27', 5699000, 'Loan'),
  (32, 8, 16, '2026-04-02', 5937000, 'Loan'),
  (24, 11, 7, '2026-05-17', 1635000, 'Bank Transfer'),
  (28, 5, 16, '2026-05-20', 617000, 'Cheque'),
  (16, 4, 17, '2026-06-05', 590000, 'Loan'),
  (18, 7, 17, '2026-07-16', 5614000, 'Loan'),
  (17, 21, 6, '2026-07-20', 1085000, 'Loan'),
  (26, 19, 3, '2026-07-31', 849000, 'Bank Transfer'),
  (10, 2, 6, '2026-08-07', 1428000, 'Loan');

-- SERVICE_RECORDS (22 records)
INSERT INTO service_records (car_id, employee_id, service_date, service_type, cost, service_status) VALUES
  (5, 18, '2025-12-14', 'Brake Service', 4800, 'Completed'),
  (27, 18, '2025-12-30', 'Battery Replacement', 8600, 'Completed'),
  (7, 14, '2026-01-08', 'Tyre Replacement', 26800, 'Completed'),
  (40, 13, '2026-01-11', 'Suspension Repair', 12700, 'Completed'),
  (30, 14, '2026-01-14', 'Suspension Repair', 11300, 'Completed'),
  (9, 14, '2026-01-16', 'Brake Service', 5400, 'Completed'),
  (9, 13, '2026-01-20', 'Engine Tuning', 10700, 'Completed'),
  (14, 14, '2026-01-30', 'Oil Change', 3500, 'Completed'),
  (13, 13, '2026-02-02', 'Engine Tuning', 11800, 'Completed'),
  (4, 14, '2026-05-02', 'Detailing & Polish', 5100, 'Completed'),
  (4, 18, '2026-05-03', 'Brake Service', 6600, 'Completed'),
  (4, 18, '2026-05-07', 'Brake Service', 11200, 'Completed'),
  (6, 14, '2026-05-07', 'AC Service', 5000, 'Completed'),
  (4, 18, '2026-05-12', 'Battery Replacement', 7100, 'Completed'),
  (21, 13, '2026-06-09', 'Tyre Replacement', 21300, 'Completed'),
  (25, 13, '2026-06-23', 'AC Service', 5100, 'Completed'),
  (31, 13, '2026-07-03', 'Engine Tuning', 10700, 'Completed'),
  (26, 15, '2026-07-04', 'Brake Service', 9200, 'Completed'),
  (35, 18, '2026-07-06', 'Tyre Replacement', 41400, 'Completed'),
  (6, 15, '2026-10-12', 'Battery Replacement', 5600, 'In Progress'),
  (8, 18, '2026-10-12', 'Battery Replacement', 6200, 'In Progress'),
  (11, 15, '2026-10-13', 'Oil Change', 5000, 'In Progress');
-- Index for faster searching of inventory by status
CREATE INDEX idx_cars_status ON cars(status);
CREATE INDEX idx_cars_model  ON cars(model_id);

-- View: all cars currently available for sale
CREATE VIEW v_available_inventory AS
SELECT c.car_id, m.name AS manufacturer, cm.model_name, cm.fuel_type,
       c.color, c.manufacture_year, c.car_condition, c.selling_price
FROM cars c
JOIN car_models   cm ON cm.model_id = c.model_id
JOIN manufacturers m ON m.manufacturer_id = cm.manufacturer_id
WHERE c.status = 'Available';

-- Trigger: validate a sale and automatically mark the car as Sold
CREATE OR REPLACE FUNCTION fn_mark_car_sold() RETURNS TRIGGER AS $$
DECLARE cur_status VARCHAR;
BEGIN
    SELECT status INTO cur_status FROM cars WHERE car_id = NEW.car_id;
    IF cur_status IN ('Sold','In Service') THEN
        RAISE EXCEPTION 'Car % cannot be sold: current status is %', NEW.car_id, cur_status;
    END IF;
    UPDATE cars SET status = 'Sold' WHERE car_id = NEW.car_id;
    RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER trg_mark_car_sold
BEFORE INSERT ON sales
FOR EACH ROW EXECUTE FUNCTION fn_mark_car_sold();
