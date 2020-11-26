#!/bin/bash
DIRS=(0 1 2 3 4 5 6 7 8 9 a)
for dir in ${DIRS[@]}
do
  cd $dir
  echo "enter $dir"
  FILES=`ls *.png`
  for file in ${FILES[@]}
  do
    echo $file
    RANDNUM=$((RANDOM % 3))
    POINT=`echo "scale=2; $RANDNUM / 10.0" | bc`
    GAMMA=`echo "scale=1; 1.0 - $POINT" | bc`
    magick $file -gamma $GAMMA  20$file
    echo "magick $file -gamma $GAMMA  20$file"
  done
  cd ..
  echo "exit $dir"
done
