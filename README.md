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

##### Customer Table

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

##### Product Table

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

##### Supplier & Warehouse Table

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

##### Ad Table

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

##### Voucher & Promotion Table

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

#### Create Relationship

##### Order Table

Within this relationship, it has been ensured that **`order_id`**, **`cust_id`**, and **`product_id`** collectively constitute a composite primary key, thereby establishing the integrity and uniqueness of each record.

```` sql
```{sql, connection = my_db , eval=FALSE}
-- order
CREATE TABLE IF NOT EXISTS "order" (
  "order_id" INT,
  "order_date" DATE,
  "quantity" INT NOT NULL,
  "cust_id" INT,
  "product_id" INT,
  "payment_method" VARCHAR,
  "voucher_code" INT,
  PRIMARY KEY ("order_id", "cust_id", "product_id"),
  FOREIGN KEY ("cust_id") REFERENCES "customer" ("cust_id"),
  FOREIGN KEY ("product_id") REFERENCES "product" ("product_id"),
  FOREIGN KEY ("voucher_code") REFERENCES "voucher" ("voucher_code")
);
```
````

##### Sell Table

```` sql
```{sql, connection = my_db , eval=FALSE}
-- sell
CREATE TABLE IF NOT EXISTS sell(
  s_id INT,
  product_id INT,
  FOREIGN KEY (product_id) REFERENCES product(product_id),
  FOREIGN KEY (s_id) REFERENCES supplier(s_id)
);
```
````

##### Stock Table

```` sql
```{sql, connection = my_db , eval=FALSE}
-- stock
CREATE TABLE IF NOT EXISTS stock(
  sku INT PRIMARY KEY,
  product_id INT,
  w_id INT,
  FOREIGN KEY (product_id) REFERENCES product(product_id),
  FOREIGN KEY (w_id) REFERENCES warehouse(w_id)
);
```
````

##### Promote Table

```` sql
```{sql, connection = my_db , eval=FALSE}
-- promote

CREATE TABLE IF NOT EXISTS promote(
  product_id INT,
  ad_id INT,
  FOREIGN KEY (product_id) REFERENCES product(product_id),
  FOREIGN KEY (ad_id) REFERENCES ad (ad_id)
);
```
````


## Generating Datasets for Tables
### Customer Data

Customer data was generated with a specific date range for registration dates **`cust_reg_date`**, ensuring it falls after the customer's birthday **`cust_birth_date`**. Names and passwords were created using the **`generator`** package, with names divided into first and last names. Customer passwords were encrypted for security.
``` r
```{r , eval=FALSE}
n <- 200
set.seed(1)
membership_type <- c("SILVER", "BRONZE", "GOLD", "PLATINUM")

customer <- data.frame(
  cust_id = seq(n),
  cust_reg_date = r_date_of_births(n, start = as.Date("2018-01-01"), end = Sys.Date()),
  cust_full_name = ch_name(n, locale = "en_GB", messy = FALSE),
  cust_email = r_email_addresses(n),
  cust_password = r_national_identification_numbers(n),
  cust_phone = phone_number_custom(n),
  postcode = sample(x = postcode, size = n, replace = TRUE),
  cust_street_address = paste0(sample(x = st_name, size = n, replace = TRUE), " ", sample(1:99, n, replace = TRUE)),
  membership = sample(x = membership_type, size = n, replace = TRUE),
  cust_birth_date = r_date_of_births(n, start = as.Date("1970-01-01"), end = as.Date("2010-01-01")),
  cust_referral = sample(0:n, size = n, replace = TRUE),
  stringsAsFactors = FALSE
)

# Split the first name and last name
customer$cust_first_name <- sapply(strsplit(as.character(customer$cust_full_name), " "), function(x) paste(x[-length(x)], collapse = " "))
customer$cust_last_name <- sapply(strsplit(as.character(customer$cust_full_name), " "), function(x) tail(x, 1))

# Customer password
customer$cust_password <- digest(customer$cust_password, algo = "md5", serialize = FALSE)

# Customer address
customer <- merge(customer, address_db, by = "postcode", all.x = TRUE)
customer$cust_zipcode <- customer$postcode
customer$cust_city <- customer$town
customer$cust_county <- customer$country_string

# Select customer data
customer <- select(customer, cust_id, cust_reg_date, cust_last_name, cust_first_name, cust_email, cust_password, cust_phone, cust_zipcode, cust_street_address, cust_city, cust_county, membership, cust_birth_date, cust_referral)

# Generate CSV data
write.csv(customer, file = "customer.csv", row.names = FALSE)
```

| cust_id | cust_reg_date | cust_last_name | cust_first_name |
|---------|---------------|----------------|-----------------|
| 1       | 2020-10-14    | Clarke-Green   | Rita            |
| 2       | 2019-11-11    | Burrows        | Karl            |
| 3       | 2023-12-18    | Howard         | Holly           |

: customer reg_date and name

| cust_password                    |
|----------------------------------|
| 2e06cf4fda81ae33015430fed51f5127 |
| 2e06cf4fda81ae33015430fed51f5127 |
| 2e06cf4fda81ae33015430fed51f5127 |

: customer password

| cust_zipcode | cust_street_address | cust_city | cust_county |
|--------------|---------------------|-----------|-------------|
| W3           | Stanley Road 51     | Ealing    | England     |
| SW2          | Church Lane 56      | Lambeth   | England     |
| SG19         | The Green 39        | Everton   | England     |

: customer address

### Product Data

To ensure consistency, the structure of the 'model_name' attribute across all products has been standardised. The **`cost_price`** of each product is randomly assigned within a range of 85% to 90% of the **`selling_price`**, maintaining variability while adhering to predetermined criteria.

``` r
```{r , eval=FALSE}
n <- 30
set.seed(1)

# Generate product data frame
product <- data.frame(
  product_id = 1:n,
  category_name = sample(c('guitar', 'drum', 'base', 'keyboards', 'pianos', 'saxophones', 'flute', 'violin', 'cello', 'harp', 'chimes', 'french horn', 'trumpet', 'bagpipe', 'microphone', 'cable', 'connector', 'lightning', 'headphone'), n, replace = TRUE),
  model_name = sapply(1:30, function(x) paste0(sample(letters, 2, replace = TRUE), sample(0:9, 2, replace = TRUE), collapse = '')),
  selling_price = NA,  # Initialize selling_price column
  stock_qty = sample(30:300, n, replace = TRUE)
)

# Set selling price based on category_name
product$selling_price <- ifelse(product$category_name == "harp", 
                                sample(1100:3000, n, replace = TRUE), 
                                ifelse(product$category_name %in% c("guitar", "base", "flute", "violin", "cello", "chimes", "french horn", "trumpet", "bagpipe"), 
                                       sample(1000:2599, n, replace = TRUE), 
                                       sample(50:999, n, replace = TRUE)))

# Add cost_price column
product$cost_price <- ifelse(product$category_name == 'pianos', product$selling_price * 0.90,
                             ifelse(product$category_name %in% c('guitar', 'drum', 'base', 'keyboards', 'saxophones', 'flute', 'violin', 'cello', 'harp', 'chimes', 'french horn', 'trumpet', 'bagpipe'), product$selling_price * 0.85,
                                    product$selling_price * 0.90))

# Save product.csv
write.csv(product, file = "product.csv", row.names = FALSE)
```

+------------+---------------+------------+---------------+-----------+------------+
| product_id | category_name | model_name | selling_price | stock_qty | cost_price |
+===========:+:==============+:===========+==============:+==========:+===========:+
| 1          | keyboards     | o3t9       | 714           | 134       | 606.90     |
+------------+---------------+------------+---------------+-----------+------------+
| 2          | flute         | l6y5       | 2359          | 153       | 2005.15    |
+------------+---------------+------------+---------------+-----------+------------+
| 3          | guitar        | y8h6       | 1348          | 106       | 1145.80    |
+------------+---------------+------------+---------------+-----------+------------+

: product data

### Promotion Data

``` r
```{r, eval=FALSE}
n <- 30

# Set seed
set.seed(2)

# Generate promotion IDs
promotion_id <- seq(n)

# Generate promotion rate convert to percentage
promotion_name <- sample(c('BirthdayBonus', 'VIP', 'Referral', 'SpringSale', 'BackTOSchool', 'MerryChristmas', 'WelcomeNewYear', 'ValentineValue', 'NewcommerWelcome', 'EasterSurprise'), 30, replace = TRUE)

# Combine data
promotion <- data.frame(promotion_id, promotion_name = promotion_name)

# Save the data frame to a CSV file
write.csv(promotion, "promotion.csv", row.names = FALSE)
```


### Voucher Data

``` r
```{r, eval=FALSE}
n <- 30

# Set seed
set.seed(2)

# Generate promotion IDs
voucher_code <- paste0("UK", sprintf("%02d", 1:30))

# Generate promotion rate convert to percentage
voucher_rate <- sample(c('0.05', '0.10', '0.15', '0.20', '0.25', '0.30'), 30, replace = TRUE)

# Combine data
voucher <- data.frame(
  voucher_code = voucher_code,
  voucher_rate = voucher_rate,
  promotion_id = sample(promotion$promotion_id, n, replace = TRUE),
  stringsAsFactors = FALSE
)

# Save the data frame to a CSV file
write.csv(voucher, "voucher.csv", row.names = FALSE)
```


### Ad Data

The company uses six media types for advertising, with ‘ad_name’ based on ad_type. Industry standards dictate that **`impression`** should surpass **`click`**, which should exceed action. Conditions like **`click`** being less than 10% of **`impression`** are enforced.

``` r
```{r, eval=FALSE}
n <- 200

# Define the function to generate synthetic data with specified conditions
generate_synthetic_data <- function(n) {
  media_type <- c("Website", "Facebook", "Instagram", "Tiktok", "Google", "Flyer")
  ad_type <- c("Discount", "Cut Off", "Promotion", "Bonus", "Freebies")
  
  ad_data <- data.frame(
    ad_id = seq(n),
    media_name = sample(x = media_type, size = n, replace = TRUE),
    ad_type = paste0(sample(x = ad_type, size = n, replace = TRUE)),
    start_date = as.Date(sample(seq(as.Date("2018-01-01"), Sys.Date(), by = "day"), n, replace = TRUE)),
    impression = sample(100:1000, n, replace = TRUE),
    stringsAsFactors = FALSE
  )
  
  ad_data$end_date <- ad_data$start_date + sample(1:90, n, replace = TRUE)
  ad_data$impression <- sample(1000:50000, n, replace = TRUE)
  ad_data$cost <- sample(10:1500, n, replace = TRUE)
  ad_data$revenue <- ad_data$cost * sample(seq(0.1, 5, by = 0.01), n, replace = TRUE)
  ad_data$click <- round(ad_data$impression * runif(n, 0.05, 0.1))
  ad_data$action <- round(ad_data$click * runif(n, 0.05, 0.2))
  
  # Filter out rows based on conditions
  ad <- ad_data %>%
    filter(impression >= 1000,
           click < impression * 0.1,
           action < click * 0.2,
           cost >= click * 0.3,
           cost <= click * 2,
           revenue >= cost * 0.1,
           revenue <= cost * 5)
  
  return(ad_data)
}


# Generate synthetic data
n <- 200
ad <- generate_synthetic_data(n)

# Write data to CSV
write.csv(ad, file = "ad.csv", row.names = FALSE)
```


| ad_id | media_name | ad_type   | start_date |   end_date |
|------:|:-----------|:----------|-----------:|-----------:|
|     1 | Google     | Promotion | 2020-09-29 | 2020-11-12 |
|     2 | Flyer      | Promotion | 2021-04-20 | 2021-07-06 |
|     3 | Flyer      | Cut Off   | 2018-10-26 | 2018-11-18 |

: ad specification

| impression | cost | revenue | click | action |
|-----------:|-----:|--------:|------:|-------:|
|       3340 | 1350 | 2970.00 |   253 |     34 |
|      26095 | 1276 |  165.88 |  1401 |     73 |
|      41469 |   34 |  151.64 |  2643 |    382 |

: ad performance

### Supplier Data

``` r
```{r , eval=FALSE}
n <- 10
s_phone <- phone_number_custom(n)
s_email <- r_email_addresses(n)

supplier <- data.frame(
  s_id = seq(n),
  s_name = c('Harmony Haven Instruments', 'Melody Masters Music Emporium', 'Rhythmic Resonance Supplies', 'Crescendo Corner', 'Sonic Spectrum Distributors', 'Tempo Treasures Inc.', 'Aria Attic Instruments', 'Virtuoso Ventures', 'Serenade Suppliers', 'Allegro Accessories Outlet'),
  postcode = sample(x = postcode, size = n, replace = TRUE),
  s_street_address = paste0(sample(x = st_name, size = n, replace = TRUE), " ", sample(1:10, n, replace = TRUE)),
  s_phone = s_phone,
  s_email = s_email
)

supplier <- merge(supplier, address_db, by = "postcode", all.x = TRUE)
supplier$s_zipcode <- supplier$postcode
supplier$s_city <- supplier$town
supplier$s_county <- supplier$country_string

supplier <- select(supplier, s_id, s_name, s_zipcode, s_street_address, s_city, s_county, s_phone, s_email)

# Save supplier.csv
write.csv(supplier, file = "supplier.csv", row.names = FALSE)
```


### Warehouse Data

The company operates one warehouse for each region of England, Wales, and Scotland. The warehouse names **`w_name`** are derived from the names of the respective regions (counties).

``` r
```{r, eval=FALSE}
n <- 3

# Create warehouse data frame with three rows
warehouse <- data.frame(
  w_id = seq(n),
  w_name = c('Eng01', 'Wales01', 'Scot01'),
  w_street_address = paste0(sample(x = st_name, size = n, replace = TRUE), " ", sample(1:10, n, replace = TRUE)),
  w_county = c('England', 'Wales', 'Scotland'),
  stringsAsFactors = FALSE  # Avoids creating factors for character variables
)

# Sample postcodes for each region
sampled_postcodes <- sapply(warehouse$w_county, function(county) {
  subset_postcodes <- address_db$postcode[address_db$country_string == county]
  if (length(subset_postcodes) > 0) {
    return(sample(subset_postcodes, 1))
  } else {
    return(NA)  # Handle the case where there are no postcodes for the specified county
  }
})

# Add sampled postcodes to the warehouse data
warehouse$postcode <- sampled_postcodes

# Assuming address_db is a data frame or tibble with columns w_zipcode, w_city, etc.
# Merge with address_db
warehouse <- merge(warehouse, address_db, by = "postcode", all.x = TRUE)
warehouse$w_zipcode <- warehouse$postcode
warehouse$w_city <- warehouse$town

# Select relevant columns
warehouse <- warehouse %>%
  select(w_id, w_name, w_zipcode, w_street_address, w_city, w_county)

# Save warehouse.csv
write.csv(warehouse, file = "warehouse.csv", row.names = FALSE)
```


+----------+----------+-----------+------------------+------------+----------+
| w_id     | w_name   | w_zipcode | w_street_address | w_city     | w_county |
+=========:+:=========+:==========+:=================+:===========+:=========+
| 3        | Scot01   | G82       | Kings Road 2     | Dumbarton  | Scotland |
+----------+----------+-----------+------------------+------------+----------+
| 1        | Eng01    | LS23      | West Street 8    | Boston Spa | England  |
+----------+----------+-----------+------------------+------------+----------+
| 2        | Wales01  | SA6       | New Street 4     | Morriston  | Wales    |
+----------+----------+-----------+------------------+------------+----------+

: warehouse data

### Promote Data

``` r
```{r, eval=FALSE}
n <- 200

# Create promote data frame
promote <- data.frame(ad_id = sample(ad$ad_id, n, replace = TRUE),
                      product_id = sample(product$product_id, n, replace = TRUE),
                      stringsAsFactors = FALSE)

# Save promote.csv
write.csv(promote, file = "promote.csv", row.names = FALSE)
```


### Stock Data

``` r
```{r, eval=FALSE}
# Set seed for reproducibility
set.seed(1)

# Create stock data frame
stock <- data.frame(
  sku = 1:30,  # Assuming 30 rows as there are 30 products
  product_id = sample(product$product_id, 30, replace = TRUE),
  w_id = sample(warehouse$w_id, 30, replace = TRUE)
)

# Save stock.csv
write.csv(stock, file = "stock.csv", row.names = FALSE)
```



### Order Data

Order data was produced within a specific date range, with more data in certain periods to highlight monthly trends. We made sure **`cust_id`**, **`product_id`**, and **`voucher_code`** were referenced from previously generated data. Also, for orders with identical order_id, we standardized the payment_method since each order can only use one payment method.

``` r
```{r, eval=FALSE}
library(dplyr)

n <- 500

# Generate order IDs
order_id <- seq(n)

# Generate customer order dates
start_date <- as.Date("2022-01-01")
end_date <- as.Date("2024-12-31")

# Generate more orders in March, September, and December
extra_dates <- c(
  sample(seq(as.Date("2024-03-01"), as.Date("2024-03-31"), by = "day"), size = 30, replace = TRUE),
  sample(seq(as.Date("2024-09-01"), as.Date("2024-09-30"), by = "day"), size = 30, replace = TRUE),
  sample(seq(as.Date("2024-12-01"), as.Date("2024-12-31"), by = "day"), size = 50, replace = TRUE),
  sample(seq(as.Date("2023-03-01"), as.Date("2023-03-31"), by = "day"), size = 25, replace = TRUE),
  sample(seq(as.Date("2023-09-01"), as.Date("2023-09-30"), by = "day"), size = 20, replace = TRUE),
  sample(seq(as.Date("2023-12-01"), as.Date("2023-12-31"), by = "day"), size = 40, replace = TRUE),
  sample(seq(as.Date("2022-03-01"), as.Date("2022-03-31"), by = "day"), size = 20, replace = TRUE),
  sample(seq(as.Date("2022-09-01"), as.Date("2022-09-30"), by = "day"), size = 15, replace = TRUE),
  sample(seq(as.Date("2022-12-01"), as.Date("2022-12-31"), by = "day"), size = 30, replace = TRUE)
)

order_date <- c(sample(seq(start_date, end_date, by = "day"), size = 240), extra_dates)

# Generate quantities as three-digit numbers that are multiples of 5
quantity <- sample(1:5, size = n, replace = TRUE)

# Generate customer IDs
cust_id <- sample(customer$cust_id, n, replace = TRUE)

# Generate product IDs
product_id <- sample(product$product_id, n, replace = TRUE)

# Generate payment methods (assuming 1 = Credit Card, 2 = Debit Card, 3 = Cash)
# Generate a consistent payment method for each unique order_id, cust_id, and product_id
payment_methods <- c("Credit Card", "Debit Card", "Paypal")
payment_method <- rep(payment_methods, length.out = n)

# Generate promotion IDs
voucher_code <- sample(voucher$voucher_code, n, replace = TRUE)

# Combine data
order <- data.frame(
  order_id = order_id,
  order_date = order_date,
  quantity = quantity,
  cust_id = cust_id,
  product_id = product_id,
  payment_method = payment_method,
  voucher_code = voucher_code
)

# Save the data frame to a CSV file
write.csv(order, "order.csv", row.names = FALSE)
```


+----------+----------+------------+--------------+----------+----------------+
| order_id | cust_id  | product_id | voucher_code | quantity | payment_method |
+=========:+=========:+===========:+=============:+=========:+:===============+
| 1        | 93       | 19         | UK01         | 5        | Credit Card    |
+----------+----------+------------+--------------+----------+----------------+
| 2        | 24       | 24         | UK02         | 2        | Debit Card     |
+----------+----------+------------+--------------+----------+----------------+
| 3        | 3        | 13         | UK03         | 3        | Paypal         |
+----------+----------+------------+--------------+----------+----------------+

: order data

### Sell Data

``` r
```{r, eval=FALSE}
n<-50

# Set seed (optional)
set.seed(123)

# Combine data
sell <- data.frame(
  s_id = sample(supplier$s_id, n, replace = TRUE),
  product_id = sample(product$product_id, n, replace = TRUE)
)

# Save the data frame to a CSV file
write.csv(sell, "sell.csv", row.names = FALSE)
```

##  Data Import and Quality Assurance
The synthetic data will be validated automatically before can be imported with github action. This part consist of 3 step:


1.  Structure validation

    The script will check data in data_upload whether:

    -   The structure of data is similar with database

    -   The primary key is unique

    -   There is no duplicated value

    -   The foreign key is well referenced

    -   The data_type is similar with the schema


``` r
    ``` {r, #structurevalidation, eval=FALSE}
    # Make a log file
    filename <- file.path("log", paste("log", format(Sys.time(), "%y%m%d_%H%M"), ".txt"))
    log_file <- file(filename, "w")
    writeLines("STRUCTURE DATA VALIDATION LOG", log_file)
    writeLines(print(timestamp()), log_file)
    close(log_file)

    # Make a function to check the variable
    checkcol <- function(tabledb, tablecsv) {
      log_file <- file(filename, "a")
      db_column_names <- sort(dbListFields(my_db, tabledb))
      csv_column_names <- sort(colnames(tablecsv))
      if (identical(db_column_names, csv_column_names)) {
        message <- paste("\t All columns in", (deparse(substitute(table))), "are similar")
        writeLines(message, log_file)
        close(log_file)
      } else {
        writeLines("\t The columns are different", log_file)
        close(log_file)
        stop("Stopping workflow execution.")
      }
    }

    # Make a function to check primary key 
    check_pk <- function(table, pk) {
      log_file <- file(filename, "a")
      if (sum(duplicated(table[[pk]])) != 0) {
        message <- paste("\t Primary key in", (deparse(substitute(table))), "is not unique")
        writeLines(message, log_file)
        close(log_file)
        stop("Stopping workflow execution.")
      } else {
        writeLines("\t Sufficient primary key", log_file)
        close(log_file)
      }
    }

    duprec <- function(tablecsv, filename) {
      log_file <- file(filename, "a")
      if (sum(duplicated(tablecsv)) == 0) {
        message <- paste("\t There is no duplicated data in", deparse(substitute(tablecsv)))
        writeLines(message, log_file)
        close(log_file)
      } else {
        writeLines("\t There is duplicated data", log_file)
        close(log_file)
        stop("Stopping workflow execution.")
      }
    }

    # Make a function to check date format
    IsDate <- function(mydate, date.format = "%y-%m-%d") {
      tryCatch(!is.na(as.Date(mydate, date.format)),  
               error = function(err) {FALSE})  
    }

    check_date <- function(table, coldate) {
      log_file <- file(filename, "a")
      if (sum(IsDate(table[[coldate]])) == nrow(table)) {
        message <- paste("\t The data type in ", deparse(substitute(col))," is sufficient")
        writeLines(message, log_file)
        close(log_file)
      } else {
        message <- paste("\t The data type in ", deparse(substitute(col))," is invalid")
        writeLines(message, log_file)
        close(log_file)
        stop("Stopping workflow execution.")
      }
    }

    # Make a function to check foreign key
    check_fk <- function(table,fk,ref) {
      log_file <- file(filename, "a")
      if(all(table[[fk]] %in% ref[[fk]])) {
        message <- paste("\t The foreign key are well-connected ")
        writeLines(message, log_file)
        close(log_file)
      } else {
        message <- paste("\t There are some invalid foreign key")
        writeLines("\t invalid reference foreign key", log_file)
        close(log_file)
        stop("Stopping workflow execution.")
      }
    }

    # Make a function to check numeric datatype
    check_num <- function(table,col) {
      log_file <- file(filename, "a")
      if (all(sapply(table[[col]], is.numeric))) {
        message <- paste("\t The data type in ", deparse(substitute(col))," is sufficient")
        writeLines(message, log_file)
        close(log_file)
      } else {
        message <- paste("\t The data type in ", deparse(substitute(col))," is sufficient")
        writeLines(message, log_file)
        close(log_file)
        stop("Stopping workflow execution.")
      }
    }

    isValidEmail <- function(x) {
      grepl("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", as.character(x))
    }
    ```
````

2.  Data validation

     	The script will check the new records in data_upload compared to the records in database. If there is new record, it will generate new csv file in new_record folder. For example the customer data:

``` r
    ``` {r, #validationdata, eval=FALSE}
    customer_db <- dbGetQuery(my_db, "SELECT * FROM customer")
    customer_push_data <- readr::read_csv("data_upload/customer.csv", col_types=cols()) 
    new_customer_records <- anti_join(customer_push_data, customer_db, by = "cust_id")
    write.csv(new_customer_records, file = "new_record/customer.csv", row.names = FALSE)
    ```
````

3.  Load data

     	The script will append the new_record to the database. For example customer:

``` r
    ``` {r, #load_data, eval=FALSE}
    customer_data <- readr::read_csv("new_record/customer.csv", col_types=cols(
      cust_reg_date = col_character(),
      cust_birth_date = col_character()
    )) 

    my_connection <- RSQLite::dbConnect(RSQLite::SQLite(),"database/e_commerce.db")

    RSQLite::dbWriteTable(my_connection,"customer",customer_data, append = TRUE, row.names = FALSE)
    ```
````


# Data Pipeline Generation

## Github Repository and Workflow Setup

Github Repository can be accessed through [link](https://github.com/agastyawan/DM-21){.uri}.

The repository has been made so that every group member can collaborate on it together by using push and pull method.

The explanation for each folder is as follows:

1.  *github/workflow*: folder to store the GitHub workflows

2.  *R*: folder to store the R script to do structure validation, content validation, load data, and visualisation

3.  *data_upload* : forlder to upload new data (csv format) which will be injected after validated 

4.  *database* : folder to store the database

5.  *figure* : folder to store images which are the result of visualisation.

6.  *log* : folder to store the log file which explains about the activity on Github e.g. the result of validation and load data. The logfile can also be used to do version-control on our project.

7.  *new_record* : the content validation script will compare the data from database and data_upload. If there are new records in data_upload, the script will generate csv file that contains the new records.


We create two branches: Main and Development. The main branches used as the final version of the project, meanwhile the development branch is used as testing the workflow before we pushed it to the main branch.

We compare the db schema in the development branch after merging the data to the db schema in the main branch to ensure that db schema has not changed.


## GitHub Actions for Continuous Integration

Github workflow set up of the automated actions. The code in Github workflow can be seen as follows:

``` r
``` {#github.workflow eval="FALSE"}
 name: DM-21

on:
#  schedule:
#    - cron: '0 */3 * * *' # Run every 3 hours
  push:
    branches: [ main ]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
      - name: Setup R environment
        uses: r-lib/actions/setup-r@v2
        with:
          r-version: '4.2.0'
      - name: Cache R packages
        uses: actions/cache@v2
        with:
          path: ${{ env.R_LIBS_USER }}
          key: ${{ runner.os }}-r-${{ hashFiles('**/lockfile') }}
          restore-keys: |
            ${{ runner.os }}-r-
      - name: Install packages
        if: steps.cache.outputs.cache-hit != 'true'
        run: |
          Rscript -e 'install.packages(c("ggplot2","dplyr","readr","RSQLite"))'
      - name: Execute R script validation2
        run: |
          Rscript R/structurevalidation.R
      - name: Execute R script validation
        run: |
          Rscript R/validation.R
      - name: Execute R script
        run: |
          Rscript R/data_load.R
      - name: Execute R script Visualisation
        run: |
          Rscript R/visualisation.R
      - name: Commit and push changes
        run: |
          git config --global user.name "agastyawan"
          git config --global user.email "agastyawan@gmail.com"
          git add .
          git commit -m "Write new data"
          git push
      - name: Push changes
        uses: ad-m/github-push-action@v0.6.0
        with:
            github_token: ${{ secrets.DM21 }}
            branch: main
```



This workflow will automatically run the validation, dataload, & visualisation  every time new data is committed. Every step will be recorded in the logfile.




