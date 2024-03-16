library(ggplot2)
library(RSQLite)
library(dplyr)

my_db <- RSQLite::dbConnect(RSQLite::SQLite(),"database/e_commerce.db")

customer_db <- dbGetQuery(my_db, "SELECT * FROM customer")
order_db <- dbGetQuery(my_db, "SELECT * FROM 'order'")

merged_data <- merge (customer_db, order_db, by = 'cust_id')

distribution_customer <- ggplot(customer_db, aes(x=cust_county, fill = cust_county)) +
  geom_bar()

ggsave(path = "figure", filename = "distribution_customer.png", plot =distribution_customer)

count_data <- merged_data %>%
  group_by(cust_county, payment_method) %>%
  summarise(order_count = n(), .groups = "drop")

ordervscounty <- ggplot(data = count_data, aes(x = cust_county, y = order_count, fill = payment_method)) +
 geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Number of Orders per Payment Method for each Customer County",
       x = "Customer County",
       y = "Number of Orders",
       fill = "Payment Method")

ggsave(path = "figure", filename = "ordervscounty.png", plot =ordervscounty)
