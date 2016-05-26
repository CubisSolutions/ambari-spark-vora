#!/bin/bash
# service ssh start
service ntp start

sed -i "s/hostname=localhost/hostname=ambarim.cubis/g" /etc/ambari-agent/conf/ambari-agent.ini

# Start the ambari agent.
ambari-agent start

while true ; do
  sleep 100000
done
