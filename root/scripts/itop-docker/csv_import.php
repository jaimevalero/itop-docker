<?php

$host = 'localhost';
$user = 'root';
$pass = '';
$database = 'video';


/********************************************************************************/
// Parameters: filename.csv table_name

$argv = $_SERVER[argv];

if($argv[1]) { $file = $argv[1]; }
else {
    echo "Please provide a file name\n"; exit; 
}
if($argv[2]) { $table = $argv[2]; }
else {
    $table = pathinfo($file);
    $table = $table['filename'];
}

if($argv[3]) { $database = $argv[3]; }
else {
$database = 'video';
}

echo $database,"\n" ;  
$db = mysql_connect($host, $user, $pass);
mysql_query("use $database", $db);



/********************************************************************************/
// Get the first row to create the column headings

$fp = fopen($file , 'r');
$frow = fgetcsv($fp );

$ccount = 0;
foreach($frow as $column) {
# Jaime: Patch for column name containing reserved word in mysql
if (strcasecmp($column, "Update") == 0) {
    $column = "Updated";
}    
if (strcasecmp($column, "Order") == 0) {
    $column = "Ordered";
}
if (strcasecmp($column, "Set") == 0) {
    $column = "Set_";
}


  $ccount++;
    if($columns) $columns .= ', ';
    $columns .= "$column varchar(250)";

}
$create = "create table if not exists $table ($columns) ENGINE=MyISAM DEFAULT CHARSET=utf8; ";
mysql_query($create, $db);

echo $create,"\n"  ;


/********************************************************************************/
// Import the data into the newly created table.

$file = $_SERVER['PWD'].'/'.$file;
$q = "LOAD DATA LOCAL INFILE '$file' into table $table FIELDS TERMINATED BY ',' LINES TERMINATED BY '\r\n' IGNORE 1 LINES ;" ; 
//$q = "load data infile '$file' into table $table fields terminated by ',' ignore 1 lines";
echo $q,"\n" ;
mysql_query($q, $db);

/* Jaime FIX to add those file non generated from windows SO, containing another end of line characters */

$resultado = mysql_query("SELECT * FROM $table", $db);
$numero_filas = mysql_num_rows($resultado);

echo "$numero_filas Filas\n";
if ($numero_filas == 0) {
$q = "LOAD DATA LOCAL INFILE '$file' into table $table FIELDS TERMINATED BY ',' IGNORE 1 LINES ;" ;
echo $q,"\n" ;
mysql_query($q, $db) ;

$resultado = mysql_query("SELECT * FROM $table", $db);
$numero_filas = mysql_num_rows($resultado);
echo "$numero_filas rows\n";

} 





?>

