# ambari-spark-vora
Ambari Spark Vora cluster setup for demo purposes

Pre-requisited
Docker needs to be installed on in order to run the environment and can be found [here](https://docs.docker.com/engine/installation/)

## Using the docker shell

Building the docker images

**Note:** *You should get the VORA package (VORA_AM1_02_0-70001227.TGZ) from* [SAP Download](https://launchpad.support.sap.com/#/softwarecenter/search/vora%25201.2) *and store it under the ./ambari/master folder. You also need the hana controler 1.6 from [SAP Download](https://launchpad.support.sap.com/#/softwarecenter/search/spark%2520controller). Extract the zip and store the tar.gz file under ./ambari/master*. The files are also internally available on dropbox.
```
docker build -t base ./base
docker build -t ambari_master ./ambari/master
docker build -t ambari_agent ./ambari/agent
```
Running the docker image:
```
docker-compose up -d
```
Accessing the master linux node:
```
docker exec -it ambari_master /bin/bash
```
Stopping the docker image:
```
docker-compose down
```
Starting the ambari webgui (admin/admin):
- Determine IP of the docker machine: 
```
docker-machine ip default
add the ip to the "C:\Windows\System32\drivers\etc\hosts" file (start editor as administrator):
                                                                                              
{ip}  ambarim.cubis ambarim
```
- Start the ambari webgui: 
```
http://ambarim.cubis:8080
```
- Start the zeppelin notebook: 
```
http://ambarim.cubis:9099
```
##Testing the environment

See [wiki](https://github.com/CubisSolutions/ambari-spark-vora/wiki/Testing-the-vora-environment)  

##Versions

v1.0: Delivers standalone cluster SPARK-HDFS-VORA runnable in docker.

V1.1: Cluster with extended with HANA Spark Controller. Read/write to SAP HANA from SPARK possible.
