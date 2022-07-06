curentdate=`date '+%d/%m/%Y_%H:%M:%S'`
echo $curentdate > Find_results.txt

for FILE in *.R 
do
  if [[ $FILE == *"template_function_"* ]]; 
  then
    if grep -q "png(" $FILE;
    then
      echo $FILE >> Find_results.txt
      # grep -n "filename" $FILE >> Find_results.txt
    fi
  fi
done

