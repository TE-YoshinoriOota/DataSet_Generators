#!/bin/bash
#
# This bash sript is made for making a set of training images for 
# Sony Neural Network Console (https://dl.sony.com)
# To use this script, type a command like below in a bash console
#
# % bash genmonobmp.bash -s [size] -d [dir] -r [deg]
#
#   size: specify the size of the output squared BMP image 
#   dir : specify the directory having corrected images
#   deg : specify the maximum degree of generated rotation images
#
#
# Note: This license has also been called the "Simplified BSD License" 
# and the "FreeBSD License". See also the 3-clause BSD License.
#
# Copyright 2020 Yoshinori Oota
#
# Redistribution and use in source and binary forms, with or without modification, 
# are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, 
#    this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice, 
#    this list of conditions and the following disclaimer in the documentation 
#    and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS 
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, 
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
# SUBSTITUTE GOODS OR SERVICES; 
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED 
# AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


#
# processing arguments
#
if [ $# -ne 6 ]; then
  echo "genmonobmp.bash  -s [size] -d [dir] -r [deg]"
  echo " -s: size: specify the size of the output squared BMP image" 
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
    xSIZE=x$SIZE
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

