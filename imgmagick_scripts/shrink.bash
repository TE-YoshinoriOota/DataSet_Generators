#!/bin/bash
DIRS=(0 1 2 3 4 5 6 7 8 9 a)
for dir in ${DIRS[@]}
do
  cd $dir
  echo "enter $dir"
  FILES=`ls *.png`
  for file in ${FILES[@]}
  do
    RANDNUM=$((RANDOM % 10))
    ROT=`echo "5 - $RANDNUM" | bc`
    magick $file -resize 25x25! tmp.png
    magick $file tmp.png -gravity center -compose over -composite 40$file
    echo "magick $file -resize 25x25 40$file"
  done
  rm tmp.png
  cd ..
  echo "exit $dir"
done
