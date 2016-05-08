FROM ubuntu:wily
MAINTAINER pascal.de.poorter@cubis.be

# apt-get install wget
# Add the ambari repo to the repository list
RUN cd /etc/apt/sources.list.d && \
    wget http://public-repo-1.hortonworks.com/ambari/ubuntu14/2.x/updates/2.2.0.0/ambari.list && \
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com B9733A7A07513CAD && \
    apt-get update && \
    apt-get install ambari-server

# Run ambari setup with the default settings
RUN ambari-server setup -s
