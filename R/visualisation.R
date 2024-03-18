library(ggplot2)
library(RSQLite)
library(dplyr)
library('lubridate')

my_db <- RSQLite::dbConnect(RSQLite::SQLite(),"database/e_commerce.db")



# Read tables from the db files  
data_customers <- dbGetQuery(my_db, "SELECT * FROM customer")
data_orders <- dbGetQuery(my_db, "SELECT * FROM 'order'")
data_product <- dbGetQuery(my_db, "SELECT * FROM product")
data_promotion <- dbGetQuery(my_db, "SELECT * FROM promotion")

#Graph 1
# Merge the tables based on a common attribute (e.g., customer_id)
merged_data <- merge(data_customers, data_orders, by = "cust_id")

# Count the number of orders made via each payment method for each customer county
count_data <- merged_data %>%
  group_by(cust_county) %>%
  summarise(order_count = n(), .groups = "drop")

p1 <- ggplot(data = count_data, aes(x = reorder(cust_county, -order_count), y = order_count, fill = cust_county)) +
 geom_bar(stat = "identity", position = "dodge") +
 scale_fill_brewer(palette = "Set1") +  
 labs(title = "Number of Orders for each Customer County",
       x = "Customer County",
       y = "Number of Orders") +
 theme_minimal() +
 theme(axis.text.x = element_text(angle = 45, hjust = 1),
       legend.position = "none") 

ggsave(path = "figure", filename = "orderwithincounty.png", plot =p1)

#Graph 2
# Merge the promotion data with the sales data
merged_data_sales <- merge(data_product, data_orders, by = "product_id")

# Now, calculate the sales by subtracting the promotion rate from sales_data
merged_data_sales$sales_data <- merged_data_sales$quantity *merged_data_sales$selling_price

# Merge the promotion data with the sales data
merged_data_sales_p <- merge(data_promotion, merged_data_sales, by = "promotion_id")

# Now, calculate the sales by subtracting the promotion rate from sales_data
merged_data_sales_p$sales <- merged_data_sales_p$sales_data - (merged_data_sales_p$selling_price * merged_data_sales_p$promotion_rate)

sales_by_category <- merged_data_sales_p %>%
  group_by(category_name) %>%
  summarise(total_sales = sum(sales), .groups = "drop")

# Create a ggplot
p2 <- ggplot(data = sales_by_category, aes(x = reorder(category_name, -total_sales), y = total_sales, fill = total_sales)) +
  geom_bar(stat = "identity") +
  scale_fill_gradient(low = "skyblue", high = "steelblue") +  
  geom_text(aes(label = format(round(total_sales, 2), big.mark = ",")), angle = 90, size = 3) +  
  scale_y_continuous(limits = c(0, max(sales_by_category$total_sales) * 1.2)) +  
  labs(title = "Total Sales per Category",
       x = "Category Name (Ordered by Sales)",
       y = "Total Sales",
       fill = "Total Sales") +
  #coord_flip() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        plot.margin = margin(10, 10, 40, 10))  # Adjust plot margins to create more space for labels

ggsave(path = "figure", filename = "sales_by_category.png", plot =p2)

# Graph 3
merge_cust_dsp <- merge(data_customers,merged_data_sales_p, by = "cust_id")

# Group by 'area' and calculate the total sales
sales_by_area <- merge_cust_dsp %>%
  group_by(cust_county) %>%
  summarise(total_sales = sum(sales), .groups = "drop")

# Create a ggplot
p3 <- ggplot(data = sales_by_area, aes(x = reorder(cust_county, -total_sales), y = total_sales, fill = total_sales)) +
  geom_bar(stat = "identity") +
  scale_fill_gradient(low = "skyblue", high = "steelblue") +
  geom_text(aes(label = format(round(total_sales), big.mark = ",")), vjust = -0.3, size = 3.25) +
  scale_y_continuous() +  # Add this line to adjust y-axis labels
  labs(title = "Total Sales per Area",
       x = "Area (Ordered by Sales)",
       y = "Total Sales",
       fill = "Total Sales") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
ggsave(path = "figure", filename = "sales_by_area.png", plot =p3)


