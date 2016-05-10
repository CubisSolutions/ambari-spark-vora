# Disable Transparent Huge Pages. --priviledged
echo never | sudo tee /sys/kernel/mm/transparent_hugepage/enabled

# service ssh start
service ntp start
ambari-server start

sed -i "s/hostname=localhost/hostname=ambari.cubis/g" /etc/ambari-agent/conf/ambari-agent.ini

# curl -u admin:admin http://localhost:8080/api/v1/clusters/Cubis?format=blueprint
# curl -u admin:admin http://192.168.99.100:8080/api/v1/hosts
# curl -u admin:admin -H "X-Requested-By: ambari" -X POST -d @./scripts/1node_template.json http://192.168.99.100:8080/api/v1/clusters/Cubis
# 