CREDENTIALS_FILE=/root/scripts/itop-utilities/.credentials
DUMP_FILE=/var/tmp/inventory-sqldump.sql

source /root/scripts/itop-docker/skeleton.sh

CreateDBUser( )
{
mysql -e "grant all on *.* to 'cmdb'@'localhost' identified by '6yhnmju7';"
}
EnsureDBisRunning( )
{
RESULT=1
while [ $RESULT -eq 1 ]
do
  /etc/init.d/mysqld stop
  rm -f /var/lock/subsys/mysqld 1>/dev/null 2>/dev/null
  /etc/init.d/mysqld start
  mysql -N -e " create database if not exists inventory "
  mysql -N -e "SELECT 'Testing mysql OK' "
  RESULT=$?
  /etc/init.d/mysqld status
done
MostrarLog "DB is running"

CreateDBUser

}

GetCorrectTime( )
{
   sudo service ntp stop ; sudo ntpdate -s time.nist.gov ; sudo service ntp start ; date
}

# Start Mysql, recover last state, generate credentials file...
PreWork( )
{
  MostrarLog "Start $0"
  GenerateItopConnectInfo
  LoadPreviousExecution
  EnsureDBisRunning
  GetCorrectTime
}


GenerateItopConnectInfo( )
{
# Avoid to upload produciton info to combodo's demo site
[ ` cat $CREDENTIALS_FILE | grep demo | wc -l ` -eq 1 ] > $CREDENTIALS_FILE
# Mysql 
echo "export MYSQL_USER=cmdb"          >> $CREDENTIALS_FILE
echo "export MYSQL_PASS=6yhnmju7"      >> $CREDENTIALS_FILE
echo "export MYSQL_HOSTNAME=localhost" >> $CREDENTIALS_FILE

# itop server credentials
[ ! -z ${itop_user}      ] && echo "export ITOP_USER=${itop_user}"                     >> $CREDENTIALS_FILE
[ ! -z ${itop_pass}      ] && echo "export ITOP_PASS=${itop_pass}"                     >> $CREDENTIALS_FILE 
[ ! -z ${itop_server}    ] && echo "export ITOP_SERVER=${itop_server}"               >> $CREDENTIALS_FILE
[ ! -z ${itop_directory} ] && echo "export INSTALLATION_DIRECTORY=${itop_directory}" >> $CREDENTIALS_FILE
[ ! -z ${https}          ] && echo "export HTTPS=Y" >> $CREDENTIALS_FILE || echo "HTTPS=N"  >> $CREDENTIALS_FILE

# ldap options
[ ! -z ${ldap_server}    ] && echo "export LDAP_SERVER=\"${ldap_server}\""           >> $CREDENTIALS_FILE
[ ! -z ${ldap_base}      ] && echo "export LDAP_BASE=\"${ldap_base}\""               >> $CREDENTIALS_FILE
[ ! -z ${ldap_bind_dn}   ] && echo "export LDAP_BIND_DN=\"${ldap_bind_dn}\""         >> $CREDENTIALS_FILE
[ ! -z ${ldap_pass}      ] && echo "export LDAP_PASSWORD=\"${ldap_pass}\""           >> $CREDENTIALS_FILE

# misc option
[ ! -z ${organization}   ] && echo "export MY_ITOP_ORGANIZATION=\"${organization}\"" >> $CREDENTIALS_FILE
[ `echo ${create_organization} | grep -i y | wc -l ` -eq 1 ] && CREATE_FLAG=1 || CREATE_FLAG=0 ;  
echo "export MY_ITOP_CREATE_ORGANIZATION=$CREATE_FLAG"  >> $CREDENTIALS_FILE 

MostrarLog Connection Info: 
cat  $CREDENTIALS_FILE #| sed -e 's/MY_ITOP_//g' 
}

LoadPreviousExecution( )
{
 
  if [ -f $DUMP_FILE ]
  then
    MostrarLog "Previous execution detected. Loading"
    mysql inventory < $DUMP_FILE 
  fi 


}

# Main
PreWork

cd /root/scripts/itop-docker; ./FromLDAP2Itop.sh

# Dump results
mysqldump inventory > $DUMP_FILE
mysql inventory_accumulated "SELECT * from users"
ls -altr  $DUMP_FILE

MostrarLog "End $0"

