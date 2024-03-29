library(readr)
library(RSQLite)
library(dplyr)

my_db <- RSQLite::dbConnect(RSQLite::SQLite(),"database/e_commerce.db")

# Check new data 

customer_db <- dbGetQuery(my_db, "SELECT * FROM customer")
customer_push_data <- readr::read_csv("data_upload/customer.csv", col_types=cols()) 
new_customer_records <- anti_join(customer_push_data, customer_db, by = "cust_id")
write.csv(new_customer_records, file = "new_record/customer.csv", row.names = FALSE)

ad_db <- dbGetQuery(my_db, "SELECT * FROM ad")
ad_push_data <- readr::read_csv("data_upload/ad.csv", col_types=cols()) 
new_ad_records <- anti_join(ad_push_data, ad_db, by = "ad_id")
write.csv(new_ad_records, file = "new_record/ad.csv", row.names = FALSE)

order_db <- dbGetQuery(my_db, "SELECT * FROM 'order'")
order_push_data <- readr::read_csv("data_upload/order.csv", col_types=cols()) 
new_order_records <- anti_join(order_push_data, order_db, by = "order_id")
write.csv(new_order_records, file = "new_record/order.csv", row.names = FALSE)

product_db <- dbGetQuery(my_db, "SELECT * FROM product")
product_push_data <- readr::read_csv("data_upload/product.csv", col_types=cols()) 
new_product_records <- anti_join(product_push_data, product_db, by = "product_id")
write.csv(new_product_records, file = "new_record/product.csv", row.names = FALSE)

promote_db <- dbGetQuery(my_db, "SELECT * FROM promote")
promote_push_data <- readr::read_csv("data_upload/promote.csv", col_types=cols()) 
new_promote_records <- anti_join(promote_push_data, promote_db, by = "ad_id")
write.csv(new_promote_records, file = "new_record/promote.csv", row.names = FALSE)

promotion_db <- dbGetQuery(my_db, "SELECT * FROM promotion")
promotion_push_data <- readr::read_csv("data_upload/promotion.csv", col_types=cols()) 
new_promotion_records <- anti_join(promotion_push_data, promotion_db, by = "promotion_id")
write.csv(new_promotion_records, file = "new_record/promotion.csv", row.names = FALSE)

sell_db <- dbGetQuery(my_db, "SELECT * FROM sell")
sell_push_data <- readr::read_csv("data_upload/sell.csv", col_types=cols()) 
new_sell_records <- anti_join(sell_push_data, sell_db, by = "product_id")
write.csv(new_sell_records, file = "new_record/sell.csv", row.names = FALSE)

stock_db <- dbGetQuery(my_db, "SELECT * FROM stock")
stock_push_data <- readr::read_csv("data_upload/stock.csv", col_types=cols()) 
new_stock_records <- anti_join(stock_push_data, stock_db, by = "sku")
write.csv(new_stock_records, file = "new_record/stock.csv", row.names = FALSE)

voucher_db <- dbGetQuery(my_db, "SELECT * FROM voucher")
voucher_push_data <- readr::read_csv("data_upload/voucher.csv", col_types=cols()) 
new_voucher_records <- anti_join(voucher_push_data, voucher_db, by = "voucher_code")
write.csv(new_voucher_records, file = "new_record/voucher.csv", row.names = FALSE)

supplier_db <- dbGetQuery(my_db, "SELECT * FROM supplier")
supplier_push_data <- readr::read_csv("data_upload/supplier.csv", col_types=cols()) 
new_supplier_records <- anti_join(supplier_push_data, supplier_db, by = "s_id")
write.csv(new_supplier_records, file = "new_record/supplier.csv", row.names = FALSE)

warehouse_db <- dbGetQuery(my_db, "SELECT * FROM warehouse")
warehouse_push_data <- readr::read_csv("data_upload/warehouse.csv", col_types=cols()) 
new_warehouse_records <- anti_join(warehouse_push_data, warehouse_db, by = "w_id")
write.csv(new_warehouse_records, file = "new_record/warehouse.csv", row.names = FALSE)
