FROM base
MAINTAINER pascal.de.poorter@cubis.be

# Add the ambari repo to the repository list
RUN cd /etc/apt/sources.list.d && \
    wget http://public-repo-1.hortonworks.com/ambari/ubuntu14/2.x/updates/2.2.0.0/ambari.list && \
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
# Extract the VORA files to the HDP service directory
RUN tar -xzvf /root/VORA_AM.TGZ -C /var/lib/ambari-server/resources/stacks/HDP/2.3/services

EXPOSE 2181 4040 8020 8042 8080 8088 8300 8500 9099 9225 18080 49155 50070 
