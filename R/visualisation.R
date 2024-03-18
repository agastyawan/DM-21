library(ggplot2)
library(RSQLite)
library(dplyr)
library(lubridate)

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


# Graph 4
# Extract the year from order_date
merge_cust_dsp$order_date <- lubridate::ymd(merge_cust_dsp$order_date)
merge_cust_dsp$year <- lubridate::year(merge_cust_dsp$order_date)

# Group by 'year' and calculate the total sales
sales_by_year <- merge_cust_dsp %>%
  group_by(year) %>%
  summarise(total_sales = sum(sales), .groups = "drop")

# Create a ggplot
p4 <- ggplot(data = sales_by_year, aes(x = factor(year, levels = sort(unique(year))), y = total_sales, fill = total_sales)) +
  geom_bar(stat = "identity") +
  scale_fill_gradient(low = "skyblue", high = "steelblue", labels = scales::comma) +
  geom_text(aes(label = format(round(total_sales, 2), big.mark = ",")), vjust = -0.3, size = 3.25) +
  scale_y_continuous(labels = scales::comma) +  # Add this line to adjust y-axis labels
  labs(title = "Total Sales per Year",
       x = "Year",
       y = "Total Sales",
       fill = "Total Sales") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

ggsave(path = "figure", filename = "sales_by_year.png", plot =p4)

# Graph 5
# Extract the quarter and year from order_date
merge_cust_dsp$quarter <- lubridate::quarter(merge_cust_dsp$order_date)
merge_cust_dsp$year <- lubridate::year(merge_cust_dsp$order_date)

# Group by 'year', 'quarter' and calculate the total sales
sales_by_quarter <- merge_cust_dsp %>%
  group_by(year, quarter) %>%
  summarise(total_sales = sum(sales), .groups = "drop")

# Create a new variable that combines the year and quarter
sales_by_quarter$year_quarter <- paste(sales_by_quarter$year, "Q", sales_by_quarter$quarter)

# Order the year_quarter variable in the order you want
sales_by_quarter$year_quarter <- factor(sales_by_quarter$year_quarter, levels = unique(sales_by_quarter$year_quarter))

# Create a ggplot
p5 <- ggplot(data = sales_by_quarter, aes(x = year_quarter, y = total_sales, fill = total_sales)) +
  geom_bar(stat = "identity") +
  scale_fill_gradient(low = "skyblue", high = "steelblue", labels = scales::comma) +
  geom_text(aes(label = scales::comma(round(total_sales, 2))), vjust = -0.3, size = 3.25) +
  scale_y_continuous(labels = scales::comma) +  # Add this line to adjust y-axis labels
  labs(title = "Total Sales per Quarter",
       x = "Year and Quarter",
       y = "Total Sales",
       fill = "Total Sales") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

ggsave(path = "figure", filename = "Sales per Quarter.png", plot =p5)

# Graph 6
merge_cust_dsp$month <- lubridate::month(merge_cust_dsp$order_date)

# Group by 'year' and 'month' and calculate the total sales
sales_by_month_year <- merge_cust_dsp %>%
  group_by(year, month) %>%
  summarise(total_sales = sum(sales), .groups = "drop")

# Create a ggplot
sales_by_month_year$month <- factor(month.abb[sales_by_month_year$month], levels = month.abb)

p6 <- ggplot(data = sales_by_month_year, aes(x = month, y = total_sales, fill = total_sales)) +
  geom_bar(stat = "identity") +
  #geom_smooth(method = "lm", se = FALSE, color = "red", linetype = "dashed") +
  scale_fill_gradient(low = "skyblue", high = "steelblue", labels = scales::comma) +
  geom_text(aes(label = format(round(total_sales), big.mark = ",")), vjust = -0.3, size = 3, angle = 90) +
  scale_y_continuous(labels = scales::comma) +  # Add this line to adjust y-axis labels
  labs(title = "Total Sales per Month per Year",
       x = "Month",
       y = "Total Sales",
       fill = "Total Sales") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  facet_grid(rows = vars(year)) 

ggsave(path = "figure", filename = "Sales per month.png", plot =p6)
