# Data Management Group21

## Introduction
Muse is a musical instrument and production e-commerce platform based in the UK which uses ETL processes to streamline data handling. An E-R diagram and SQL schema represent the structure of the database while the system is tested by synthetic data. Github workflows aided in Automation which enhanced efficiency. Sales data analysis and visualisation are showcased for business insights.

## Database Design and Implementation
### ER diagram
The initial part of our database design was the Entity-Relationship diagram.While keeping practicality in focus, we created a structure which covers every aspect of a functional e-commerce database.

In the E-R diagram, we mainly focused on three entity relationships: One-to-One, One-to-Many, and Many-to-Many. For instance, a One-to-One relationship exists between Promotion and Voucher entities. Each promotion corresponds to one voucher. A crucial aspect of an entity is its primary key, a unique identifier. For the customer entity, the primary key is the customer_id, providing a unique identity for each customer. 

In a One-to-Many relationship, consider Product and Warehouse entities. All products are located in one warehouse. For a Many-to-Many relationship, consider Product and Supplier entities. Multiple suppliers can supply multiple products. 

Additionally, the diagram applies the **Self Referencing** process, specifically to the customer entity. This process, “give referral”, occurs between customers. A customer who purchases a product from Muse can refer another potential customer to the platform.

![ER Diagram](https://github.com/agastyawan/DM-21/blob/main/figure/ER-Final.png?raw=true)

### Logical Schema
The E-R diagram showcases 5 relationships among which 3 were used for explanation. The ‘supplier’, ‘sells’ and ‘product’ relationship show how suppliers connect to products through relationships (r1 and r2). Comparably, for ‘stores in’ and ‘product’, warehouses connect to the products. The primary key for the ‘order’ relationship is made up of ‘customer_ID’, ‘product_ID’ as well as ‘Order_ID’.


## SQL Database Schema

The SQL database schema conforms to the provided E-R diagram, ensuring consistency and readability through the use of lowercase letters for all names and columns. The **`e_commerce.db`** dataset has been generated and linked using the following code.

``` r eval=FALSE
# Connect Database
my_db <- RSQLite::dbConnect(RSQLite::SQLite(),"e_commerce.db")
```

#### Create entities

#### Customer Table

For the customer entity table, customer_name was split into **`cust_first_name`** and **`cust_last_name`** increasing flexibility. Customer referrals were tracked using the **`cust_referral`** column being linked to cust_ID

```` sql
```{sql, connection = my_db, eval=FALSE}
--customer
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
  FOREIGN KEY (cust_referral) REFERENCES customer(cust_id) --self referencing
  
);
```
````

#### Product Table

With adherence to 3NF, the product name is separated into **`category_name`** and **`model_name`**, removing transitive dependencies and redundancy, thus making sure each attribute is dependent on the primary key.

```` sql
```{sql, connection = my_db , eval=FALSE}
-- product
CREATE TABLE IF NOT EXISTS product(
  product_id INT PRIMARY KEY,
  category_name VARCHAR(100),
  model_name VARCHAR(100),
  selling_price INT,
  cost_price INT,
  stock_qty INT
);
```
````

#### Supplier & Warehouse Table

The **`supplier`** and **`warehouse`** tables utilise the same address structure as the **`customer`** table, encompassing attributes such as **`zipcode`**, **`street_address`**, **`city`**, and **`county`**. This approach maintains consistency across the database schema.

```` sql
```{sql, connection = my_db , eval=FALSE}
-- supplier
CREATE TABLE IF NOT EXISTS supplier (
  s_id INT PRIMARY KEY,
  s_name VARCHAR(100),
  s_zipcode VARCHAR(10),
  s_street_address VARCHAR(255),
  s_city VARCHAR(100),
  s_county VARCHAR(20),
  s_phone VARCHAR(20) UNIQUE NOT NULL,
  s_email VARCHAR(255) UNIQUE NOT NULL
);
```

```` sql
```{sql, connection = my_db}
-- warehouse 
CREATE TABLE IF NOT EXISTS 'warehouse' (
  w_id INT PRIMARY KEY,
  w_name VARCHAR(100) NOT NULL,
  w_zipcode VARCHAR(10) NOT NULL,
  w_street_address VARCHAR(255) NOT NULL,
  w_city VARCHAR(100),
  w_county VARCHAR(25)
);
```
````

#### Ad Table

The **`ad`** table displays basic advertisement information data along with its performance metrics, including impression, click, and action. Impressions, clicks, and actions are represented as integers, while cost and revenue allow for two decimal places to calculate the pounds.

```` sql
```{sql, connection = my_db , eval=FALSE}
-- ad
CREATE TABLE IF NOT EXISTS 'ad'(
  ad_id INT PRIMARY KEY,
  media_name VARCHAR(100),
  ad_type VARCHAR(100),
  start_date DATE,
  end_date DATE,
  impression INT,
  click INT,
  cost DECIMAL(10, 2),
  action INT,
  revenue DECIMAL(10, 2)
 );
```
````

#### Voucher & Promotion Table

```` sql
```{sql, connection = my_db , eval=FALSE}
-- promotion
CREATE TABLE IF NOT EXISTS promotion (
 promotion_id INT PRIMARY KEY,  
 promotion_name VARCHAR (200)
); 
```
````

```` sql
```{sql, connection = my_db , eval=FALSE}
-- voucher
CREATE TABLE IF NOT EXISTS voucher (
 voucher_code VARCHAR PRIMARY KEY,  
 voucher_rate FLOAT,
 promotion_id INT,
 FOREIGN KEY promotion_id REFERENCES promotion (promotion_id)
); 
```
````

# Generate Synthetic data

In this section, various R packages and address datasets were utilised to generate synthetic data that conforms to the previously created database schema. Datasets for all tables have been successfully generated, aligning with the E-R diagram and SQL schema. Descriptions are provided for five representative datasets to illustrate their contents.

## Personal data generation

Synthetic personal data, including addresses and phone numbers, was generated using authentic UK postcode data with city and county details. Random street names were extracted from **`street_name.csv`** for address authenticity. British phone numbers starting with '07' and consisting of nine digits were generated to meet UK telecommunication standards.

## Generating datasets for tables

### Customer data

Customer data was generated with a specific date range for registration dates **`cust_reg_date`**, ensuring it falls after the customer's birthday **`cust_birth_date`**. Names and passwords were created using the **`generator`** package, with names divided into first and last names. Customer passwords were encrypted for security. Zip codes and addresses were generated utilising the mentioned dataset.

| cust_id | cust_reg_date | cust_last_name | cust_first_name |
|---------|---------------|----------------|-----------------|
| 1       | 2020-10-14    | Clarke-Green   | Rita            |
| 2       | 2019-11-11    | Burrows        | Karl            |
| 3       | 2023-12-18    | Howard         | Holly           |


| cust_password                    |
|----------------------------------|
| 2e06cf4fda81ae33015430fed51f5127 |
| 2e06cf4fda81ae33015430fed51f5127 |
| 2e06cf4fda81ae33015430fed51f5127 |


| cust_zipcode | cust_street_address | cust_city | cust_county |
|--------------|---------------------|-----------|-------------|
| W3           | Stanley Road 51     | Ealing    | England     |
| SW2          | Church Lane 56      | Lambeth   | England     |
| SG19         | The Green 39        | Everton   | England     |


### Product data

In the product data, 30 entries are distributed among 10 distinct categories. To ensure consistency, the structure of the 'model_name' attribute across all products has been standardised. The **`cost_price`** of each product is randomly assigned within a range of 85% to 90% of the **`selling_price`**, maintaining variability while adhering to predetermined criteria.


| product_id | category_name | model_name | selling_price | stock_qty | cost_price |
|------------|---------------|------------|---------------|-----------|------------|
| 1          | keyboards     | o3t9       | 714           | 134       | 606.90     |
| 2          | flute         | l6y5       | 2359          | 153       | 2005.15    |
| 3          | guitar        | y8h6       | 1348          | 106       | 1145.80    |


### Ad data

The company employs six types of media for advertising, with each 'ad_name' derived from the corresponding **`ad_type`**. We've verified that the **`end_date`** of each ad falls after its **`start_date`**. Moreover, in accordance with industry standards, constraints have been applied, ensuring that **`impression`** exceeds **`click`**, which in turn exceeds **`action`**. Specific conditions, such as **`click`** being less than 10% of **`impression`**, are enforced.

| ad_id | media_name | ad_type   | start_date |   end_date |
|------:|:-----------|:----------|-----------:|-----------:|
|     1 | Google     | Promotion | 2020-09-29 | 2020-11-12 |
|     2 | Flyer      | Promotion | 2021-04-20 | 2021-07-06 |
|     3 | Flyer      | Cut Off   | 2018-10-26 | 2018-11-18 |


| impression | cost | revenue | click | action |
|-----------:|-----:|--------:|------:|-------:|
|       3340 | 1350 | 2970.00 |   253 |     34 |
|      26095 | 1276 |  165.88 |  1401 |     73 |
|      41469 |   34 |  151.64 |  2643 |    382 |


### Warehouse data

The company operates one warehouse for each region of England, Wales, and Scotland. The warehouse names **`w_name`** are derived from the names of the respective regions (counties). For example, warehouse 'Eng01' corresponds to the region of England and has address information based on England.


| w_id     | w_name   | w_zipcode | w_street_address | w_city     | w_county |
|----------|----------|-----------|------------------|------------|----------|
| 3        | Scot01   | G82       | Kings Road 2     | Dumbarton  | Scotland |
| 1        | Eng01    | LS23      | West Street 8    | Boston Spa | England  |
| 2        | Wales01  | SA6       | New Street 4     | Morriston  | Wales    |


### Relationship data

Relationship data is generated from many-to-many (M:N) relationships between entities, necessitating that the foreign key data is derived from existing entity data. For instance, in the order data, **`cust_id`**, **`product_id`**, and **`promotion_id`** are referenced from previously generated data. Furthermore, to ensure consistency, for orders sharing the same **`order_id`**, the **`payment_method`** has been standardized, as each order is associated with only one payment method.


| order_id | cust_id  | product_id | promotion_id | quantity | payment_method |
|----------|----------|------------|--------------|----------|----------------|
| 1        | 93       | 19         | 3            | 5        | Credit Card    |
| 2        | 24       | 24         | 2            | 2        | Debit Card     |
| 3        | 3        | 13         | 2            | 3        | Paypal         |

## Data Pipeline Generation

### Github Repository and Workflow Setup

Github Repository can be accessed through <https://github.com/agastyawan/DM-21>.

The repository has been made so that every group member can collaborate on it together by using push and pull method.

The explanation for each folder is as follows:

| No  | FolderName          | Description                                                                                                                                                                          |
|-----|---------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1   | .github/workflow    | folder to store the GitHub workflows                                                                                                                                                 |
| 2   | R                   | folder to store the R script to do structure validation, content validation, load data, and visualisation                                                                            |
| 3   | data_upload         | folder to upload new data (csv format) which will be injected after validated                                                                                                        |
| 4   | database            | folder to store the database                                                                                                                                                         |
| 5   | figure              | folder to store images which are the result of visualisation.R                                                                                                                       |
| 6   | log                 | folder to store the log file which explains about the activity (version-control on our project) on Github e.g. the result of validation and load data.                               |
| 7   | new_record          | If there are new records in data_upload, the script will generate csv file that contains the new records.                                                                            |


We create two branches: Main and Development. The main branches used as the final version of the project, meanwhile the development branch is used as testing the workflow before we pushed it to the main branch.
We compare the db schema in the development branch after merging the data to the db schema in the main branch to ensure that db schema has not changed.

### Github Repository and Workflow Setup

Github workflow set up of the automated actions. This workflow will automatically run the following action every time new data is committed:

**1.  Structure validation**
    The workflow will run the structurevalidation.R which will check the data in data_upload:
      The structure of data is similar with database
      The primary key is unique
      There is no duplicated value
      The foreign key is well referenced
      The data_type is similar with the schema
    Every step will be recorded in the logfile.

**2.  Data validation**
    The workflow will run the validation.R which will check the new records in data_upload compared to the records in database. If there is new record, it will generate new csv file in new_record folder. 
    Every step will be recorded in the logfile.

**3.  Load data**
    The workflow will run the data_load.R which will append the new_record to the database.
    
**4.  Visualisation**
    The workflow will run the visualisation.R which will produce the figure and store it to the folder figure.
