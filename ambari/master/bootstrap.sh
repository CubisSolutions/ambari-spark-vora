#!/bin/bash
# Disable Transparent Huge Pages. --priviledged
echo never | sudo tee /sys/kernel/mm/transparent_hugepage/enabled

# service ssh start
service ntp start
ambari-server start

sed -i "s/hostname=localhost/hostname=ambarim.cubis/g" /etc/ambari-agent/conf/ambari-agent.ini

ambari-agent start

printf 'Waiting for ambari-master'
until $(curl --output /dev/null --silent --head --fail http://localhost:8080); do
  printf '.'
  sleep 5
done

curl -u admin:admin -H "X-Requested-By: ambari" -X POST -d @/root/cubis1node_blueprint.json http://localhost:8080/api/v1/blueprints/cubis1node_blueprint?validate_topology=false
curl -u admin:admin -H "X-Requested-By: ambari" -X POST -d @/root/1node_template.json http://localhost:8080/api/v1/clusters/Cubis

printf '\n\nWaiting for Cubis-cluster to be up'
while true ; do
  message=$(curl -u admin:admin -i -s -H 'X-Requested-By: ambari' -X GET http://localhost:8080/api/v1/clusters/Cubis/requests/1 | grep progress_percent)
  if grep -qw '100' <<< "$message" ; then
     break
  else
     printf '.'
     sleep 5  
  fi
done
printf '\nDone'

# variables defined in bash.bashrc not available on docker entrypoint startup

export JAVA_HOME=/usr/jdk64/jdk1.8.0_60 
export HADOOP_CONF_DIR=/etc/hadoop/conf
export SPARK_HOME=/usr/hdp/2.3.6.0-3796/spark
export SPARK_CONF_DIR=$SPARK_HOME/conf
export PATH=$PATH:$SPARK_HOME/bin 
export LD_LIBRARY_PATH=/usr/hdp/2.3.6.0-3796/hadoop/lib/native 
 
# Prepare HDFS for vora
su hdfs -c "hadoop fs -mkdir /user/vora"
su hdfs -c "hadoop fs -chown vora /user/vora"

# Try to tart the zeppelin service
sudo vora -c set
while true ; do
  su vora -c "/home/vora/zeppelin-0.5.6-incubating-bin-all/bin/zeppelin-daemon.sh start"
  message=$(su vora -c "/home/vora/zeppelin-0.5.6-incubating-bin-all/bin/zeppelin-daemon.sh status" | grep running)
  if grep -qw 'OK' <<< "$message" ; then
     break
  else
     printf '.'
     sleep 5  
  fi
done

su vora -c "echo '1,2,Hello' > /home/vora/test.csv"
su vora -c "hadoop fs -put /home/vora/test.csv"

# mv /root/SHA_create_employee_table.sql /home/hive/
# mv /root/SHA_Employee.dat /home/hive

# chown hive:hive /home/hive/*
 
# su hive -c "hive -f /home/hive/SHA_create_employee_table.sql"
# su hive -c "hdfs dfs -put /home/hive/SHA_Employee.dat /apps/hive/warehouse/sha.db/employee"

# cp spark-sap-datasource...jar to spark controller library
cp /var/lib/ambari-server/resources/stacks/HDP/2.3/services/vora-base/package/lib/vora-spark/lib/spark-sap-datasources-1.2.33-assembly.jar /usr/sap/spark/controller/lib/
chown hanaes:sapsys /usr/sap/spark/controller/lib/spark-sap-datasources-1.2.33-assembly.jar 

# Copy spark Controller jars to hdfs
# su hdfs -c "hdfs dfs -mkdir -p /sap/hana/spark/libs/thirdparty"
# su hdfs -c "hdfs dfs -put $SPARK_HOME/lib/spark-assembly-1.5.1.2.3.6.0-3796-hadoop2.7.1.2.3.6.0-3796.jar /sap/hana/spark/libs/"
# su hdfs -c "hdfs dfs -put -p $SPARK_HOME/lib/datanucleus-core-3.2.10.jar /sap/hana/spark/libs/thridparty"
# su hdfs -c "hdfs dfs -put -p $SPARK_HOME/lib/datanucleus-api-jdo-3.2.6.jar /sap/hana/spark/libs/thridparty"
# su hdfs -c "hdfs dfs -put -p $SPARK_HOME/lib/datanucleus-rdbms-3.2.9.jar /sap/hana/spark/libs/thridparty"
# su hdfs -c "hdfs dfs -put -p /usr/sap/spark/controller/lib.jar /sap/hana/spark/libs/thridparty"

while true ; do
   sleep 100000
done
