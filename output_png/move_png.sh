if [[ -d png_outputs ]];
then
  mv *.png /png_outputs
else
  mkdir png_outputs
  mv *.png /png_outputs
fi