FROM base
MAINTAINER pascal.de.poorter@cubis.be

# Install http server for local repository hosting for ambari installation
RUN yum -y install httpd
RUN systemctl enable httpd
RUN mkdir -p /var/www/html/ambari/centos7 && \
    mkdir -p /var/www/html/hdp/centos7

# Create local ambari util repositories
RUN reposync -r Updates-ambari-2.2.2.0 -p /var/www/html/ambari/centos7 && \
    reposync -r HDP-2.4.2.0 -p /var/www/html/hdp/centos7 && \
    reposync -r HDP-UTILS-1.1.0.20 -p /var/www/html/hdp/centos7

RUN createrepo /var/www/html/ambari/centos7/Updates-ambari-2.2.2.0 && \
    createrepo /var/www/html/hdp/centos7/HDP-2.4.2.0 && \
    createrepo /var/www/html/hdp/centos7/HDP-UTILS-1.1.0.20
    
EXPOSE 80
