#!/bin/bash
cd WORK
echo `pwd`
DIRS=(lion Tiger Jager Kitty Office)
for dir in ${DIRS[@]}
do
  cd $dir
  echo "enter $dir"
  FILES=`ls`
  for file in ${FILES[@]}
  do
    FILENAME=`echo $file | sed 's/\.[^\.]*$//'`
    echo "magick $FILENAME.jpg -type GrayScale -colors 256 -depth 8  BMP3:../../Result/$dir/$FILENAME.bmp"
    magick $FILENAME.jpg -type GrayScale -colors 256 -depth 8 -colorspace Gray -compress none BMP3:../../Result/$dir/$FILENAME.bmp
  done
  cd ..
  echo "exit $dir"
done
