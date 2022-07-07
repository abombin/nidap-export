# add_png_output.sh
# First developed to find if png output setting is available in parsed pipelines for Christine Minnar (CM pipeline) R3


# Get current system datetime as first line to initiate the Find_results.txt
curentdate=`date '+%d/%m/%Y_%H:%M:%S'`
echo $curentdate > Find_results.txt

# Loop throuhg R scripts
for FILE in *.R 
do

  # The parsed scripts always have "template_function_" in filename
  if [[ $FILE == *"template_function_"* ]]; 
  then
  
    # The png output code used in CM pipeline is png(), hence without the "png(", the core does not have png output arguement
    if grep -q "png(" $FILE;
    then
    
      # record findings
      echo $FILE >> Find_results.txt
      echo grep -n "png(" $FILE >> Find_results.txt
      # grep -n "filename" $FILE >> Find_results.txt
    fi
  fi
done

