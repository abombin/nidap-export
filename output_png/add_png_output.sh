curentdate=`date '+%d/%m/%Y_%H:%M:%S'`
echo $curentdate > Modify_log.txt

for FILE in *.R 
do
  if [[ $FILE == *"template"* ]]; 
  then
    if grep -q "png(" $FILE;
    then
      echo ""
    else
      echo $FILE >> Modify_log.txt
      var2=${FILE%.*}
      var3=${var2:18}
      var3+=".png"
      sed  -i '2i image_width = 2500; image_height = 2500; image_resolution = 300' $FILE
      sed  -i '3i current_png_output_name = "'"$var3"'"' $FILE
      sed  -i '4i png(filename=current_png_output_name, width=image_width, height=image_height, units="px", pointsize=4, bg="white", res=image_resolution, type="cairo") ' $FILE
    fi
  fi
done