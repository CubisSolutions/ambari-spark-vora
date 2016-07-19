FROM base
MAINTAINER pascal.de.poorter@cubis.be

# Add the ambari repo to the repository list
RUN cd /etc/apt/sources.list.d && \
    wget -nv http://public-repo-1.hortonworks.com/ambari/ubuntu14/2.x/updates/2.2.0.0/ambari.list && \
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com B9733A7A07513CAD && \
    apt-get update && \
    apt-get install -y ambari-server
    
RUN adduser -ingroup users vora

# Run ambari setup with the default settings
RUN ambari-server setup -s

# Also make it possible to run the agent on the master
RUN apt-get install -y ambari-agent

# Copy startup script into the docker image
COPY bootstrap.sh /root/bootstrap.sh
RUN chmod +x /root/bootstrap.sh

# Copy the ambari blueprint creation/installation scripts
COPY ./scripts/* /root/

# Copy the VORA repository for installation in the container
COPY ./VORA_AM1_02_0-70001227.TGZ /root/VORA_AM.TGZ

# Copy the VORA controler for installation in the container
COPY ./controller.distribution-1.6.0-Ambari-Archive.tar.gz /root/VORA_CO.TGZ
 
# Extract the VORA files to the HDP service directory
RUN tar -xzvf /root/VORA_CO.TGZ -C /var/lib/ambari-server/resources/stacks/HDP/2.3/services
RUN tar -xzvf /root/VORA_AM.TGZ -C /var/lib/ambari-server/resources/stacks/HDP/2.3/services

RUN rm /root/*.TGZ

# Install Zeppelin under the vora user
USER vora
RUN wget -O /home/vora/ZEPPELIN.TGZ http://archive.apache.org/dist/incubator/zeppelin/0.5.6-incubating/zeppelin-0.5.6-incubating-bin-all.tgz
RUN tar -xzvf /home/vora/ZEPPELIN.TGZ -C /home/vora && \
    cp /home/vora/zeppelin-0.5.6-incubating-bin-all/conf/zeppelin-site.xml.template /home/vora/zeppelin-0.5.6-incubating-bin-all/conf/zeppelin-site.xml && \
    chmod 0755 /home/vora/zeppelin-0.5.6-incubating-bin-all/conf/zeppelin-site.xml && \
    sed -i "s/ScaldingInterpreter<\/value>/ScaldingInterpreter,org.apache.spark.sql.SapSqlInterpreter<\/value>/" /home/vora/zeppelin-0.5.6-incubating-bin-all/conf/zeppelin-site.xml 
    
RUN cp /home/vora/zeppelin-0.5.6-incubating-bin-all/conf/zeppelin-env.sh.template /home/vora/zeppelin-0.5.6-incubating-bin-all/conf/zeppelin-env.sh && \
    chmod 0755 /home/vora/zeppelin-0.5.6-incubating-bin-all/conf/zeppelin-env.sh  && \
    echo "export MASTER=yarn-client" >>  /home/vora/zeppelin-0.5.6-incubating-bin-all/conf/zeppelin-env.sh && \
    echo "export ZEPPELIN_PORT=9099" >>  /home/vora/zeppelin-0.5.6-incubating-bin-all/conf/zeppelin-env.sh 
    
RUN mkdir /home/vora/tmp && cd /home/vora/tmp && \
    /usr/jdk64/jdk1.8.0_60/bin/jar -xf /var/lib/ambari-server/resources/stacks/HDP/2.3/services/vora-base/package/lib/vora-spark/lib/spark-sap-datasources-1.2.33-assembly.jar && \
    /usr/jdk64/jdk1.8.0_60/bin/jar -xf /home/vora/zeppelin-0.5.6-incubating-bin-all/interpreter/spark/zeppelin-spark-0.5.6-incubating.jar && \
    /usr/jdk64/jdk1.8.0_60/bin/jar -cvf /home/vora/zeppelin-0.5.6-incubating-bin-all/interpreter/spark/zeppelin-spark-sap-combined.jar -C /home/vora/tmp .
    
RUN rm /home/vora/zeppelin-0.5.6-incubating-bin-all/interpreter/spark/zeppelin-spark-0.5.6-incubating.jar && \
    rm -r /home/vora/tmp

RUN rm /home/vora/*.TGZ

USER root

RUN echo 'export LD_LIBRARY_PATH=/usr/hdp/2.3.6.0-3796/hadoop/lib/native' >> /etc/bash.bashrc && \
    echo 'export JAVA_HOME=/usr/jdk64/jdk1.8.0_60' >> /etc/bash.bashrc && \
    echo 'export HADOOP_CONF_DIR=/etc/hadoop/conf' >> /etc/bash.bashrc && \
    echo 'export SPARK_HOME=/usr/hdp/2.3.6.0-3796/spark' >> /etc/bash.bashrc && \
    echo 'export SPARK_CONF_DIR=$SPARK_HOME/conf' >> /etc/bash.bashrc && \
    echo 'export SPARK_VORA_HOME=/var/lib/ambari-agent/cache/stacks/HDP/2.3/services/vora-base/package/lib/vora-spark' >> /etc/bash.bashrc && \
    echo 'export PATH=$PATH:$SPARK_HOME/bin' >> /etc/bash.bashrc 
    
EXPOSE 2181 4040 7860 7861 8020 8042 8080 8088 8300 8500 9083 9099 9225 18080 31015 45054 49155 50070 56000-58000
