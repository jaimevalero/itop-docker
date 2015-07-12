# Test
FROM appcontainers/centos66
MAINTAINER Jaime Valero <jaimevalero78@yahoo.es>
LABEL Description="Synchronize user data from LDAP to Itop" Version="0.1.0"

# Get git
RUN mkdir /root/scripts
RUN yum install -y git 
RUN cd /root/scripts && git clone "https://github.com/jaimevalero78/itop-utilities"

# Install dependencies for repo
RUN yum install    -y mysql-server nc php php-common php-pdo php-cli php-mysql
RUN /etc/init.d/mysqld start 

CMD ["/bin/bash", "/root/scripts/openstack-utilities/startup.sh"]

EXPOSE 3306
VOLUME ["/var/tmp/" ]

# Start scripts
#ADD ./startup.sh /root/scripts/itop-utilities/startup.sh
#RUN chmod +x /root/scripts/openstack-utilities/OpenStack2Mysql.sh /root/scripts/openstack-utilities/startup.sh
