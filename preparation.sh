#Connect to your Oracle Cloud Big Data Compute Edition
  ssh [username]@[ip-address]

#Download data set 'ratings_2012'
  wget https://s3.amazonaws.com/hipicdatasets/ratings_2012.txt

#Download data set 'ratings_2013'
  wget https://s3.amazonaws.com/hipicdatasets/ratings_2013.txt

#Download data set 'products'
  wget https://s3.amazonaws.com/hipicdatasets/products.tsv

#Create directory folder in HDFS for upload data files into
  hdfs dfs -mkdir ratings
  hdfs dfs -put ratings_2012.txt /user/rlunett/ratings/
  
  hdfs dfs -mkdir dualcore
  hdfs dfs -put ratings_2013.txt dualcore
  
  hdfs dfs -mkdir products
  hdfs dfs -put products.tsv /user/rlunett/products/

  hdfs dfs -ls -h products dualcore ratings

#Grant privledges/permissions to write/rewrite in BEELINE (Hive CLI)
  hdfs dfs -chmod -R o+w .
  
