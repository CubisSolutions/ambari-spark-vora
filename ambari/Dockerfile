FROM ubuntu:trusty
MAINTAINER pascal.de.poorter@cubis.be

# We need wget to download the ambari repo
RUN apt-get update && \
    apt-get -y install wget sudo ssh

# Add the ambari repo to the repository list
RUN cd /etc/apt/sources.list.d && \
    wget http://public-repo-1.hortonworks.com/ambari/ubuntu14/2.x/updates/2.2.0.0/ambari.list && \
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com B9733A7A07513CAD && \
    apt-get update && \
    apt-get install -y ambari-server

RUN mkdir ~/.ssh && \
    chmod 700 ~/.ssh && \
    ssh-keygen -f ~/.ssh/id_rsa -N "" && \
    cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys && \
    chmod 600 ~/.ssh/authorized_keys && \
    service ssh start


# Run ambari setup with the default settings
RUN ambari-server setup -s
