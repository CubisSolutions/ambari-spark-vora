FROM centos:7
MAINTAINER pascal.de.poorter@cubis.be

RUN yum -y install libaio unzip ntp

RUN yum -y install epel-release

RUN yum -y install numactl

RUN yum -y install libtool libtool-ltdl lsof sudo

RUN yum -y install wget initscripts yum-utils createrepo redhat-lsb

RUN wget http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.2.2.0/ambari.repo -O /etc/yum.repos.d/ambari.repo && \
         wget http://public-repo-1.hortonworks.com/HDP/centos7/2.x/updates/2.4.2.0/hdp.repo -O /etc/yum.repos.d/hdp.repo && \
         yum repolist

RUN wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u112-b15/jdk-8u112-linux-x64.rpm"

RUN rpm -ivh jdk-8u112-linux-x64.rpm

RUN rm *.rpm

RUN yum -y install mysql-connector-java*

RUN yum -y install python-devel net-tools rpcbind nc fuse fuse-libs

RUN yum clean all

ENV container docker

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

VOLUME [ "/sys/fs/cgroup" ]

CMD ["/usr/sbin/init"]


