# Array of csv files
LDAP_FIELDS="sn givenName employeeNumber l mail telephoneNumber mobile" 

# Array of csv files
export CSV_LIST=(users)
# Array of csv headers
export CSV_HEADER=(`echo $LDAP_FIELDS| tr ' ' ',' `)

WORKING_PATH=/root/scripts/itop-docker/

# Load skeleton
source /root/scripts/itop-docker/skeleton.sh

SYNCH_FILES="/root/scripts/itop-docker/config/Location-Person.synch /root/scripts/itop-docker/config/Person.synch"

ChoseFilestoSynch( )
{
  # if user has say so, we create organization
 [ $MY_ITOP_CREATE_ORGANIZATION -eq 1 ] && [ ! -z ${MY_ITOP_ORGANIZATION} ] && SYNCH_FILES="/root/scripts/itop-docker/config/Organization-Person.synch $SYNCH_FILES"
 MostrarLog Synchronize files: $SYNCH_FILES

}

DeleteTempFiles( )
{
  rm -f output.ldif output.ldif output.regexp  1>/dev/null 2>/dev/null
  [ -f users ] && mv -f ${CSV_LIST[0]} $OUTPUT_DIRECTORY
}

GettingData( )
{
  MostrarLog "Querying LDAP... ${LDAP_SERVER} ${LDAP_BASE} "
  ldapsearch -D "${LDAP_BIND_DN}" \
    -w "${LDAP_PASSWORD}"  \
    -x  \
    -h "${LDAP_SERVER}"  \
    -b "${LDAP_BASE}" \
    $LDAP_FIELDS | tr ',' ' '  > output.ldif 
}

PostGetData( )
{
 # Decode
 grep -o " .*==" output.ldif |  awk '{print $1}'  | sort -du> output.regexp
 while read line
 do
   line_decoded=`echo $line | python -m base64 -d`
   sed -i "s/${line}/${line_decoded}/g" output.ldif
 done < output.regexp

 # Convert to csv
 cat output.ldif  | ./ldif-to-csv.sh sn givenName employeeNumber l mail telephoneNumber mobile   | grep -v '"","","","","","",""' | tr -d '"' | head -3 >> ${CSV_LIST[0]} 

 # Add date field
 ./AddDateCsv.sh ${CSV_LIST[0]}
}


Main

