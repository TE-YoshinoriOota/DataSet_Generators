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
    RX=$((RANDOM % 3))
    RY=$((RANDOM % 3))
    magick $file -affine '2,2 $RX,$RY' 20$file
    echo "magick $file -affine '2,2 $RX,$RY' 20$file"
  done
  cd ..
  echo "exit $dir"
done
