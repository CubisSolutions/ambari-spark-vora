FROM base
MAINTAINER pascal.de.poorter@cubis.be

# Add the ambari repo to the repository list
RUN cd /etc/apt/sources.list.d && \
    wget http://public-repo-1.hortonworks.com/ambari/ubuntu14/2.x/updates/2.2.0.0/ambari.list && \
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com B9733A7A07513CAD && \
    apt-get update && \
    apt-get install -y ambari-agent

RUN apt-get update && \
    apt-get install -y software-properties-common
    
# add the java component.
RUN sudo add-apt-repository ppa:webupd8team/java && \
    apt-get update && \
    echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections && \
    apt-get install -y oracle-java8-installer
    
# Copy startup script into the docker image
COPY bootstrap.sh /root/bootstrap.sh
RUN chmod +x /root/bootstrap.sh

# Copy PortLocker program to image. Portlocker is used with the docker
# installation for Spark Hana Controller and locks some ports from being
# used by the Controller node programs during the retrieval of data by
# hana SDA. The communications is on ports 56000 - 58000. Data retrieval
# is submitted to the spark hana controller driver, that distributes the
# data requests to one of the namenodes. Since we cannot directly communicate
# with the docker containers, communication is done through the docker host and
# unique ports. Using Port Locker we can prevent that e.g. port 56000 is used by
# all executioner nodes. We will lock 56000 and 56050 from the Secondary docker
# container. This way the master node will use 56000 and 56050 and the secondary
# node will use 56100 and 56150. Ports will be mapped in a similar way in the
# docker-compose.yml file.
RUN mkdir -p /root/com/cubis
COPY PortLocker.class /root/com/cubis/

EXPOSE 2181 4040 7860 7861 8020 8042 8080 8088 8300 8500 9083 9099 9225 10000 18080 45054 49155 50070 56100 56150
