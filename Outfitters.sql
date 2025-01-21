/*Data cleaning*/

ALTER TABLE retail 
RENAME COLUMN `ï»¿Model no` TO `Model no`;

ALTER TABLE retail 
DROP COLUMN `Qty Received`;

ALTER TABLE retail
RENAME COLUMN `Order Status` to `Item name`;

ALTER TABLE retail 
RENAME COLUMN `Unit Cost` to `Quantity Received`;

ALTER TABLE retail 
RENAME COLUMN `Extended Cost` to `Unit Cost`;

ALTER TABLE retail 
RENAME COLUMN `Retail Price` to `Extended Cost`;

ALTER TABLE retail
RENAME COLUMN `Extended Price` to `Retail Price`;

ALTER TABLE retail 
RENAME COLUMN `Gross Margin` to `Extended retail`;

ALTER TABLE retail 
ADD `Size` VARCHAR(255);

UPDATE retail
SET Size = CASE
	WHEN RIGHT(`Model no`, 2) = '01' THEN 'XS'
    WHEN RIGHT(`Model no`, 2) = '02' THEN 'SM'
    WHEN RIGHT(`Model no`, 2) = '03' THEN 'MED'
    WHEN RIGHT(`Model no`, 2) = '04' THEN 'LG'
    WHEN RIGHT(`Model no`, 2) = '05' THEN 'XL'
    WHEN RIGHT(`Model no`, 2) = '06' THEN 'XXL'
    WHEN RIGHT(`Model no`, 2) = '07' THEN '3XL'
    ELSE 'Unknown'
END;

ALTER TABLE sales
ADD `Size` VARCHAR(255);

UPDATE sales
SET Size = CASE
	WHEN RIGHT(`Model no`, 2) = '01' THEN 'XS'
    WHEN RIGHT(`Model no`, 2) = '02' THEN 'SM'
    WHEN RIGHT(`Model no`, 2) = '03' THEN 'MED'
    WHEN RIGHT(`Model no`, 2) = '04' THEN 'LG'
    WHEN RIGHT(`Model no`, 2) = '05' THEN 'XL'
    WHEN RIGHT(`Model no`, 2) = '06' THEN 'XXL'
    WHEN RIGHT(`Model no`, 2) = '07' THEN '3XL'
    ELSE 'Unknown'
END;

ALTER TABLE retail
ADD COLUMN `Product No` VARCHAR(255);

ALTER TABLE sales
ADD COLUMN `Product No` VARCHAR(255);

ALTER TABLE sales
ADD COLUMN `Product color` VARCHAR(255);

UPDATE retail
SET `Product No` = LEFT(`Model no`, LENGTH(`Model no`) - 2);

UPDATE sales
SET `Product No` = LEFT(`Model no`, LENGTH(`Model no`) - 2);

UPDATE sales
SET `Product color` = SUBSTRING_INDEX(SUBSTRING_INDEX(`Item Name`, ' ', -2), ' ', 1);

UPDATE sales 
SET `Product color` = 'WHITE'
WHERE `Product no` = '41135';

UPDATE sales SET `Product color` = 'RD' WHERE `Product no` LIKE '756260%';
UPDATE sales SET `Product color` = 'BLK' WHERE `Product no` LIKE '756132%';
UPDATE sales SET `Product color` = 'BLK' WHERE `Product no` LIKE '7560%';
UPDATE sales SET `Product color` = 'WHT' WHERE `Product no` LIKE '7559%';
UPDATE sales SET `Product color` = 'RD' WHERE `Product no` LIKE '7558%';
UPDATE sales SET `Product color` = 'CHAR GRY' WHERE `Product no` LIKE '7557%';
UPDATE sales SET `Product color` = 'BLK' WHERE `Product no` LIKE '7556%';
UPDATE sales SET `Product color` = 'RED' WHERE `Product no` LIKE '48260%';
UPDATE  sales SET `Product color`= 'HTHR GRY' WHERE `Product no` LIKE '104632%';
UPDATE  sales SET `Product color`= 'SILV GRY' WHERE `Product no` LIKE '12532%';

UPDATE  sales SET `Product color`= 'SILV GRY' WHERE `Item name` LIKE '%SILV GRY%';
UPDATE  sales SET `Product color`= 'ASH GRY' WHERE `Item name` LIKE '%ASH GRY%';
UPDATE  sales SET `Product color`= 'CHAR GRY' WHERE `Item name` LIKE '%CHAR GRY%';
UPDATE  sales SET `Product color`= 'HTHR BLK' WHERE `Item name` LIKE '%HTHR BLK%';

UPDATE sales
SET `Product color` = 'Unknown' 
WHERE  `Product color` IN ('HOOD', 'HOODED');


ALTER TABLE sales
RENAME COLUMN `ï»¿Model no` TO `Model no`;

/* EXPLORATORY DATA ANALYSIS*/

select DISTINCT(`Product no`), `Item Name`,`Retail Price`FROM retail;

SELECT * FROM sales 
WHERE `Product color` LIKE '%BLK%';

# Count the number of models
SELECT COUNT(DISTINCT `Model no`) AS `Total qty of products in Inventory` FROM retail;

# Count the no of products in total
SELECT COUNT(DISTINCT `Product no`) AS `Total Products purchased` FROM retail;

SELECT DISTINCT `Product no` AS `Total Products in Inventory` FROM sales;
  
## Sales Analysis

# Dispaly the quantity of items purchased per model
SELECT `Model no`, `Display Name`, SUM(`Quantity Received`) AS `Quantity purchased`
FROM retail
GROUP BY `Model no`, `Display Name`
ORDER BY `Quantity purchased` DESC;

# Diplay the models where quantity purchased is greater than 100 units
SELECT `Product no`,SUM(`Quantity Received`) AS `Quantity purchased`
FROM retail 
GROUP BY `Product no`
HAVING SUM(`Quantity Received`) > 100
ORDER BY `Quantity purchased` DESC LIMIT 10;

# Display the least purchased products
SELECT `Product no`,SUM(`Quantity Received`) AS `Quantity purchased`
FROM retail 
GROUP BY `Product no`
ORDER BY `Quantity purchased` ASC LIMIT 5;

# Display the amount purchased by size and rank based on the quantity purchased
SELECT 
Size, 
SUM(`Quantity Received`) AS `Total Quantity Purchased`
FROM retail
GROUP BY Size;

# Display and compare the quantity sold vs the quantity purchased from the retailer
SELECT 
`Product no`, 
SUM(`Quantity Received`) AS `Total Quantity`,
ROUND(SUM(`Extended Retail`),2) AS `Total Retail Value`
FROM retail
GROUP BY `Product no`
ORDER BY `Total Retail Value` DESC;

## Display the products and thier size that were sold but not purchased from the retailer 
WITH IdentifyProductsnotPurchased AS(
	SELECT DISTINCT(retail.`Model no`) AS `Products purchased`, 
	sales.`Model no` AS `Products Sold`, 
	sales.size
	FROM retail RIGHT JOIN sales 
		ON retail.`Model no` = sales.`Model no`)
SELECT * FROM IdentifyProductsnotPurchased
WHERE `Products purchased` is NULL;

SELECT 
DISTINCT(retail.`Product no`) AS `Products purchased`, 
sales.`Product no` AS `Products Sold`
	FROM retail RIGHT JOIN sales 
		ON retail.`Product no`= sales.`Product no`;
        
	
## Product analysis
#Display the top 5 products by size sold In-store
WITH Top5ProductsbySize AS(
SELECT `Product no`, Size,
 `Total Revenue`,
 RANK() OVER(PARTITION BY Size ORDER BY `Total Revenue` DESC) AS `Rank`
 FROM sales
 WHERE `Sale Mode` = "In-store")
 SELECT * 
 FROM Top5ProductsbySize
 WHERE `Rank` <= 5;

#Display the top 5 products by size sold Online
WITH Top5ProductsbySize AS(
SELECT `Product no`, Size,
 `Total Revenue`,
 RANK() OVER(PARTITION BY Size ORDER BY `Total Revenue` DESC) AS `Rank`
 FROM sales
 WHERE `Sale Mode` = "Online")
 SELECT * 
 FROM Top5ProductsbySize
 WHERE `Rank` <= 5;

#Cost Vs Retail price analysis - display the markup % for every product
SELECT 
`Product No`, 
`Unit Cost`, 
`Retail Price`,
ROUND((`Retail Price` - `Unit Cost`) / `Unit Cost` * 100, 2) AS `Markup %`
FROM retail
ORDER BY `Markup %` DESC;

#Display and compare the quantity sold vs the quantity purchased from the retailer
SELECT retail.`Product No`, 
retail.`Quantity Received`, 
sales.`Qty Sold` AS `Quantity Sold`, 
( sales.`Qty Sold` / retail.`Quantity Received`) AS `Sales to retail ratio`
FROM retail JOIN  sales ON retail.`Product No` = sales.`Product No`
ORDER BY `Sales to retail ratio` DESC;

#Display the products with the highest Gross Profit % 
SELECT 
    `Product No`,
    ROUND(SUM(`Extended Cost`), 2) AS `Total Extended Cost`,
    ROUND(SUM(`Extended Retail`), 2) AS `Total Extended Retail`,
    ROUND(
        (SUM(`Extended Retail`) - SUM(`Extended Cost`)) / SUM(`Extended Retail`) * 100, 
        2
    ) AS `Gross Margin %`
FROM retail
GROUP BY `Product No`
ORDER BY `Gross Margin %` DESC LIMIT 10;

#Display the products with the lowest Gross Profit % 
SELECT 
    `Product No`,
    ROUND(SUM(`Extended Cost`), 2) AS `Total Extended Cost`,
    ROUND(SUM(`Extended Retail`), 2) AS `Total Extended Retail`,
    ROUND(
        (SUM(`Extended Retail`) - SUM(`Extended Cost`)) / SUM(`Extended Retail`) * 100, 
        2
    ) AS `Gross Margin %`
FROM retail
GROUP BY `Product No`
ORDER BY `Gross Margin %` ASC LIMIT 5;
 
 

