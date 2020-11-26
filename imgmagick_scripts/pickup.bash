#!/bin/bash
DIRS=(0 1 2 3 4 5 6 7 8 9 a)
for dir in ${DIRS[@]}
do
  cd $dir
  echo "enter $dir"
  VAR=0
  ZERO=0
  FILES=`ls *.png`
  for file in ${FILES[@]}
  do
    VAR=$(($VAR + 1))
    PICK=$(($VAR % 5))
    if [ $PICK -eq 0 ]; then
       echo "move $file to ../../validation/$dir"
       mv $file ../../validation/$dir
    fi
  done
  cd ..
  echo "exit $dir"
done
