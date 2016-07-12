FROM base
MAINTAINER pascal.de.poorter@cubis.be

# Add the ambari repo to the repository list
RUN cd /etc/apt/sources.list.d && \
    wget http://public-repo-1.hortonworks.com/ambari/ubuntu14/2.x/updates/2.2.0.0/ambari.list && \
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com B9733A7A07513CAD && \
    apt-get update && \
    apt-get install -y ambari-agent
    
# Copy startup script into the docker image
COPY bootstrap.sh /root/bootstrap.sh
RUN chmod +x /root/bootstrap.sh

EXPOSE 2181 4040 8020 8042 8080 8088 8300 8500 9099 9225 18080 45054 49155 50070
