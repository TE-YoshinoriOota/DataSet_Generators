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
    magick $file -resize 34x34 tmp.png
    magick tmp.png -rotate $ROT -background black tmp.png
    magick tmp.png -gravity center -crop 28x28+0+0 30$file
    echo "magick $file -rotate $ROT 30$file"
  done
  cd ..
  echo "exit $dir"
done
