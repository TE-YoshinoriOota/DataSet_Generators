#!/bin/bash
if [ $# -ne 1 ]; then
  echo "mkbmp_1_28_28_256.bash  [dir]"
  exit 0
fi
ROOT=$1
mkdir training
cd $ROOT
DIRS=`ls`
for dir in ${DIRS[@]}
do
  cd $dir
  echo "enter $dir"
  FILES=`ls`
  for file in ${FILES[@]}
  do 
    echo "mkdir $dir in training"
    mkdir ../../training/$dir
    echo "resizing $file"
    magic $file -resize 28x28^ tmp.png
    magic tmp.png -gravity center -crop 28x28+0+0 tmp.png
    echo "monorizing $file"
    FILENAME=`echo $file | se 's/\.[^\.]*$//'`
    magic tmp.png -depth 8 -alpha off -compress NONE -colors 256 BMP3:tmp.bmp
    mv tmp.mbp ../../training/$dir/$FILENAME.bmp
  done
done

  
