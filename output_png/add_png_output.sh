# add_png_output.sh
# First developed to add png output setting into parsed pipeline for Christine Minnar (CM pipeline) R3


# Get current system datetime as first line to initiate the Modify_log.txt
curentdate=`date '+%d/%m/%Y_%H:%M:%S'`
echo $curentdate > Modify_log.txt


# Loop through R scripts in curernt directory
for FILE in *.R 
do
  
  # The parsed scripts always have "template_function_" in filename
  if [[ $FILE == *"template_function_"* ]]; 
  then
  
    # The png output code used in CM pipeline is png(), hence without the "png(", the core does not have png output arguement
    if grep -q "png(" $FILE;
    then
    
      # echo ""
    else
      
      # First record the name of modified file
      echo $FILE >> Modify_log.txt
      
      # Process the filename to get the image name
      var2=${FILE%.*}
      var3=${var2:18}
      var3+=".png"
      
      # insert three lines into targeted scripts with default image setting and output image name
      sed  -i '2i image_width = 2500; image_height = 2500; image_resolution = 300' $FILE
      sed  -i '3i current_png_output_name = "'"$var3"'"' $FILE
      sed  -i '4i png(filename=current_png_output_name, width=image_width, height=image_height, units="px", pointsize=4, bg="white", res=image_resolution, type="cairo") ' $FILE
    fi
  fi
done