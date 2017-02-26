#!/bin/bash
# inform host about ip adress
echo "$(hostname -i)" > /hostdata/$(hostname -f)

chown vora /etc/vora/datatools/htpasswd

# java -cp /root com.cubis.PortLocker 56000 56050 &
