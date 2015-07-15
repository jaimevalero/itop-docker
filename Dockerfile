# Test
FROM       appcontainers/centos66
MAINTAINER Jaime Valero <jaimevalero78@yahoo.es>
LABEL      Description="Synchronize user data from LDAP to Itop" Version="0.3.0"

# Install dependencies for repo
RUN yum install    -y mysql-server nc openldap-clients php php-common php-pdo php-cli php-mysql
RUN /etc/init.d/mysqld start 

# Get git repos
RUN mkdir -p /root/scripts/itop-docker
RUN yum install -y git
RUN yum clean all
RUN cd /root/scripts &&  git clone "https://github.com/jaimevalero78/itop-utilities"


# Permissions and entrypoint
CMD ["/bin/bash", "/root/scripts/itop-docker/startup.sh"]

# Start scripts
ADD ./startup.sh                                /root/scripts/itop-docker/startup.sh  
ADD ./root/scripts/itop-docker/csv_import.php   /root/scripts/itop-docker/csv_import.php 
ADD ./root/scripts/itop-docker/ldif-to-csv.sh   /root/scripts/itop-docker/ldif-to-csv.sh 
ADD ./root/scripts/itop-docker/AddDateCsv.sh    /root/scripts/itop-docker/AddDateCsv.sh
ADD ./root/scripts/itop-docker/skeleton.sh      /root/scripts/itop-docker/skeleton.sh
ADD ./root/scripts/itop-docker/FromItop2LDAP.sh /root/scripts/itop-docker/FromItop2LDAP.sh

RUN chmod +x /root/scripts/itop-docker/startup.sh \
         /root/scripts/itop-docker/csv_import.php \
         /root/scripts/itop-docker/ldif-to-csv.sh \
         /root/scripts/itop-docker/AddDateCsv.sh \
         /root/scripts/itop-docker/skeleton.sh \
         /root/scripts/itop-docker/FromItop2LDAP.sh
RUN find root/scripts/itop-docker/ -name "*.sh"
RUN touch /root/scripts/itop-utilities/.credentials 
RUN ln -s /root/scripts/itop-utilities/.credentials /root/scripts/itop-docker/.credentials

EXPOSE 3306
VOLUME ["/var/tmp/" ]

