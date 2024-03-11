library(readr)
library(RSQLite)

customer_data <- readr::read_csv("data_upload/customer.csv")
my_connection <-RSQLite::dbConnect(RSQLite(),"database/e-commerce.db")
RSQLite::dbWriteTable(my_connection,"customers"), customer_data)
