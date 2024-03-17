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

Github workflow set up of the automated actions. The code in Github workflow can be seen as follows:

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

This workflow will automatically run the following action every time new data is committed:

1.  Structure validation

    The workflow will run the structurevalidation.R which will check the data in data_upload:

    -   The structure of data is similar with database

    -   The primary key is unique

    -   There is no duplicated value

    -   The foreign key is well referenced

    -   The data_type is similar with the schema

    Every step will be recorded in the logfile.

    ``` {#structurevalidation eval="FALSE"}
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

    # Make a function to check duplicate value
    duprec <- function(tablecsv) {
      log_file <- file(filename, "a")
      if (sum(duplicated(tablecsv)) == 0) {
        message <- paste("\t There is no duplicated data in", deparse(substitute(tablecsv)))
        writeLines(message, log_file)
        close(log_file)
      } else {
        temp <- unique(tablecsv)
        write.csv(temp, file = paste("data_upload/", tablecsv, ".csv", sep = ""), row.names = FALSE)
        writeLines("\t Duplicated data have been removed", log_file)
        close(log_file)
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

2.  Data validation

    The workflow will run the validation.R which will check the new records in data_upload compared to the records in database. If there is new record, it will generate new csv file in new_record folder. For example the customer data:

    ``` {#validationdata eval="FALSE"}
    customer_db <- dbGetQuery(my_db, "SELECT * FROM customer")
    customer_push_data <- readr::read_csv("data_upload/customer.csv", col_types=cols()) 
    new_customer_records <- anti_join(customer_push_data, customer_db, by = "cust_id")
    write.csv(new_customer_records, file = "new_record/customer.csv", row.names = FALSE)
    ```

    Every step will be recorded in the logfile.

3.  Load data

    The workflow will run the data_load.R which will append the new_record to the database. For example customer:

    ``` {#load_data eval="FALSE"}
    customer_data <- readr::read_csv("new_record/customer.csv", col_types=cols(
      cust_reg_date = col_character(),
      cust_birth_date = col_character()
    )) 

    my_connection <- RSQLite::dbConnect(RSQLite::SQLite(),"database/e_commerce.db")

    RSQLite::dbWriteTable(my_connection,"customer",customer_data, append = TRUE, row.names = FALSE)
    ```

4.  Visualisation

    The workflow will run the visualisation.R which will produce the figure and store it to the folder figure.
