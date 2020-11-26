#!/bin/bash
DIRS=(0 1 2 3 4 5 6 7 8 9 a)
for dir in ${DIRS[@]}
do
  cd $dir
  echo "enter $dir"
  FILES=`ls *.png`
  for file in ${FILES[@]}
  do
    magick $file -resize 28x28!  $file
    echo "magick $file -resize 28x28!  $file"
  done
  cd ..
  echo "exit $dir"
done
