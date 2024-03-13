library(readr)
library(RSQLite)
library(dplyr)

my_db <- RSQLite::dbConnect(RSQLite::SQLite(),"database/e-commerce.db")

# Check new data 

customer_db <- dbGetQuery(my_db, "SELECT * FROM customer")
customer_push_data <- readr::read_csv("data_upload/customer.csv", col_types=cols()) 
customer_db$cust_reg_date <- as.Date(customer_db$cust_reg_date, origin = "1970-01-01")
customer_db$cust_birth_date <- as.Date(customer_db$cust_birth_date, origin = "1970-01-01")
new_customer_records <- anti_join(customer_push_data, customer_db)
write.csv(new_customer_records, file = "new_record/new_customer_records.csv", row.names = FALSE)

ad_db <- dbGetQuery(my_db, "SELECT * FROM ad")
ad_push_data <- readr::read_csv("data_upload/ad.csv", col_types=cols()) 
new_ad_records <- anti_join(ad_push_data, ad_db)
write.csv(new_ad_records, file = "new_record/new_ad_records.csv", row.names = FALSE)

order_db <- dbGetQuery(my_db, "SELECT * FROM order")
order_push_data <- readr::read_csv("data_upload/order.csv", col_types=cols()) 
new_order_records <- anti_join(order_push_data, order_db)
write.csv(new_order_records, file = "new_record/new_order_records.csv", row.names = FALSE)

product_db <- dbGetQuery(my_db, "SELECT * FROM product")
product_push_data <- readr::read_csv("data_upload/product.csv", col_types=cols()) 
new_product_records <- anti_join(product_push_data, product_db)
write.csv(new_product_records, file = "new_record/new_product_records.csv", row.names = FALSE)

promote_db <- dbGetQuery(my_db, "SELECT * FROM promote")
promote_push_data <- readr::read_csv("data_upload/promote.csv", col_types=cols()) 
new_promote_records <- anti_join(promote_push_data, promote_db)
write.csv(new_promote_records, file = "new_record/new_promote_records.csv", row.names = FALSE)

promotion_db <- dbGetQuery(my_db, "SELECT * FROM promotion")
promotion_push_data <- readr::read_csv("data_upload/promotion.csv", col_types=cols()) 
new_promotion_records <- anti_join(promotion_push_data, promotion_db)
write.csv(new_promotion_records, file = "new_record/new_promotion_records.csv", row.names = FALSE)

sell_db <- dbGetQuery(my_db, "SELECT * FROM sell")
sell_push_data <- readr::read_csv("data_upload/sell.csv", col_types=cols()) 
new_sell_records <- anti_join(sell_push_data, sell_db)
write.csv(new_sell_records, file = "new_record/new_sell_records.csv", row.names = FALSE)

stock_db <- dbGetQuery(my_db, "SELECT * FROM stock")
stock_push_data <- readr::read_csv("data_upload/stock.csv", col_types=cols()) 
new_stock_records <- anti_join(stock_push_data, stock_db)
write.csv(new_stock_records, file = "new_record/new_stock_records.csv", row.names = FALSE)

supplier_db <- dbGetQuery(my_db, "SELECT * FROM supplier")
supplier_push_data <- readr::read_csv("data_upload/supplier.csv", col_types=cols()) 
new_supplier_records <- anti_join(supplier_push_data, supplier_db)
write.csv(new_supplier_records, file = "new_record/new_supplier_records.csv", row.names = FALSE)

warehouse_db <- dbGetQuery(my_db, "SELECT * FROM warehouse")
warehouse_push_data <- readr::read_csv("data_upload/warehouse.csv", col_types=cols()) 
new_warehouse_records <- anti_join(warehouse_push_data, warehouse_db)
write.csv(new_warehouse_records, file = "new_record/new_warehouse_records.csv", row.names = FALSE)
