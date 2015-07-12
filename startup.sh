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

[ ! -z ${itop_user}      ] && echo "export MY_USER=${itop_user}"                     >> $CREDENTIALS_FILE
[ ! -z ${itop_pass}      ] && echo "export MY_PASS=${itop_pass}"                     >> $CREDENTIALS_FILE 
[ ! -z ${itop_server}    ] && echo "export ITOP_SERVER=${itop_server}"               >> $CREDENTIALS_FILE
[ ! -z ${itop_directory} ] && echo "export INSTALLATION_DIRECTORY=${itop_directory}" >> $CREDENTIALS_FILE
[ ! -z ${https}          ] && echo "export HTTPS=Y" >> $CREDENTIALS_FILE || echo "HTTPS=N"  >> $CREDENTIALS_FILE

[ ! -z ${ldap_server}    ] && echo "export LDAP_SERVER=\"${ldap_server}\""           >> $CREDENTIALS_FILE
[ ! -z ${ldap_base}      ] && echo "export LDAP_BASE=\"${ldap_base}\""               >> $CREDENTIALS_FILE
[ ! -z ${ldap_bind_dn}   ] && echo "export LDAP_BIND_DN=\"${ldap_bind_dn}\""         >> $CREDENTIALS_FILE
[ ! -z ${ldap_pass}      ] && echo "export LDAP_PASSWORD=\"${ldap_pass}\""           >> $CREDENTIALS_FILE

MostrarLog Connection Info: 
cat  $CREDENTIALS_FILE
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

