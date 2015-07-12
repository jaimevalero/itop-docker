# Este skeleton deberia ser el nuevo modelo a invocar para todos los script que interactuen con csv
#skeleton

WORKING_PATH=${MY_WORKING_PATH-.}
FICHERO_TRAZA=/var/log/`basename $0`.log

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
    echo " mysql -e ' SELECT COUNT(1) AS QUITARQUITAR from $DB.$MY_TABLA  '  " > kkinsertarsnap
    chmod +x kkinsertarsnap
    SALIDA=` ./kkinsertarsnap | grep -v QUITAR | awk '{ print $1 }' `
    rm  -f ./kkinsertarsnap 2>/dev/null
  # TODO check wether a table exists
    MostrarLog Resultados: Insert contra la tabla $DB.$MY_TABLA, $SALIDA

}

# Drop table
DropTable( )
{
  MostrarLog $1
    MY_TABLA=$1
    MostrarLog Borrando Tabla $MY_TABLA
    mysql -e " drop table IF EXISTS  $DB.$MY_TABLA" 2>/dev/null 1>/dev/null

}

InsertTable( )
{
  MostrarLog $1
  MY_TABLA=$1 

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
MostrarLog FIN 

}
PreLoadDB( )
{
notin=0
}

LoadingDB( )
{
MostrarLog Cargando ${CSV_LIST[*]}

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
MostrarLog Cargando ${CSV_LIST[*]}

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
  MostrarLog Cabecera de $i $CSV_HEADER[$index]
done

}


PreWork( )
{

MostrarLog INICIO:
MostrarLog Lista CSVs :${CSV_LIST[*]}

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

    Fin

    PostWork
}


