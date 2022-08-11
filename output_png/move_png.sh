
# Check ig png_outputs folder exists
if [[ -d png_outputs ]];
then

  # Move png files into the folder
  mv *.png png_outputs
else

  # Create the folde and then move the files
  mkdir png_outputs
  mv *.png png_outputs
fi