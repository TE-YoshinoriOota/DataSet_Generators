#!/bin/bash
#
# This bash sript is made for making a set of training images for 
# Sony Neural Network Console (https://dl.sony.com)
# To use this script, type a command like below in a bash console
#
# % bash mkmonobmp.bash -s [size] -d [dir] -r [deg]
#
#   size: specify the size of a squared BMP image 
#   dir : specify the directory having corrected images
#   deg : specify the maximum degree of generated rotation images
#
#                                   Copyright 2020 Yoshinori Oota
#


#
# processing arguments
#
if [ $# -ne 6 ]; then
  echo "mkmonobmp.bash  -s [size] -d [dir] -r [deg]"
  echo " -s: size: specify the size of a squared BMP image" 
  echo " -d: dir : specify the directory having corrected images"
  echo " -r: deg : specify the maximum degree of generated rotation images"
  exit 0
fi

while getopts s:d:r:o: OPT
do
  case $OPT in
    "s" ) FLG_S="TRUE" ; SIZE="$OPTARG" ;;
    "d" ) FLG_D="TRUE" ; ROOT="$OPTARG" ;;
    "r" ) FLG_R="TRUE" ; SROT="$OPTARG" ;;
  esac
done


#
# making the images for a data-set
#

# mkdir for the processed images
xSIZE=x$SIZE
mkdir -p training
mkdir -p validation

# move to the root of the corrected image
cd $ROOT
echo "enter $ROOT"

# list up the directories in the root directory
DIRS=`ls -d */`
for dir in ${DIRS[@]}
do
  # enter each directory
  echo "enter $dir"
  cd $dir

  # mkdir the correspoing dir in the training folder
  echo "mkdir $dir in training"
  TRAINDIR=../../training/$dir
  mkdir -p $TRAINDIR

  FILES=`ls`
  for file in ${FILES[@]}
  do
    # set parameters
    TMP=../../tmp.bmp
    FILENAME=`echo $file | sed 's/\.[^\.]*$//'`

    # resize the image
    echo "resizing $file"
    magick $file -resize $SIZE$xSIZE^ $TMP
    magick $TMP -gravity center -crop $SIZE$xSIZE+0+0 $TMP

    # monorize the image
    echo "monorizing $file"
    magick $TMP -type GrayScale BMP3:$TMP
    magick $TMP -depth 8 -alpha off -compress NONE -colors 256 BMP3:$TRAINDIR/$FILENAME.bmp

    # add noise to the image
    echo "generating noised $file"
    magick $TRAINDIR/$FILENAME.bmp +noise Gaussian $TMP
    magick $TMP -depth 8 -alpha off -compress NONE -colors 256 BMP3:$TRAINDIR/n$FILENAME.bmp

    # enlarge and rotate the image
    ENL=`echo "$SIZE*1.2" | bc`
    RANDNUM=$((RANDOM % $SROT))
    ROT=`echo "$SROT/2 - $RANDNUM" | bc`
    echo "enlarging and rotating $file at $ROT degree"
    magick $TRAINDIR/$FILENAME.bmp -resize $ENLx$ENL $TMP
    magick $TMP -rotate $ROT $TMP
    magick $TMP -gravity center -crop $SIZE$xSIZE+0+0 $TMP
    magick $TMP -depth 8 -alpha off -compress NONE -colors 256 BMP3:$TRAINDIR/r$FILENAME.bmp

    # shrink the image
    RANDNUM=$((RANDOM % $SROT))
    ROT=`echo "$SROT/2 - $RANDNUM" | bc`
    echo "shrinking and rotating $file at $ROT degree"
    SHR=`echo "$SIZE*0.9" | bc`
    xSHR=x$SHR
    magick $TRAINDIR/$FILENAME.bmp -resize $SHR$xSHR $TMP
    magick $TMP -rotate $ROT $TMP
    magick $TMP -gravity center -crop $SHR$xSHR+0+0 $TMP
    magick $TRAINDIR/$FILENAME.bmp $TMP -gravity center -compose over -composite $TMP

    # convert 24bits to 8bits 
    magick $TMP -depth 8 -alpha off -compress NONE -colors 256 BMP3:$TRAINDIR/s$FILENAME.bmp
    rm $TMP
  done
  cd ..
  echo "exit $dir"
done
cd ..


#
# picking up some processed images for validation
#
cd training
DIRS=`ls -d */`
for dir in ${DIRS[@]}
do
  # enter each directory
  echo "enter $dir"
  cd $dir

  echo "mkdir $dir in validation"
  mkdir -p ../validation/$dir

  # set up parameters
  VAR=0
  ZERO=0

  # list up the processed images
  FILES=`ls`
  for file in ${FILES[@]}
  do
    # pickup a image every 5 times
    VAR=$(($VAR + 1))
    PICK=$(($VAR % 5))
    if [ $PICK -eq 0 ]; then
       echo "move $file to validation/$dir"
       mv $file ../../validation/$dir
    fi
  done
  cd ..
  echo "exit $dir"
done
cd ..


#
# output the csv file for training
#
cd training
echo "x:image,y:label" > training.csv
VAR=0
DIRS=`ls -d */`
for dir in ${DIRS[@]}
do
  find $dir -name "*.bmp" | sed "s/bmp/bmp,$VAR/" >> training.csv
  VAR=$(($VAR + 1))
done
cd ..


#
# output the csv file for validation
#
cd validation
echo "x:image,y:label" > validation.csv
VAR=0
DIRS=`ls -d */`
for dir in ${DIRS[@]}
do
  find $dir -name "*.bmp" | sed "s/bmp/bmp,$VAR/" >> validation.csv
  VAR=$(($VAR + 1))
done

