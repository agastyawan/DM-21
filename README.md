# Group21

## Introduction
Muse is a digital marketplace for musical instruments, appliances as well as production products. With the advancements in e-commerce and the overall digital retail environments, Muse’s purpose is to provide products for audiophiles, music producers and musicians. Unlike other local market leaders, Muse aims to only target the UK specifically, allowing a greater focus on customer satisfaction. Before moving on to the details of the report, it is essential to establish that we’ve made Muse to be a small but agile company, and have tried to create a dynamic and responsive model which can be used to sell products like guitars and bases, drums, keys, microphones, DJ equipment, cables, connectors, lighting and stage accessories, headphones, etc. We have also assumed that the company sells products as small as a guitar capo worth 5 pounds to full-size pianos worth 40,000 pounds, and the E-R diagram has been given thought and designed accordingly.

## ER diagram
The initial part of our database design was the Entity-Relationship diagram.While keeping practicality in focus, we created a structure which covers every aspect of a functional e-commerce database.

For the ER diagram, we focused mainly on three types of relationships between entities. One to One. One to Many and Many to Many. An example of a One-to-One relationship could be between the entities Advertisement and Voucher (as shown in the ER diagram). For every one Advertisement, one voucher would be passed out. Another important aspect about the Entity is the primary key, i.e the unique identifier of any entity. The customer_id is the primary key for the customer entity which would give a unique identity to every customer allowing for them to be identified with ease when need be.

For a One-to-Many relationship, we could use an example of the entities, Product and Warehouse. There is only one Warehouse where all the product inventory is located. Finally, to give an example of a Many to Many Relationships, the relationship between the entities, Product and Supplier could be described. Multiple Products could be supplied from Multiple Suppliers.

Furthermore another concept that has been applied in the diagram, specifically towards the customer entity is the Self Referencing process. The process in particular is “give referral” process. This process itself happens between customers, customers who buy a product from Muse have the potential to refer the platform to another, could be a friend, family member, band mate etc. This would lead to that customer converting the referred

![ER Diagram](https://github.com/agastyawan/DM-21/blob/main/figure/ER-Final.png?raw=true)

