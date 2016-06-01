# ambari-spark-vora
Ambari Spark Vora cluster setup for demo purposes

Pre-requisited
Docker needs to be installed on in order to run the environment and can be found [here](https://docs.docker.com/engine/installation/)

## Using the docker shell

Building the docker images

**Note:** *You should get the VORA package (VORA_AM1_02_0-70001227.TGZ) from* [SAP Download](https://launchpad.support.sap.com/#/softwarecenter/search/vora%25201.2) *and store it under the ./ambari/master folder. It's also internally available on dropbox.*
```
docker build -t base ./base
docker build -t ambari_master ./ambari/master
```
Running the docker image:
```
docker-compose up -d
```
Stopping the docker image:
```
docker-compose down
```
Starting the ambari webgui (admin/admin):
- Determine IP of the docker machine: 
```
docker-machine ip default
```
- Start the webgui: 
```
http://{ip}:8080
```
