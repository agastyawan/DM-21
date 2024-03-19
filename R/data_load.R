library(readr)
library(RSQLite)
library(dplyr)

customer_data <- readr::read_csv("new_record/customer.csv", col_types=cols(
  cust_reg_date = col_character(),
  cust_birth_date = col_character()
)) 
ad_data <- readr::read_csv("new_record/ad.csv", col_types=cols(
  start_date = col_character(),
  end_date = col_character()
)) 
warehouse_data <- readr::read_csv("new_record/warehouse.csv", col_types=cols())
promotion_data <- readr::read_csv("new_record/promotion.csv", col_types=cols())
product_data <- readr::read_csv("new_record/product.csv", col_types=cols()) 
order_data <- readr::read_csv("new_record/order.csv", col_types=cols(
  order_date = col_character()
))
sell_data <- readr::read_csv("new_record/sell.csv", col_types=cols())
supplier_data <- readr::read_csv("new_record/supplier.csv", col_types=cols()) 
promote_data <- readr::read_csv("new_record/promote.csv", col_types=cols()) 
voucher_data <- readr::read_csv("new_record/voucher.csv", col_types=cols()) 
stock_data <- readr::read_csv("new_record/stock.csv", col_types=cols())

my_connection <- RSQLite::dbConnect(RSQLite::SQLite(),"database/e_commerce.db")

RSQLite::dbWriteTable(my_connection,"customer",customer_data, append = TRUE, row.names = FALSE)
RSQLite::dbWriteTable(my_connection,"ad",ad_data, append = TRUE, row.names = FALSE)
RSQLite::dbWriteTable(my_connection,"warehouse",warehouse_data, append = TRUE, row.names = FALSE)
RSQLite::dbWriteTable(my_connection, "promotion", promotion_data, append = TRUE, row.names = FALSE)
RSQLite::dbWriteTable(my_connection, "product", product_data, append = TRUE, row.names = FALSE)
RSQLite::dbWriteTable(my_connection, "order", order_data, append = TRUE, row.names = FALSE)
RSQLite::dbWriteTable(my_connection, "sell", sell_data, append = TRUE, row.names = FALSE)
RSQLite::dbWriteTable(my_connection, "supplier", supplier_data, append = TRUE, row.names = FALSE)
RSQLite::dbWriteTable(my_connection, "promote", promote_data, append = TRUE, row.names = FALSE)
RSQLite::dbWriteTable(my_connection, "stock", stock_data, append = TRUE, row.names = FALSE)
RSQLite::dbWriteTable(my_connection, "voucher", voucher_data, append = TRUE, row.names = FALSE)
