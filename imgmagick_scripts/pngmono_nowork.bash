#!/bin/bash
DIRS=(0 1 2 3 4 5 6 7 8 9 a)
for dir in ${DIRS[@]}
do
  cd $dir
  echo "enter $dir"
  FILES=`ls *.png`
  for file in ${FILES[@]}
  do
    magick $file -colorspace Gray -define png:color-type=0 $file
    echo "magick $file -define png:color-type=0 $file"
  done
  rm tmp.png
  cd ..
  echo "exit $dir"
done
