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
    echo "magick $file -gravity center -crop 28x28+0+0 $file"
    magick $file -gravity center -crop 28x28+0+0 $file
  done
  cd ..
  echo "exit $dir"
done
