FROM base
MAINTAINER pascal.de.poorter@cubis.be

# Add the ambari repo to the repository list
RUN yum -y install ambari-agent
RUN sed -i "s/hostname=localhost/hostname=ambarim.cubis/" /etc/ambari-agent/conf/ambari-agent.ini
 
# Copy startup script into the docker image
COPY bootstrap.sh /root/bootstrap.sh
RUN chmod +x /root/bootstrap.sh

# Copy password file for vora tools
COPY htpasswd /etc/vora/datatools/htpasswd

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

RUN yum clean all

# Copy the ambari blueprint creation/installation scripts
COPY ./scripts/* /root/
RUN rm -f /etc/yum.repos.d/*
RUN mv /root/ambari.repo /etc/yum.repos.d/ambari.repo

RUN systemctl enable ntpd

EXPOSE 2181 2202 3000 4040 6188 7860 7861 8020 8042 8080 8088 8300 8500 9083 9099 9225 10000 18080 45054 49152 49155 50070 56100 56150
