# PreWork
/etc/init.d/mysqld restart 

CREDENTIALS_FILE=/root/scripts/itop-utilities/.credentials


GenerateItopConnectInfo( )
{

[ ! -z $itop-user      ] && echo "MY_USER=$itop-user"                     >> $CREDENTIALS_FILE
[ ! -z $itop-pass      ] && echo "MY_PASS=$itop-pass"                     >> $CREDENTIALS_FILE 
[ ! -z $itop-server    ] && echo "ITOP_SERVER=$itop-server"               >> $CREDENTIALS_FILE
[ ! -z $itop-directory ] && echo "INSTALLATION_DIRECTORY=$itop-directory" >> $CREDENTIALS_FILE
[ ! -z $https          ] && echo "HTTPS=Y" >> $CREDENTIALS_FILE || echo "HTTPS=N"  >> $CREDENTIALS_FILE
}


GenerateItopConnectInfo

#source  /root/scripts/openstack-utilities/profiles/${profile}

#mysql  -e  " GRANT ALL ON *.* TO 'root'@'localhost' IDENTIFIED BY '6yhnmju7' "

#mysql -u${MYSQL_USER} -p${MYSQL_PASS} -h${MYSQL_HOSTNAME} -e " show databases"
#RESUL=$?
#[ $RESUL -ne 0 ] && echo " Incorrectas credenciales" && exit 1
#
# Work
#/root/scripts/openstack-utilities/OpenStack2Mysql.sh  /root/scripts/openstack-utilities/profiles/${profile}

# Dump results
source  /root/scripts/openstack-utilities/profiles/${profile} 
mysqldump  -u${MYSQL_USER} -p${MYSQL_PASS} -h${MYSQL_HOSTNAME} $MYSQL_DATABASE  


