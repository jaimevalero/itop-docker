# Add date columns to a csv file, passed as argument.
# Calculate Date
DATE=` date +'%Y-%m-%d'`
MY_FILE="$1"
NUM_LINES=`cat $MY_FILE | wc -l`

# Header 
echo ",DATE" > $MY_FILE.tmp

# Body
for COUNT in ` seq 2 $NUM_LINES `
do
 echo ",$DATE" >> $MY_FILE.tmp
done

# Merge
paste $MY_FILE $MY_FILE.tmp > $MY_FILE.tmp2
mv $MY_FILE.tmp2 $MY_FILE
rm -f $MY_FILE.tmp

