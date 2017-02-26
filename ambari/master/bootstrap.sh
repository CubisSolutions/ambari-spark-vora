#!/bin/bash
# Inform host about ip adress
echo "$(hostname -i)" > /hostdata/$(hostname -f)

# Disable Transparent Huge Pages. --priviledged
echo never | sudo tee /sys/kernel/mm/transparent_hugepage/enabled

# Check to initialize the mysql database for ambari setup
password="`grep 'temporary password' /var/log/mysqld.log | sed 's/.*localhost: //g'`"
message="`mysqladmin ping -u root -p$password 2>&1 >/dev/null | grep expired`"
if grep -qw 'expired' <<< "$message" ; then
  mysql -u root -p$password --execute="SET PASSWORD = PASSWORD('CubisRoot_1')" --connect-expired-password
  mysqladmin -u root -pCubisRoot_1 create ambaridb
  mysqladmin -u root -pCubisRoot_1 create hivedb
  mysql -u root -pCubisRoot_1 < /root/ambaridb.sql
  mysql -u root -pCubisRoot_1 < /root/hivedb.sql
  ambari-server setup -s --database=mysql \
                         --java-home=/usr/java/jdk1.8.0_112/ \
                         --databasehost=localhost \
                         --databaseport=3306 \
                         --databasename=ambaridb \
                         --databaseusername=ambari \
                         --databasepassword=Ambari_password1 
  mysql -u ambari -pAmbari_password1 ambaridb <  /var/lib/ambari-server/resources/Ambari-DDL-MySQL-CREATE.sql
fi

# service ssh start
ambari-server start

printf 'Waiting for ambari-master'
until $(curl --output /dev/null --silent --head --fail http://localhost:8080); do
  printf '.'
  sleep 5
done

curl -u admin:admin -H "X-Requested-By: ambari" -X PUT -d '{"Repositories" : { "base_url" : "http://repo.cubis/hdp/centos7/HDP-2.4.2.0/", "verify_base_url" : true } }' http://localhost:8080/api/v1/stacks/HDP/versions/2.4/operating_systems/redhat7/repositories/HDP-2.4
curl -u admin:admin -H "X-Requested-By: ambari" -X PUT -d '{"Repositories" : { "base_url" : "http://repo.cubis/hdp/centos7/HDP-UTILS-1.1.0.20/", "verify_base_url" : false } }' http://localhost:8080/api/v1/stacks/HDP/versions/2.4/operating_systems/redhat7/repositories/HDP-UTILS-1.1.0.20
curl -u admin:admin -H "X-Requested-By: ambari" -X POST -d @/root/cubis1node_blueprint.json http://localhost:8080/api/v1/blueprints/cubis1node_blueprint?validate_topology=false
curl -u admin:admin -H "X-Requested-By: ambari" -X POST -d @/root/1node_template.json http://localhost:8080/api/v1/clusters/Cubis

printf '\n\nWaiting for Cubis-cluster to be up'
while true ; do
  message="`curl -u admin:admin -i -s -H 'X-Requested-By: ambari' -X GET http://localhost:8080/api/v1/clusters/Cubis/requests/1 | grep progress_percent`"
  if grep -qw '100' <<< "$message" ; then
     break
  else
     printf '.'
     sleep 5  
  fi
done
printf '\nDone'

# variables defined in bash.bashrc not available on docker entrypoint startup

export JAVA_HOME=/usr/java/jdk1.8.0_112 
export HADOOP_CONF_DIR=/etc/hadoop/conf
export SPARK_HOME=/usr/hdp/2.4.2.0-258/spark
export SPARK_CONF_DIR=$SPARK_HOME/conf
export PATH=$PATH:$SPARK_HOME/bin 
export LD_LIBRARY_PATH=/usr/hdp/2.4.2.0-258/hadoop/lib/native 
 
# Prepare HDFS for zeppelin
su hdfs -c "hadoop fs -mkdir /user/root"
su hdfs -c "hadoop fs -chown root /user/root"
su hdfs -c "hadoop fs -mkdir /user/flume"
su hdfs -c "hadoop fs -chown flume /user/flume"

echo '1,2,Hello' > /root/test.csv
hadoop fs -put /root/test.csv

# Create vora manager user and password file
cd /var/lib/ambari-server/resources/stacks/HDP/2.4/services
./genpasswd.sh --vora-username=voraadmin --vora-password=voraadmin --vora-password-file-path=/etc/vora/datatools/
chown vora /etc/vora/datatools/htpasswd
cp /etc/vora/datatools/htpasswd /etc/vora/manager/
chown vora /etc/vora/manager/htpasswd

curl -uadmin:admin -H 'X-Requested-By: ambari' -X POST -d '{ "RequestInfo": {"command":"RESTART", "context":"Restart Vora Master"}, "Requests/resource_filters":[ {"service_name": "HANA_VORA_MANAGER", "component_name": "HANA_VORA_MANAGER_MASTER", "hosts": "ambarim.cubis"} ] }' http://localhost:8080/api/v1/clusters/Cubis/requests

curl -uadmin:admin -H 'X-Requested-By: ambari' -X POST -d '{ "RequestInfo": {"command":"RESTART", "context":"Restart Vora Master"}, "Requests/resource_filters":[ {"service_name": "HANA_VORA_MANAGER", "component_name": "HANA_VORA_MANAGER_WORKER", "hosts": "ambarim.cubis, ambaris.cubis"} ] }' http://localhost:8080/api/v1/clusters/Cubis/requests

# Setup zeppeling to run VORA 1.3
export ZEPPELIN_HOME=/root/zeppelin-0.6.2-bin-all
cp /var/lib/ambari-agent/cache/stacks/HDP/2.4/services/vora-manager/package/lib/vora-spark/zeppelin/zeppelin-*.jar $ZEPPELIN_HOME/interpreter/spark/
jar xf $ZEPPELIN_HOME/interpreter/spark/zeppelin-1*.jar interpreter-setting.json
jar uf $ZEPPELIN_HOME/interpreter/spark/zeppelin-spark_*.jar interpreter-setting.json

rm interpreter-setting.json
cp $ZEPPELIN_HOME/conf/zeppelin-env.sh.template $ZEPPELIN_HOME/conf/zeppelin-env.sh
chmod 755 $ZEPPELIN_HOME/conf/zeppelin-env.sh
echo "export MASTER=yarn-client" >> $ZEPPELIN_HOME/conf/zeppelin-env.sh
echo "export HADOOP_CONF_DIR=/etc/hadoop/conf" >> $ZEPPELIN_HOME/conf/zeppelin-env.sh
cp $ZEPPELIN_HOME/conf/zeppelin-site.xml.template $ZEPPELIN_HOME/conf/zeppelin-site.xml
chmod 755 $ZEPPELIN_HOME/conf/zeppelin-site.xml
sed -i "s/org.apache.zeppelin.spark.SparkInterpreter,/org.apache.zeppelin.spark.SparkInterpreter,sap.zeppelin.spark.SapSqlInterpreter,/" $ZEPPELIN_HOME/conf/zeppelin-site.xml
sed -i "s/<value>8080/<value>9099/" $ZEPPELIN_HOME/conf/zeppelin-site.xml
$ZEPPELIN_HOME/bin/zeppelin-daemon.sh start
cp /root/interpreter.json $ZEPPELIN_HOME/conf/interpreter.json
$ZEPPELIN_HOME/bin/zeppelin-daemon.sh restart

# mv /root/SHA_create_employee_table.sql /home/hive/
# mv /root/SHA_Employee.dat /home/hive

# chown hive:hive /home/hive/*
 
# su hive -c "hive -f /home/hive/SHA_create_employee_table.sql"
# su hive -c "hdfs dfs -put /home/hive/SHA_Employee.dat /apps/hive/warehouse/sha.db/employee"



# Copy spark Controller jars to hdfs
# su hdfs -c "hdfs dfs -mkdir -p /sap/hana/spark/libs/thirdparty"
# su hdfs -c "hdfs dfs -put $SPARK_HOME/lib/spark-assembly-1.5.1.2.3.6.0-3796-hadoop2.7.1.2.3.6.0-3796.jar /sap/hana/spark/libs/"
# su hdfs -c "hdfs dfs -put -p $SPARK_HOME/lib/datanucleus-core-3.2.10.jar /sap/hana/spark/libs/thridparty"
# su hdfs -c "hdfs dfs -put -p $SPARK_HOME/lib/datanucleus-api-jdo-3.2.6.jar /sap/hana/spark/libs/thridparty"
# su hdfs -c "hdfs dfs -put -p $SPARK_HOME/lib/datanucleus-rdbms-3.2.9.jar /sap/hana/spark/libs/thridparty"
# su hdfs -c "hdfs dfs -put -p /usr/sap/spark/controller/lib.jar /sap/hana/spark/libs/thridparty"

