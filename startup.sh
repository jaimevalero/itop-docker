CREDENTIALS_FILE=/root/scripts/itop-utilities/.credentials
DUMP_FILE=/var/tmp/inventory-sqldump.sql


# PreWork
PreWork( )
{
  echo "Iniciando $0"
  /etc/init.d/mysqld restart 
  /etc/init.d/mysqld status
}

GenerateItopConnectInfo( )
{

[ ! -z $itop-user      ] && echo "MY_USER=$itop-user"                     >> $CREDENTIALS_FILE
[ ! -z $itop-pass      ] && echo "MY_PASS=$itop-pass"                     >> $CREDENTIALS_FILE 
[ ! -z $itop-server    ] && echo "ITOP_SERVER=$itop-server"               >> $CREDENTIALS_FILE
[ ! -z $itop-directory ] && echo "INSTALLATION_DIRECTORY=$itop-directory" >> $CREDENTIALS_FILE
[ ! -z $https          ] && echo "HTTPS=Y" >> $CREDENTIALS_FILE || echo "HTTPS=N"  >> $CREDENTIALS_FILE

[ ! -z $ldap-server    ] && echo "LDAP_SERVER=\"$ldap-server\""           >> $CREDENTIALS_FILE
[ ! -z $ldap-base      ] && echo "LDAP_BASE=\"$ldap-base\""               >> $CREDENTIALS_FILE
[ ! -z $ldap-bind-dn   ] && echo "LDAP_BIND_DN=\"$ldap-bind-dn\""         >> $CREDENTIALS_FILE
[ ! -z $ldap-pass      ] && echo "LDAP_PASSWORD=\"$ldap-pass\""           >> $CREDENTIALS_FILE

}

LoadPreviousExecution( )
{
 
  if [ -f $DUMP_FILE ]
  then
    echo "Previous execution detected. Loading"
    mysql -e " create database if not exists inventory"
    mysql inventory < $DUMP_FILE 
  fi
}

PreWork

GenerateItopConnectInfo

LoadPreviousExecution


#source  /root/scripts/openstack-utilities/profiles/${profile}

#mysql  -e  " GRANT ALL ON *.* TO 'root'@'localhost' IDENTIFIED BY '6yhnmju7' "

#mysql -u${MYSQL_USER} -p${MYSQL_PASS} -h${MYSQL_HOSTNAME} -e " show databases"
#RESUL=$?
#[ $RESUL -ne 0 ] && echo " Incorrectas credenciales" && exit 1
#
# Work
#/root/scripts/openstack-utilities/OpenStack2Mysql.sh  /root/scripts/openstack-utilities/profiles/${profile}

cd /root/scripts/itop-docker; ./FromItop2LDAP.sh

# Dump results
mysqldump inventory > $DUMP_FILE


