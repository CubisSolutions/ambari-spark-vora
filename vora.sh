#!/bin/bash
#
# Start the vora hadoop environment
#
#
init() {
  if ! [ -n "$HOSTDATA" ]; then
    echo "Variable 'HOSTDATA' not set! Used to put local data available to 'ambarim.cubis'."
    exit 1
  fi
  if ! [ -n "$vpnip" ]; then
    # vpnip is returned by the DockerResolver class and is used to inform the HANA sda
    # with which ip adress it should communicate for receiving data from VORA table lookup
    # from HANA 
    # If no explicit adress is set. VPN communication is expected between hana and the host.
    # If no vpn tunnel is up
    export vpnip=$(ifconfig | grep -A 1 'tun0' | tail -1 | cut -d ':' -f 2 | cut -d ' ' -f 1)
    if ! [ -n "$vpnip" ]; then
       echo "Variable 'vpnip' not set! HANA will no be able to retrieve data from the VORA cluster." 
    else
       echo "Variable 'vpnip' set to $vpnip."
    fi
  else
    echo "Variable 'vpnip' set to $vpnip."
  fi
  rm -f $HOSTDATA/*.cubis
}

set_hosts() {
   if [ -n "$( grep "$1" /etc/hosts )" ]
   then
      sed -i "/$1/ s/.*/$(head -n 1 $HOSTDATA/$1)\t$1/g" /etc/hosts
   else
      echo "$(head -n 1 $HOSTDATA/$1 -i)    $1" >> /etc/hosts 
   fi
}

wait_for_hosts() {
   check=0
   counter=1
   while :
   do
     if [ $counter -eq 30 ]
     then 
        break
     fi
     # check if ambarim.cubis exists
     if [ -f "$HOSTDATA/ambaria1.cubis" ]
     then
        check=$(( $check | 1 ))
     fi 
     if [ -f "$HOSTDATA/ambaria2.cubis" ]
     then
        check=$(( $check | 2 ))
     fi 
     if [ -f "$HOSTDATA/ambaris.cubis" ]
     then
        check=$(( $check | 4 ))
     fi 
     if [ -f "$HOSTDATA/ambarim.cubis" ]
     then
        check=$(( $check | 8 ))
     fi 
     if [ $check -eq 15 ]
     then
        set_hosts "ambaria1.cubis"
        set_hosts "ambaria2.cubis"
        set_hosts "ambaris.cubis"
        set_hosts "ambarim.cubis"
        echo "Loops: $counter"
        break
     fi
     counter=$(( $counter + 1 ))
     sleep 5 
   done    
}

# Main
init
docker-compose $1 $2 
wait_for_hosts

exit 0   
