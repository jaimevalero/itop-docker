# Este skeleton deberia ser el nuevo modelo a invocar para todos los script que interactuen con csv
#skeleton

WORKING_PATH=${MY_WORKING_PATH-.}
FICHERO_TRAZA=/var/log/`basename $0`.log
OUTPUT_DIRECTORY=/var/tmp
SYNCH_FILES=

# TODO
# Add index
# mv to spool

#######################################################
#
# Funcion MostrarLog
#
# Saca por log el texto pasado por argumento
#
#######################################################
MostrarLog( )
{
        echo [`basename $0`] [`date +'%Y_%m_%d %H:%M:%S'`] [$$] [${FUNCNAME[1]}] $@  | /usr/bin/tee -a $FICHERO_TRAZA
}

# Check if a tabla has results
CheckTable( )
{
  MostrarLog $1
  MY_TABLA=$1
    echo " mysql $DB -e ' SELECT COUNT(1) AS QUITARQUITAR from $MY_TABLA  '  " > kkinsertarsnap
    chmod +x kkinsertarsnap
    SALIDA=` ./kkinsertarsnap | grep -v QUITAR | awk '{ print $1 }' `
    rm  -f ./kkinsertarsnap 2>/dev/null
  # TODO check wether a table exists
    MostrarLog Resuls: Insert in the table $DB.$MY_TABLA, $SALIDA

}

# Drop table
DropTable( )
{
    MostrarLog $1
    MY_TABLA=$1
    MostrarLog Deleting table $MY_TABLA
    mysql -e " drop table IF EXISTS  $DB.$MY_TABLA" 2>/dev/null 1>/dev/null

}

InsertTable( )
{
    MostrarLog $1
    MY_TABLA=$1 
    mysql -e " create database if not exists $DB"
    DropTable $MY_TABLA
    php /root/scripts/itop-docker/csv_import.php $MY_TABLA $MY_TABLA $DB 2>/dev/null 1>/dev/null
    CheckTable $MY_TABLA
}


CheckFile( )
{
  MostrarLog $1
  MY_FILE=$1
  NUM_LINES=`cat $MY_FILE | wc -l`
  TOTAL=` expr $NUM_LINES - 1 `
  if [ ${TOTAL} -eq 0 ] 
  then
        MostrarLog "ERROR CSV $MY_FILE vacio" 
    else
        MostrarLog "Generado csv $MY_FILE con $TOTAL filas"
  fi
}

Fin( )
{
  MostrarLog End 
}
PreLoadDB( )
{
notin=0
}

LoadingDB( )
{
MostrarLog Loading ${CSV_LIST[*]}

for i in `echo ${CSV_LIST[*]}`
do
  InsertTable $i
done

}

PostCargaDB( )
{
notin=0
}


LoadDB( )
{
    PreLoadDB

    LoadingDB

    PostCargaDB

}

PreGetData( )
{
notin=0
} 
GettingData( )
{
notin=0
} 

# Check csv are not empty
PostGetData( )
{
MostrarLog Loading ${CSV_LIST[*]}

for i in `echo ${CSV_LIST[*]}`
do
  CheckFile $i
done

} 

DeleteTempFiles( )
{
notin=0
} 

GenerateCsvHeader( )
{
for i in `echo ${CSV_LIST[*]}`
do
  echo ${CSV_HEADER[$index]} > $i
  index=`expr $index + 1` 
  MostrarLog Header of $i $CSV_HEADER[$index]
done

}


PreWork( )
{

MostrarLog START:
MostrarLog CSV list :${CSV_LIST[*]}

cd $WORKING_PATH 2>/dev/null



# Reset Variables, set working path, initialize logs...
DeleteTempFiles

# Generate csvheader
GenerateCsvHeader

}

PostWork( )
{
  DeleteTempFiles
}

ReplaceVariables( )
{
  # For each env vble called MY_ITOP_XXX: replace it for its value on the synch file
  for my_exp in ` env | grep MY_ITOP `
  do
    MY_KEY=` echo $my_exp | cut -d\= -f1 `         
    MY_VALUE=` echo $my_exp | cut -d\= -f2-100 `
    sed -i "s/$MY_KEY/$MY_VALUE/g" $TEMP_SYNCH_FILE
  done

}

Synchronizing( )
{
  # For each synch file :copy it to a tmp, 
  # replace with all the related variables 
  # and then call to synch
for i in `echo $SYNCH_FILES`
do
  TEMP_SYNCH_FILE=/tmp/`basename $i`-$$-config
  cp -f $i $TEMP_SYNCH_FILE
  # For each env vble called MY_ITOP_XXX: replace it for its value on the synch file
  ReplaceVariables

  cat $TEMP_SYNCH_FILE
  MostrarLog synching $i
  # Call to synch
  /root/scripts/itop_utilities/synch.sh $TEMP_SYNCH_FILE
  rm -f $TEMP_SYNCH_FILE
done
}
PreSynch( )
{
notin=0
}
PostSynch( )
{
notin=0
}

Synch( )
{
    PreSynch

    Synchronizing

    PostSynch

}

# Get Data
GetData( )
{
    PreGetData

    GettingData

    PostGetData

}

Main( )
{
  
    PreWork

    GetData

    LoadDB

    Synch

    Fin

    PostWork
}


