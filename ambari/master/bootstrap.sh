# Disable Transparent Huge Pages. --priviledged
echo never | sudo tee /sys/kernel/mm/transparent_hugepage/enabled

# service ssh start
service ntp start
ambari-server start

sed -i "s/hostname=localhost/hostname=ambari.cubis/g" /etc/ambari-agent/conf/ambari-agent.ini

ambari-agent start

printf 'Waiting for ambari-master'
until $(curl --output /dev/null --silent --head --fail http://localhost:8080); do
  printf '.'
  sleep 5
done

curl -u admin:admin -H "X-Requested-By: ambari" -X POST -d @./cubis1node_blueprint.json http://localhost:8080/api/v1/blueprints/cubis1node_blueprint
curl -u admin:admin -H "X-Requested-By: ambari" -X POST -d @./1node_template.json http://localhost:8080/api/v1/clusters/Cubis

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

# Prepare HDFS for vora
su hdfs -c "hadoop fs -mkdir /user/vora"
su hdfs -c "hadoop fs -chown vora /user/vora"

#sleep 100000