CREDENTIALS_FILE=/root/scripts/itop-utilities/.credentials
DUMP_FILE=/var/tmp/inventory-sqldump.sql

source /root/scripts/itop-docker/skeleton.sh

EnsureDBisRunning( )
{
RESULT=1
while [ $RESULT -eq 1 ]
do
  /etc/init.d/mysqld stop
  rm -f /var/lock/subsys/mysqld 1>/dev/null 2>/dev/null
  /etc/init.d/mysqld start
  mysql -e " create database if not exists inventory "
  mysql -e " show databases "
  RESULT=$?
  /etc/init.d/mysqld status
done
MostrarLog "DB is running"


}

# Start Mysql, recover last state, generate credentials file...
PreWork( )
{
  MostrarLog "Start $0"
  GenerateItopConnectInfo
  LoadPreviousExecution
  EnsureDBisRunning
}


GenerateItopConnectInfo( )
{

[ ! -z $itop-user      ] && echo "export MY_USER=$itop-user"                     >> $CREDENTIALS_FILE
[ ! -z $itop-pass      ] && echo "export MY_PASS=$itop-pass"                     >> $CREDENTIALS_FILE 
[ ! -z $itop-server    ] && echo "export ITOP_SERVER=$itop-server"               >> $CREDENTIALS_FILE
[ ! -z $itop-directory ] && echo "export INSTALLATION_DIRECTORY=$itop-directory" >> $CREDENTIALS_FILE
[ ! -z $https          ] && echo "export HTTPS=Y" >> $CREDENTIALS_FILE || echo "HTTPS=N"  >> $CREDENTIALS_FILE

[ ! -z $ldap-server    ] && echo "export LDAP_SERVER=\"$ldap-server\""           >> $CREDENTIALS_FILE
[ ! -z $ldap-base      ] && echo "export LDAP_BASE=\"$ldap-base\""               >> $CREDENTIALS_FILE
[ ! -z $ldap-bind-dn   ] && echo "export LDAP_BIND_DN=\"$ldap-bind-dn\""         >> $CREDENTIALS_FILE
[ ! -z $ldap-pass      ] && echo "export LDAP_PASSWORD=\"$ldap-pass\""           >> $CREDENTIALS_FILE

MostrarLog Connection Info: `cat  $CREDENTIALS_FILE`
}

LoadPreviousExecution( )
{
 
  if [ -f $DUMP_FILE ]
  then
    MostrarLog "Previous execution detected. Loading"
    mysql inventory < $DUMP_FILE 
  fi 


}

PreWork



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

MostrarLog "End $0"

