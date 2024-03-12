library(readr)
library(RSQLite)
library(dplyr)

customer_data <- readr::read_csv("data_upload/customer.csv", col_types=cols()) 
ad_data <- readr::read_csv("data_upload/ad.csv", col_types=cols()) 
#warehouse_data <- readr::read_csv("data_upload/warehouse.csv", col_types=cols())
#promotion_data <- readr::read_csv("data_upload/promotion.csv", col_types=cols())
product_data <- readr::read_csv("data_upload/product.csv", col_types=cols()) 
order_data <- readr::read_csv("data_upload/order.csv")
sell_data <- readr::read_csv("data_upload/sell.csv")
supplier_data <- readr::read_csv("data_upload/supplier.csv", col_types=cols())
#promote_data <- readr::read_csv("data_upload/promote.csv", col_types=cols()) 
stock_data <- readr::read_csv("data_upload/stock.csv")

customer_data <- customer_data[-c(1)]
ad_data <- ad_data[-c(1)]
product_data <- product_data[-c(1)]
supplier_data <- supplier_data[-c(1)]



my_connection <- RSQLite::dbConnect(RSQLite::SQLite(),"e-commerce.db")

RSQLite::dbWriteTable(my_connection,"customer",customer_data, append = TRUE, row.names = FALSE)
RSQLite::dbWriteTable(my_connection,"ad",ad_data, append = TRUE, row.names = FALSE)
#RSQLite::dbWriteTable(my_connection,"warehouse",warehouse_data, append = TRUE, row.names = FALSE)
#RSQLite::dbWriteTable(my_connection, "promotion", promotion_data, append = TRUE, row.names = FALSE)
RSQLite::dbWriteTable(my_connection, "product", product_data, append = TRUE, row.names = FALSE)
RSQLite::dbWriteTable(my_connection, "order", order_data, append = TRUE, row.names = FALSE)
RSQLite::dbWriteTable(my_connection, "sell", sell_data, append = TRUE, row.names = FALSE)
RSQLite::dbWriteTable(my_connection, "supplier", supplier_data, append = TRUE, row.names = FALSE)
#RSQLite::dbWriteTable(my_connection, "promote", promote_data, append = TRUE, row.names = FALSE)
RSQLite::dbWriteTable(my_connection, "stock", stock_data, append = TRUE, row.names = FALSE)
