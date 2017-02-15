USE ambaridb;
CREATE USER 'ambari'@'localhost' IDENTIFIED BY 'Ambari_password1';
GRANT ALL PRIVILEGES ON *.* TO 'ambari'@'localhost';
CREATE USER 'ambari'@'%' IDENTIFIED BY 'Ambari_password1';
GRANT ALL PRIVILEGES ON *.* TO 'ambari'@'%';
FLUSH PRIVILEGES;
