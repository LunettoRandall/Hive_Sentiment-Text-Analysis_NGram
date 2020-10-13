#Connect to HIVE using BEELINE(CLI)

#Create database or use your existing database

#Create external table 'ratings' for storing tab-delimited records

CREATE EXTERNAL TABLE IF NOT EXISTS ratings 
(posted TIMESTAMP,cust_id INT, prod_id INT, rating TINYINT, message STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/user/rlunett/ratings';

select count(*) from ratings;

#Upload data into Hive table

LOAD DATA INPATH '/user/rlunett/dualcore/ratings_2013.txt' 
INTO TABLE ratings;
  
select count(*) from ratings;
  
#Create external table 'products' for storing tab-delimited records

CREATE EXTERNAL TABLE products 
(prod_id INT, brand STRING, name STRING, price INT, cost INT, shipping_wt INT)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/user/rlunett/products';

#Find the product that customers like most and consider products with few ratings that may be misleading. 
#Get HIGHEST average using DESC among all those with at least 50 ratings.

SELECT prod_id, FORMAT_NUMBER(avg_rating, 2) AS avg_rating 
FROM (SELECT prod_id, AVG(rating) AS avg_rating, COUNT(*) AS num 
FROM ratings GROUP BY prod_id) rated 
WHERE num >= 50 
ORDER BY avg_rating DESC LIMIT 1;

#Get LOWEST average using DESC among all those with at least 50 ratings.

SELECT prod_id, FORMAT_NUMBER(avg_rating, 2) AS avg_rating
FROM (SELECT prod_id, AVG(rating) AS avg_rating, COUNT(*) AS num 
FROM ratings GROUP BY prod_id) rated 
WHERE num >= 50 
ORDER BY avg_rating ASC LIMIT 1;

#Normalize comments text, breakdown into individual words and use nGrams to find 5 most common two-word combinations.

SELECT NGRAMS(SENTENCES(LOWER(message)), 2, 5) 
AS bigrams FROM ratings WHERE prod_id = 1274673;

#Results from above too common, use trigrams to find three-word combinations.

SELECT EXPLODE(NGRAMS(SENTENCES(LOWER(message)), 3, 5)) 
AS trigrams FROM ratings WHERE prod_id = 1274673;

#Results from above reveal trigram "ten times more". Let's double click into those.

SELECT message FROM ratings 
WHERE prod_id = 1274673 AND message 
LIKE '%ten times more%' LIMIT 3;

#Customer complaints have been identified regarding pricing on product_id 1274673. Find all comments related to this.

SELECT distinct(message) FROM ratings 
WHERE prod_id = 1274673 AND message LIKE '%red%';

#Identify the product which has pricing issues.

SELECT * FROM products WHERE prod_id = 1274673;

SELECT * FROM products WHERE name LIKE '%16 GB USB Flash Drive%' AND brand='"Orion"';

#Results from above confirm pricing error.
#Double click into the word 'red' to dig deeper.

#Test 1-gram in context_ngrams

SELECT context_ngrams(sentences(LOWER(message)), 
array(null, null), 10) AS onegram FROM ratings;

#Add EXPLODE() function to beautify the result.

SELECT EXPLODE(context_ngrams(sentences(LOWER(message)), 
array(null, null), 10)) AS onegram FROM ratings;

#Test 2-gram in context_ngrams

SELECT EXPLODE(context_ngrams(sentences(LOWER(message)), 
array(null, null), 10)) AS bigram FROM ratings;

#Test 4-gram in context_ngrams that starts “red one”.
SELECT EXPLODE(context_ngrams(sentences(lower(message)), 
array("red", "one", null, null), 4, 10)) AS snippet FROM ratings;
