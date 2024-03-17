# Group21

## Introduction
Muse is a digital marketplace for musical instruments, appliances as well as production products. With the advancements in e-commerce and the overall digital retail environments, Muse’s purpose is to provide products for audiophiles, music producers and musicians. Unlike other local market leaders, Muse aims to only target the UK specifically, allowing a greater focus on customer satisfaction. Before moving on to the details of the report, it is essential to establish that we’ve made Muse to be a small but agile company, and have tried to create a dynamic and responsive model which can be used to sell products like guitars and bases, drums, keys, microphones, DJ equipment, cables, connectors, lighting and stage accessories, headphones, etc. We have also assumed that the company sells products as small as a guitar capo worth 5 pounds to full-size pianos worth 40,000 pounds, and the E-R diagram has been given thought and designed accordingly.

## ER diagram
The initial part of our database design was the Entity-Relationship diagram.While keeping practicality in focus, we created a structure which covers every aspect of a functional e-commerce database.

For the ER diagram, we focused mainly on three types of relationships between entities. One to One. One to Many and Many to Many. An example of a One-to-One relationship could be between the entities Advertisement and Voucher (as shown in the ER diagram). For every one Advertisement, one voucher would be passed out. Another important aspect about the Entity is the primary key, i.e the unique identifier of any entity. The customer_id is the primary key for the customer entity which would give a unique identity to every customer allowing for them to be identified with ease when need be.

For a One-to-Many relationship, we could use an example of the entities, Product and Warehouse. There is only one Warehouse where all the product inventory is located. Finally, to give an example of a Many to Many Relationships, the relationship between the entities, Product and Supplier could be described. Multiple Products could be supplied from Multiple Suppliers.

Furthermore another concept that has been applied in the diagram, specifically towards the customer entity is the Self Referencing process. The process in particular is “give referral” process. This process itself happens between customers, customers who buy a product from Muse have the potential to refer the platform to another, could be a friend, family member, band mate etc. This would lead to that customer converting the referred

![ER Diagram](https://github.com/agastyawan/DM-21/blob/main/figure/ER-Final.png?raw=true)

# SQL Database Schema

The SQL database schema conforms to the provided E-R diagram, ensuring consistency and readability through the use of lowercase letters for all names and columns. The **`e_commerce.db`** dataset has been generated and linked using the following code.

``` r eval=FALSE
# Connect Database
my_db <- RSQLite::dbConnect(RSQLite::SQLite(),"e_commerce.db")
```

## Create entities

### Customer table

In the customer entity table, it is advisable to split the customer_name attribute into 'cust_first_name' and 'cust_last_name' to ensure flexibility and consistency within the database. Additionally, the cust_referral column acts as a self-referencing foreign key, linking to the customer table's primary key, cust_id. This column facilitates tracking customer referrals within the database by establishing relationships within the customer entity.

``` sql eval=FALSE
CREATE TABLE IF NOT EXISTS customer(
  cust_id INT PRIMARY KEY,
  cust_reg_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  cust_last_name VARCHAR (100) NOT NULL,
  cust_first_name VARCHAR (100) NOT NULL,
  cust_email VARCHAR (100) UNIQUE NOT NULL,
  cust_password VARCHAR(64) NOT NULL,
  cust_phone VARCHAR (20) UNIQUE NOT NULL,
  cust_zipcode VARCHAR (10), 
  cust_street_address VARCHAR (255),
  cust_city VARCHAR (50),
  cust_county VARCHAR (10),
  membership VARCHAR(10) CHECK (membership IN ('PLATINUM', 'GOLD', 'SILVER', 'BRONZE')),
  cust_birth_date DATE,
  cust_referral INT,
  FOREIGN KEY (cust_referral) REFERENCES customer(cust_id)
  );
```

### Product table

To ensure adherence to the third normal form (3NF) and avoid transitive dependencies between non-prime attributes, the structure of the product name has been split into **`category_name`** and **`model_name`**. This separation allows for distinguishing the category of the product and avoids redundancy within the database. Each attribute is now functionally dependent only on the primary key, maintaining the integrity of the database schema.

``` sql eval=FALSE
CREATE TABLE IF NOT EXISTS product(
  product_id INT PRIMARY KEY,
  category_name VARCHAR(100),
  model_name VARCHAR(100),
  selling_price INT,
  cost_price INT,
  product_desc VARCHAR(250),
  stock_qty INT
);
```

### Supplier & Warehouse table

The **`supplier`** and **`warehouse`** tables utilise the same address structure as the **`customer`** table, encompassing attributes such as **`zipcode`**, **`street_address`**, **`city`**, and **`county`**. This approach maintains consistency across the database schema.

``` sql eval=FALSE
CREATE TABLE IF NOT EXISTS supplier(
  s_id INT PRIMARY KEY,
  s_name VARCHAR(255),
  s_zipcode VARCHAR(20),
  s_street_address VARCHAR(255),
  s_city VARCHAR(100),
  s_county VARCHAR(20),
  s_phone VARCHAR(20),
  s_email VARCHAR(255)
);
```

``` sql eval=FALSE
CREATE TABLE IF NOT EXISTS warehouse (
  w_id INT PRIMARY KEY,
  w_name VARCHAR(255) NOT NULL,
  w_zipcode VARCHAR(20) NOT NULL,
  w_street_address VARCHAR(255) NOT NULL,
  w_city VARCHAR(100),
  w_county VARCHAR(25);
```

### Ad table

The **`ad`** table displays basic advertisement information data along with its performance metrics, including impression, click, and action. Impressions, clicks, and actions are represented as integers, while cost and revenue allow for two decimal places to calculate the pounds.

``` sql eval=FALSE
CREATE TABLE IF NOT EXISTS 'ad'(
  ad_id INT PRIMARY KEY,
  media_name VARCHAR(255),
  ad_type VARCHAR(255),
  start_date DATE,
  end_date DATE,
  impression INT,
  click INT,
  cost DECIMAL(10, 2),
  action INT,
  revenue DECIMAL(10, 2)
 );
```

### Promotion table

The 'promotion_rate' column is defined as a float to ensure that it can accommodate percentages.

``` sql eval=FALSE
CREATE TABLE IF NOT EXISTS promotion (
 promotion_id INT PRIMARY KEY,  
 promotion_rate FLOAT
); 
```

## Create relationship

### Order table

This table incorporates the highest number of foreign keys from other entities, notably including **`order_id`**, **`cust_id`**, **`product_id`**, and **`promotion_id`**. Within this relationship, it has been ensured that **`order_id`**, **`cust_id`**, and **`product_id`** collectively constitute a composite primary key, thereby establishing the integrity and uniqueness of each record.

``` sql eval=FALSE
CREATE TABLE IF NOT EXISTS "order" (
  "order_id" INT,
  "order_date" DATE,
  "quantity" INT NOT NULL,
  "cust_id" INT,
  "product_id" INT,
  "payment_id" INT,
  "payment_method" VARCHAR,
  "promotion_id" INT,
  PRIMARY KEY ("order_id", "cust_id", "product_id"),
  FOREIGN KEY ("payment_id") REFERENCES "payment" ("payment_id"),
  FOREIGN KEY ("cust_id") REFERENCES "customer" ("cust_id"),
  FOREIGN KEY ("product_id") REFERENCES "product" ("product_id"),
  FOREIGN KEY ("promotion_id") REFERENCES "promotion" ("promotion_id")
```

### Sell table

The **`sell`** table comprises two foreign keys, **`s_id`** and **`product_id`**, indicating the association between suppliers and the products they sell. It is assumed that each supplier sells distinct products, ensuring clarity and accuracy in tracking product-supplier relationships within the database.

``` sql eval=FALSE
CREATE TABLE IF NOT EXISTS sell(
  s_id INT,
  product_id INT,
  FOREIGN KEY (product_id) REFERENCES product(product_id),
  FOREIGN KEY (s_id) REFERENCES supplier(s_id)
);
```

### Stock table

The **`sku`** serves as the primary key of the **`stock`** table, indicating the **`product_id`** located in different warehouses.

``` sql eval=FALSE
CREATE TABLE IF NOT EXISTS stock(
  sku INT PRIMARY KEY,
  product_id INT,
  w_id INT,
  FOREIGN KEY (product_id) REFERENCES product(product_id),
  FOREIGN KEY (w_id) REFERENCES warehouse(w_id)
);
```

### Promote table

The **`promote`** table facilitates a many-to-many relationship between products and advertisements. Each **`ad_id`** can promote several **`product_id`**s, and conversely, each **`product_id`** can be promoted by several **`ad_id`**s.

``` sql eval=FALSE
CREATE TABLE IF NOT EXISTS promote(
  product_id INT,
  ad_id INT,
  FOREIGN KEY (product_id) REFERENCES product(product_id),
  FOREIGN KEY (ad_id) REFERENCES ad (ad_id)
);
```
