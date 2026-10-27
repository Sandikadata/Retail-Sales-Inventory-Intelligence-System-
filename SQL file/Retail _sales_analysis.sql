CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    phone VARCHAR(20),
    email VARCHAR(100),
    street VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    zip_code VARCHAR(10)
);

CREATE TABLE stores (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    street VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    zip_code VARCHAR(10)
);

CREATE TABLE staffs (
    staff_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(20),
    active INT,
    store_id INT,
    manager_id INT
);

CREATE TABLE brands (
    brand_id INT PRIMARY KEY,
    brand_name VARCHAR(100)
);

CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    brand_id INT,
    category_id INT,
    model_year INT,
    list_price DECIMAL(10,2)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_status INT,
    order_date DATE,
    required_date DATE,
    shipped_date DATE,
    store_id INT,
    staff_id INT
);

CREATE TABLE order_items (
    order_id INT,
    item_id INT,
    product_id INT,
    quantity INT,
    list_price DECIMAL(10,2),
    discount DECIMAL(4,2)
);

CREATE TABLE stocks (
    store_id INT,
    product_id INT,
    quantity INT
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    brand_id INT,
    category_id INT,
    model_year INT,
    list_price DECIMAL(10,2)
);

COPY customers
FROM 'E:\Internship2026\Reatil_sales_Dasboard\reatil_sale_csv file/customers.csv'
DELIMITER ','
CSV HEADER;

COPY products
FROM 'E:\Internship2026\Reatil_sales_Dasboard\reatil_sale_csv file/products.csv'
DELIMITER ','
CSV HEADER;

COPY stores
FROM 'E:\Internship2026\Reatil_sales_Dasboard\reatil_sale_csv file/stores.csv'
DELIMITER ','
CSV HEADER
NULL 'NULL';

COPY order_items
FROM 'E:\Internship2026\Reatil_sales_Dasboard\reatil_sale_csv file/order_items.csv'
DELIMITER ','
CSV HEADER;

COPY stocks
FROM 'E:\Internship2026\Reatil_sales_Dasboard\reatil_sale_csv file/stocks.csv'
DELIMITER ','
CSV HEADER;
COPY  categories
FROM 'E:\Internship2026\Reatil_sales_Dasboard\reatil_sale_csv file/categories.csv'
DELIMITER ','
CSV HEADER;

COPY brands
FROM 'E:/Internship2026/Reatil_sales_Dasboard/reatil_sale_csv file/brands.csv'
DELIMITER ','
CSV HEADER;

COPY stocks
FROM 'E:\Internship2026\Reatil_sales_Dasboard\reatil_sale_csv file/stocks.csv'
DELIMITER ','
CSV HEADER
NULL 'NULL';

COPY staffs
FROM 'E:\Internship2026\Reatil_sales_Dasboard\reatil_sale_csv file/staffs.csv'
DELIMITER ','
CSV HEADER
NULL 'NULL';



COPY orders
FROM 'E:\Internship2026\Reatil_sales_Dasboard\reatil_sale_csv file/orders.csv'
DELIMITER ','
CSV HEADER
NULL 'NULL';

SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM stores;

--STORE-WISE SALES ANALYSIS--

SELECT
s.store_name,
ROUND(
SUM(oi.quantity * oi.list_price * (1-oi.discount))::numeric,
2
) AS total_sales
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN stores s
ON o.store_id = s.store_id
GROUP BY s.store_name
ORDER BY total_sales DESC;

--REGION WISE NALYSIS---
SELECT
s.state,
ROUND(
SUM(oi.quantity * oi.list_price * (1-oi.discount))::numeric,
2
) AS regional_sales
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN stores s
ON o.store_id = s.store_id
GROUP BY s.state
ORDER BY regional_sales DESC;

---PRODUCT WISE ANALYSIS--
SELECT
p.product_name,
SUM(oi.quantity) AS total_quantity,
ROUND(
SUM(oi.quantity * oi.list_price * (1-oi.discount))::numeric,
2
) AS total_sales
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_sales DESC;

---TOP SELLING BRAND--
SELECT
b.brand_name,
ROUND(
SUM(oi.quantity * oi.list_price * (1-oi.discount))::numeric,
2
) AS sales
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
JOIN brands b
ON p.brand_id = b.brand_id
GROUP BY b.brand_name
ORDER BY sales DESC;

---STAFF PERFORMANCE REPORT--
SELECT
st.first_name || ' ' || st.last_name AS staff_name,
COUNT(o.order_id) AS total_orders,
ROUND(
SUM(oi.quantity * oi.list_price * (1-oi.discount))::numeric,
2
) AS sales_handled
FROM orders o
JOIN staffs st
ON o.staff_id = st.staff_id
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY staff_name
ORDER BY sales_handled DESC;



----CUSTOMER   ORDER ANALYSIS--
SELECT
c.first_name || ' ' || c.last_name AS customer_name,
COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY customer_name
ORDER BY total_orders DESC;

---INVENTORY ANALYSIS---
SELECT
s.store_name,
p.product_name,
st.quantity
FROM stocks st
JOIN stores s
ON st.store_id = s.store_id
JOIN products p
ON st.product_id = p.product_id
ORDER BY st.quantity ASC;

---Low stock alert---
SELECT
s.store_name,
p.product_name,
st.quantity
FROM stocks st
JOIN stores s
ON st.store_id = s.store_id
JOIN products p
ON st.product_id = p.product_id
WHERE st.quantity < 10
ORDER BY st.quantity;

---Monthly END
SELECT
EXTRACT(YEAR FROM order_date) AS year,
EXTRACT(MONTH FROM order_date) AS month,
COUNT(order_id) AS total_orders
FROM orders
GROUP BY year, month
ORDER BY year, month;

---DELAY SHIPMENT ANALYSIS
SELECT
order_id,
required_date,
shipped_date,
(shipped_date - required_date) AS delay_days
FROM orders
WHERE shipped_date > required_date;


---REVENUE AND DISCOUNT ANALYSIS
SELECT
ROUND(
SUM(quantity * list_price)::numeric,
2
) AS gross_revenue,

ROUND(
SUM(quantity * list_price * discount)::numeric,
2
) AS discount_amount,

ROUND(
SUM(quantity * list_price * (1-discount))::numeric,
2
) AS net_revenue

FROM order_items;

---SQL View for power bi--
CREATE VIEW sales_dashboard AS
SELECT
o.order_id,
o.order_date,
c.first_name,
c.last_name,
s.store_name,
s.state,
p.product_name,
cat.category_name,
b.brand_name,
oi.quantity,
oi.list_price,
oi.discount,
(oi.quantity * oi.list_price * (1-oi.discount)) AS sales
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
JOIN stores s
ON o.store_id = s.store_id
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN products p
ON oi.product_id = p.product_id
JOIN categories cat
ON p.category_id = cat.category_id
JOIN brands b
ON p.brand_id = b.brand_id;