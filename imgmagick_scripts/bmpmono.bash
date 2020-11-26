#!/bin/bash
DIRS=(0 1 2 3 4 5 6 7 8 9 a)
for dir in ${DIRS[@]}
do
  cd $dir
  echo "enter $dir"
  FILES=`ls *.png`
  for file in ${FILES[@]}
  do
    FILENAME=`echo $file | sed 's/\.[^\.]*$//'`
    #magick $FILENAME.png -type GrayScale -colors 256 ../../work/$dir/$FILENAME.bmp
    magick $FILENAME.png -depth 8 -alpha off -compress NONE -colors 256 BMP3:../../work/$dir/$FILENAME.bmp
    echo "magick $FILENAME.png -type GrayScale -colorspace Gray ../../work/$dir/$FILENAME.bmp"
  done
  rm tmp.png
  cd ..
  echo "exit $dir"
done
