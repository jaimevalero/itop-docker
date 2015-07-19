##########################################################
# Accumulate data from DB (as argument) into DB_accumulated
# Used to detect inactive objects
##########################################################
#
##########################################################

FICHERO_TRAZA=/var/log/inventario/`basename $0`.log
#######################################################
#
# Funcion MostrarLog
#
# Saca por log el texto pasado por argumento
#
#######################################################
MostrarLog( )
{
        echo [`basename $0`] [`date +'%Y_%m_%d %H:%M:%S'`] [$$] $@  | /usr/bin/tee -a $FICHERO_TRAZA
}

CopyTableFromDailytoAccumulate( )
{
mysql -e " INSERT IGNORE ${DATABASE}_accumulated.${TABLA} SELECT DISTINCT * FROM  ${DATABASE}.${TABLA}"
}

DeleteDuplicate( )
{
 comprobar=0
 # Copy to a temp table to remove dupes, then delete the old table and rename
 mysql  ${DATABASE}_accumulated -e " DROP TABLE ${TABLA}_TEMP" 1>/dev/null 2>/dev/null
 mysql  ${DATABASE}_accumulated -e " CREATE TABLE ${TABLA}_TEMP SELECT DISTINCT * FROM ${TABLA}" 
 mysql  ${DATABASE}_accumulated -e " DROP TABLE ${TABLA} " 
 mysql  ${DATABASE}_accumulated -e " ALTER TABLE ${TABLA}_TEMP RENAME  ${TABLA} "

}

# We have to replicate indexes from daily database to historic one, because we destroy the index of the table when we accumulate data
AddIndexes( )
{

 mysql  --skip-column-names -e "SELECT 'ALTER TABLE ', CONCAT(TABLE_SCHEMA,'_accumulated.'),TABLE_NAME,'ADD INDEX(',COLUMN_NAME,');' FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_SCHEMA = '${DATABASE}' AND INDEX_NAME =  COLUMN_NAME and TABLE_NAME NOT LIKE '%.%' group by TABLE_SCHEMA,TABLE_NAME,COLUMN_NAME;"   | sed -e "s/\t/ /g"  | sed -e "s/\. /\./g" > kk-index-${DATABASE}

# Log 
 while read line
 do
  MostrarLog $line
  echo $line > kk-index-${DATABASE}-single
  # Create single index
  mysql < kk-index-${DATABASE}

 done < kk-index-${DATABASE}


 rm -f kk-index-${DATABASE}  kk-index-${DATABASE}-single

}

CreateTableifnotExist( )
{
    # Verify table exist on historic database
 #CREATE TABLE db2.table SELECT * FROM db1.table
    mysql -e " select count(1) as QUITAR_QUITAR from ${DATABASE}_accumulated.${TABLA} " 1>/dev/null 2>/dev/null
    RESUL=$?
    if [ $RESUL -eq 1 ]  
    then 
      MostrarLog Creando ${DATABASE}_accumulated.${TABLA}
      mysql -e " CREATE TABLE ${DATABASE}_accumulated.${TABLA} SELECT * FROM ${DATABASE}.${TABLA}"
   fi
}
MostrarLog INICIO:
# hay un bug conocido, por si cambia la estrucura de las tablas, entonces habría que poner esa misma estructura en la DB_accumulated	
# Esperamos argumento, si no por defecto es inventario
if [ $# -ne 1 ]
then
	DATABASE=inventory
else
	DATABASE=$1
fi

mysql -e "Create DATABASE if not exists $DATABASE_accumulated"

for i in ` mysql $DATABASE -e "show tables"  | grep -v Tables_in_ | grep -v backup_summary `  
	do
		TABLA=` echo $i  | awk '{ print $1 }'`
    MostrarLog " "
		MostrarLog Procesando ${DATABASE}.${TABLA} 
   
   # Verify table exist on historic database
   #CREATE TABLE db2.table SELECT * FROM db1.table
   CreateTableifnotExist    

    # Accumulate number of rows
    ROWS_DAILY_TABLE=`mysql -e " select count(1) as QUITAR_QUITAR from ${DATABASE}.${TABLA}" | grep -v QUITAR_QUITAR |   awk '{print $1}' `
    NUM_ROWS_BEFORE=`mysql -e " select count(1) as QUITAR_QUITAR from ${DATABASE}_accumulated.${TABLA}" | grep -v QUITAR_QUITAR |   awk '{print $1}' `

    # Insert ignore to avoid problems with duplicated keys aborting all the proccess
		CopyTableFromDailytoAccumulate 

    # Delete duplicate
    DeleteDuplicate   

    NUM_ROWS_AFTER=`mysql -e " select count(1) as QUITAR_QUITAR from ${DATABASE}_accumulated.${TABLA}" | grep -v QUITAR_QUITAR |   awk '{print $1}' ` 
    NEW_ROWS=` expr $NUM_ROWS_AFTER - $NUM_ROWS_BEFORE`
    MostrarLog "Tabla ${DATABASE}_accumulated.${TABLA} tiene $NUM_ROWS_AFTER de los cuales son nuevos $NEW_ROWS "
    MostrarLog "Tabla ${DATABASE}.${TABLA} Ratio historic/daily =" ` expr $NUM_ROWS_AFTER / $ROWS_DAILY_TABLE`
#exit

done 

AddIndexes

MostrarLog FIN 

