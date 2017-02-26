FROM base
MAINTAINER pascal.de.poorter@cubis.be

# Put ambari server in the container
RUN yum -y install ambari-server

# Also make it possible to run the agent on the master
RUN yum -y install ambari-agent

# Install mysql
RUN wget https://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm && \
    rpm -ivh mysql57-community-release-el7-9.noarch.rpm && \
    yum -y install mysql-server

# Copy the ambari blueprint creation/installation scripts
COPY ./scripts/* /root/
RUN rm -f /etc/yum.repos.d/*
RUN mv /root/ambari.repo /etc/yum.repos.d/ambari.repo

# Copy the VORA repository for installation in the container
COPY ./VORA_AM1_03P_11-80002420.TGZ /root/VORA_AM.TGZ

# Copy the VORA controler for installation in the container
COPY ./controller.distribution-1.6.0-Ambari-Archive.tar.gz /root/VORA_CO.TGZ

# Overwrite internal container to public adress for hana sda data retrieval. 
COPY ./DockerResolver.jar /root/DockerResolver.jar
 
# Extract the VORA files to the HDP service directory
RUN tar -xzvf /root/VORA_CO.TGZ -C /var/lib/ambari-server/resources/stacks/HDP/2.4/services
RUN tar -xzvf /root/VORA_AM.TGZ -C /var/lib/ambari-server/resources/stacks/HDP/2.4/services


# Zeppelin
RUN wget http://archive.apache.org/dist/zeppelin/zeppelin-0.6.2/zeppelin-0.6.2-bin-all.tgz -O /root/ZEPPELIN.TGZ
RUN tar -xzvf /root/ZEPPELIN.TGZ -C /root
COPY ./scripts/interpreter.json /root/interpreter.json

RUN rm /root/*.TGZ

USER root

# Copy startup script into the docker image
COPY bootstrap.sh /root/bootstrap.sh
RUN chmod +x /root/bootstrap.sh

RUN echo 'export ZEPPELIN_HOME=/root/zeppelin-0.6.2-bin-all' >> /etc/bashrc && \
    echo 'export JAVA_HOME=/usr/java/jdk1.8.0_112' >> /etc/bashrc && \
    echo 'export HADOOP_CONF_DIR=/etc/hadoop/conf' >> /etc/bashrc && \
    echo 'export SPARK_HOME=/usr/hdp/2.4.2.0-258/spark' >> /etc/bashrc && \
    echo 'export SPARK_CONF_DIR=$SPARK_HOME/conf' >> /etc/bashrc && \
    echo 'export SPARK_VORA_HOME=/var/lib/ambari-agent/cache/stacks/HDP/2.4/services/vora-manager/package/lib/vora-spark/bin' >> /etc/bashrc && \
    echo 'export PATH=$PATH:$SPARK_HOME/bin' >> /etc/bashrc

RUN yum clean all

RUN systemctl enable ntpd
    
EXPOSE 2181 2202 2204 3000 3306 4040 5005 7860 7861 8020 8042 8080 8088 8300 8500 9083 9099 9225 18080 19000 19888 31015 45054 49152 49155 50070 56000 56050
