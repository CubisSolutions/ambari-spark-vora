USE hivedb;
CREATE USER 'hive'@'localhost' IDENTIFIED BY 'Hive_password1';
GRANT ALL PRIVILEGES ON *.* TO 'hive'@'localhost';
CREATE USER 'hive'@'%' IDENTIFIED BY 'Hive_password1';
GRANT ALL PRIVILEGES ON *.* TO 'hive'@'%';
FLUSH PRIVILEGES;
