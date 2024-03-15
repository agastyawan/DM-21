library(readr)
library(RSQLite)
library(dplyr)

# Check primary key unique

# Make a log file
log_file <- file("log.txt", "w")
writeLines("DATA VALIDATION LOG", log_file)
writeLines(print(timestamp()), log_file)
close(log_file)

# Make a function to check primary key 
check_pk <- function(table, pk) {
  log_file <- file("log.txt", "a")
  writeLines(paste(deparse(substitute(table))), log_file)
  if (sum(duplicated(table[[pk]])) != 0) {
    message <- paste("\t Primary key in", (deparse(substitute(table))), "is not unique")
    writeLines(message, log_file)
    close(log_file)
  } else {
    writeLines("\t Sufficient primary key", log_file)
    close(log_file)
  }
}

# Make a function to check date format
IsDate <- function(mydate, date.format = "%y/%m/%d") {
  tryCatch(!is.na(as.Date(mydate, date.format)),  
           error = function(err) {FALSE})  
}

check_date <- function(table, coldate) {
  log_file <- file("log.txt", "a")
  if (sum(IsDate(table[[coldate]])) == nrow(table)) {
    message <- paste("\t Sufficient input on", (deparse(substitute(coldate))))
    writeLines(message, log_file)
    close(log_file)
  } else {
    writeLines("\t invalid format on date", log_file)
    close(log_file)
  }
}
# Make a function to check foreign key
check_fk <- function(table,fk,ref) {
  log_file <- file("log.txt", "a")
  if(all(table[[fk]] %in% ref[[fk]])) {
    message <- paste("\t The foreign key", (deparse(substitute(table)))," are well-connected ")
    writeLines(message, log_file)
    close(log_file)
  } else {
    writeLines("\t invalid reference foreign key", log_file)
    close(log_file)
  }
}

# Read the table
customer <- readr::read_csv("data_upload/customer.csv", col_types=cols()) 
ad <- readr::read_csv("data_upload/ad.csv", col_types=cols()) 
promotion <- readr::read_csv("data_upload/promotion.csv", col_types=cols()) 
product <- readr::read_csv("data_upload/product.csv", col_types=cols()) 
stock <- readr::read_csv("data_upload/stock.csv", col_types=cols()) 
supplier <- readr::read_csv("data_upload/supplier.csv", col_types=cols()) 
warehouse <- readr::read_csv("data_upload/warehouse.csv", col_types=cols()) 


# Customer
check_pk(customer,"cust_id")
## email
isValidEmail <- function(x) {
  grepl("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", as.character(x))
}

invalid_emails <- !isValidEmail(customer$cust_email)

if (sum(invalid_emails) == 0) {
  log_file <- file("log.txt", "a")
  writeLines("\t All customer emails are valid", log_file)
  close(log_file)
} else {
  log_file <- file("log.txt", "a")
  writeLines("\t There are invalid emails:", log_file)
  writeLines(as.character(customer$cust_email[invalid_emails]), log_file)
  close(log_file)
}

## Date
check_date(customer,"cust_birth_date")

### Referral
tempdata <- customer
merged_data <- merge(customer, customer[, c("cust_id", "cust_reg_date")], 
                     by.x = "cust_referral", by.y = "cust_id", all.x = TRUE, suffixes = c("", ".y"))
merged_data$cust_referral[merged_data$cust_reg_date < merged_data$cust_reg_date.y] <- ""
merged_data <- select(merged_data, cust_id, cust_reg_date, cust_last_name, cust_first_name, cust_email, cust_password, cust_phone, cust_zipcode, cust_street_address, cust_city, cust_county, membership, cust_birth_date, cust_referral)


# Ad
check_pk(ad,"ad_id")

# Product
check_pk(product,"product_id")
check_fk(product, "w_id", warehouse)

# Promotion
check_pk(promotion,"promotion_id")

# Stock
check_pk(stock,"sku")

# Supplier
check_pk(supplier,"s_id")

# Warehouse
check_pk(warehouse,"w_id")
