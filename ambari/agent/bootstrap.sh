#!/bin/bash
# inform host about ip adress
echo "$(hostname -i)" > /hostdata/$(hostname)

# service ssh start
service ntp start

sed -i "s/hostname=localhost/hostname=ambarim.cubis/g" /etc/ambari-agent/conf/ambari-agent.ini

# Start the ambari agent.
ambari-agent start

java -cp /root com.cubis.PortLocker 56000 56050
