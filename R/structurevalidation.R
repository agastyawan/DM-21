library(readr)
library(RSQLite)
library(dplyr)

# Make a log file
filename <- file.path("log", paste("log", format(Sys.time(), "%y%m%d_%H%M"), ".txt"))
log_file <- file(filename, "w")
writeLines("STRUCTURE DATA VALIDATION LOG", log_file)
writeLines(print(timestamp()), log_file)
close(log_file)


#Make a function to check data structure
checkcol <- function(name) {
  log_file <- file(filename, "a")
  csv <- readr::read_csv(paste0("data_upload/", name, ".csv"), col_types = cols())
  db <- DBI::dbReadTable(my_db, name)
  db_column_names <- sort(names(db))
  csv_column_names <- sort(names(csv))
  
  if (identical(db_column_names, csv_column_names)) {
    message <- paste("\t All columns in", name , "are similar")
    writeLines(message, log_file)
  } else {
    writeLines("\t The columns are different", log_file)
    stop("Stopping workflow execution.")
  }
  
  close(log_file)
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
duprec <- function(tablecsv, name) {
  log_file <- file(filename, "a")
  if (sum(duplicated(tablecsv)) == 0) {
    message <- paste("\t There is no duplicated data in", deparse(substitute(tablecsv)))
    writeLines(message, log_file)
    close(log_file)
  } else {
    temp <- unique(tablecsv)
    fcsv <-paste("data_upload/", name, ".csv",sep="")
    write.csv(temp, file = fcsv, row.names = FALSE)
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

# Read the table
customer <- readr::read_csv("data_upload/customer.csv", col_types=cols()) 
ad <- readr::read_csv("data_upload/ad.csv", col_types=cols()) 
promotion <- readr::read_csv("data_upload/promotion.csv", col_types=cols()) 
stock <- readr::read_csv("data_upload/stock.csv", col_types=cols()) 
supplier <- readr::read_csv("data_upload/supplier.csv", col_types=cols()) 
warehouse <- readr::read_csv("data_upload/warehouse.csv", col_types=cols()) 
order <- readr::read_csv("data_upload/order.csv", col_types=cols())
sell <- readr::read_csv("data_upload/sell.csv", col_types=cols())
stock <- readr::read_csv("data_upload/stock.csv", col_types=cols())
promote <- readr::read_csv("data_upload/promote.csv", col_types=cols()) 
product <- readr::read_csv("data_upload/product.csv", col_types=cols()) 
voucher <- readr::read_csv("data_upload/voucher.csv", col_types=cols()) 
my_db <- RSQLite::dbConnect(RSQLite::SQLite(),"database/e_commerce.db")


# Customer
log_file <- file(filename, "a")
writeLines("\n CUSTOMER", log_file)
close(log_file)

# Make a function to check email
isValidEmail <- function(x) {
  grepl("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", as.character(x))
}
check_email <- function(table,col){
  invalid_emails <- !isValidEmail(table[[col]])
  log_file <- file(filename, "a")
  if (sum(invalid_emails) == 0) {
    writeLines("\t All emails are valid", log_file)
    close(log_file)
  } else {
    writeLines("\t There are invalid emails:", log_file)
    writeLines(as.character(customer$cust_email[invalid_emails]), log_file)
    close(log_file)
  }
}

checkcol("customer")
duprec(customer,"customer")
check_pk(customer,"cust_id")
check_date(customer,"cust_reg_date")
check_email(customer, "cust_email")
check_date(customer,"cust_birth_date")

## Referral
check_ref <- function(table) {
  log_file <- file(filename, "a")
  merged_data <- merge(table, table[, c("cust_id", "cust_reg_date")], by.x = "cust_referral", by.y = "cust_id", all.x = TRUE, suffixes = c("", ".y"))
  merged_data$cust_referral[merged_data$cust_reg_date < merged_data$cust_reg_date.y] <- "0"
  merged_data <- merged_data[, c("cust_id", "cust_reg_date", "cust_last_name", "cust_first_name", "cust_email", "cust_password", "cust_phone", "cust_zipcode", "cust_street_address", "cust_city", "cust_county", "membership", "cust_birth_date", "cust_referral")]
  write.csv(merged_data, file = "data_upload/customer.csv", row.names = FALSE)
  message <- paste("\t The referrals are validated")
  writeLines(message, log_file)
  close(log_file)
}
check_ref(customer)

# Ad
log_file <- file(filename, "a")
writeLines("\n AD", log_file)
close(log_file)
checkcol("ad")
duprec(ad,"ad")
check_pk(ad,"ad_id")
check_date(ad,"start_date")
check_date(ad,"end_date")
check_num(ad,"impression")
check_num(ad,"click")
check_num(ad,"cost")
check_num(ad,"action")
check_num(ad,"revenue")

# Order
log_file <- file(filename, "a")
writeLines("\n ORDER", log_file)
close(log_file)

checkcol("order")
if (length(unique(paste(order$order_id, order$cust_id, order$product_id))) != nrow(order)) {
  message <- paste("\tPrimary key in", deparse(substitute(order)), "is not unique")
  log_file <- file(filename, "a")
  writeLines(message, log_file)
  close(log_file)
  stop("Stopping workflow execution.")
} else {
  log_file <- file(filename, "a")
  writeLines("\tSufficient primary key", log_file)
  close(log_file)
}
duprec(order,"order")
check_date(order,"order_date")
check_num(order,"quantity")
check_fk(order, "cust_id", customer)
check_fk(order, "product_id", product)
check_fk(order, "voucher_code", voucher)


# Product
log_file <- file(filename, "a")
writeLines("\n PRODUCT", log_file)
close(log_file)
duprec(product,"product")
checkcol("product")
check_pk(product,"product_id")
check_num(product,"selling_price")
check_num(product,"cost_price")
check_fk(product, "w_id", warehouse)

# Promotion
log_file <- file(filename, "a")
writeLines("\n PRODUCT", log_file)
close(log_file)
duprec(promotion,"promotion")
checkcol("promotion")
check_pk(promotion,"promotion_id")

# Stock
log_file <- file(filename, "a")
writeLines("\n STOCK", log_file)
close(log_file)

checkcol("stock")
duprec(stock,"stock")
check_pk(stock, "sku")
check_fk(stock, "w_id", warehouse)
check_fk(stock, "product_id", product)

# voucher
log_file <- file(filename, "a")
writeLines("\n VOUCHER", log_file)
close(log_file)

checkcol("voucher")
duprec(voucher,"voucher")
check_pk(voucher, "voucher_code")


# Supplier
log_file <- file(filename, "a")
writeLines("\n SUPPLIER", log_file)
close(log_file)
duprec(supplier,"supplier")
checkcol("supplier")
check_pk(supplier,"s_id")

# Warehouse
log_file <- file(filename, "a")
writeLines("\n WAREHOUSE", log_file)
close(log_file)
duprec(warehouse,"warehouse")
checkcol("warehouse")
check_pk(warehouse,"w_id")

# Sell
log_file <- file(filename, "a")
writeLines("\n SELL", log_file)
close(log_file)
duprec(sell, "sell")
checkcol("sell")
check_fk(sell, "s_id", supplier)
check_fk(sell, "product_id", product)

# Promote
log_file <- file(filename, "a")
writeLines("\n PROMOTE", log_file)
close(log_file)
duprec(promote,"promote")
checkcol("promote")
check_fk(promote, "ad_id", ad)
check_fk(promote, "product_id", product)

dbDisconnect(my_db)
