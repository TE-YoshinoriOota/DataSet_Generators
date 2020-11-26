#!/bin/bash
DIRS=(0 1 2 3 4 5 6 7 8 9 a)
for dir in ${DIRS[@]}
do
  cd $dir
  echo "enter $dir"
  FILES=`ls *.png`
  for file in ${FILES[@]}
  do
    magick $file +noise Gaussian tmp.png
    magick $file tmp.png -compose lighten -composite 20$file
    rm tmp.png
    echo "magick $file +noise Gaussian 20$file"
  done
  cd ..
  echo "exit $dir"
done
