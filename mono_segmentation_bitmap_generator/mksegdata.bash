#!/bin/sh
#
# This bash sript is made for making a set of training images for 
# Sony Neural Network Console (https://dl.sony.com)
# To use this script, type a command like below in a bash console
#
# % bash gensegbmp.bash -s [size] -b [background] -t [train_data] -v [valid_data]
#
#   size       : specify the size of the output sauared BMP image
#   background : specify the background image
#   train_data : specify the number of generated training data
#   valid_data : specify the number of generated validation data
#
#
#   gensegbmp.bash --+--/images : contains target images to be recognized
#                    +--/masks  : contains mask images of target images
#                    +--<background image> : must be 1920x1080
#                    +--/train-+-/input    : input data for training
#                    |         +-/output   : output data for training 
#                    |         +-train.csv : csv data
#                    +--/valid-+-/input    : input data for validation
#                              +-/output   : output data for validation
#                              +-valid.csv : csv data
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
if [ $# -ne 8 ]; then
  echo "gensegdata.bash  -s [size] -b [dir] -t [train_data] -v [valid_data]"
  echo " -s: size: specify the size of the output squared BMP image" 
  echo " -b: background image: specify the background image"
  echo " -t: specify the number of generated training data"
  echo " -v: specify the number of generated validation data"
  exit 0
fi

while getopts s:b:t:v: OPT
do
  case $OPT in
    "s" ) FLG_S="TRUE" ; SIZE="$OPTARG" ;;
    "b" ) FLG_B="TRUE" ; BGIM="$OPTARG" ;;
    "t" ) FLG_B="TRUE" ; NUM_OF_TRAIN="$OPTARG" ;;
    "v" ) FLG_B="TRUE" ; NUM_OF_VALID="$OPTARG" ;;
  esac
done

#
# making the images for a data-set of segmentation
#

# set directories
if [ ! -e ./train ]; then
  echo "make the train directory"
  mkdir train
fi

if [ ! -e ./valid ]; then
  echo "make the valid directory"
  mkdir valid
fi

echo "check the images directory"
if [ -e ./images ]; then
  cd ./images
  NUMF=`ls -1 | wc -l`
  if [ $NUMF -eq 0 ]; then
    echo "./images should contain images"
    exit 0
  else
    echo "ok"
    cd ..
  fi
else
  echo "the images directory must be set"
  exit 0
fi

echo "check the masks directory"
if [ -e ./masks ]; then
  cd ./masks
  if [ -e black.png ]; then
    echo "black.png ok"
  else
    echo "./masks must have black.png"
    exit 0
  fi
  NUMF=`ls -1 | wc -l`
  if [ $NUMF -lt 2 ]; then
    echo "./masks must contain images"
    exit 0
  else
    echo "ok"
    cd ..
  fi
else
  echo "the masks directory must be set"
  exit 0
fi

# setup the train directory
echo "cd to the train directory"
cd train
if [ ! -e ./input ]; then
  echo "make the input directory"
  mkdir input
fi
if [ ! -e ./output ]; then
  echo "make the out directory"
  mkdir output
fi
cd ..

# setup the valid directory
echo "cd the valid directory"
cd valid
if [ ! -e ./input ]; then
  echo "make the in directory"
  mkdir input
fi
if [ ! -e ./output ]; then
  echo "make the out directory"
  mkdir output
fi
cd ..

# countup the image files
NUM_OF_TARGET=`ls -1 images | wc -l`

mk_segmentation_data () {
  # mv target dir
  echo "enter $1"
  cd $1

  # mk csv file
  CSVFILE=$1.csv
  if [ -f $CSVFILE ]; then
    rm $CSVFILE
  fi
  echo "write \"x:in,y:out\" to $CSVFILE" 
  echo "x:in,y:out" >> $CSVFILE


  # make data for training
  for ((i = 0; i < $2; +++i))
  do
    echo "---[$i]---"

    # make a background image
    xSIZE=x$SIZE
    RANDX=$((RANDOM % (1920 - $SIZE)))
    RANDY=$((RANDOM % (1080 - $SIZE)))
    echo "cropping the image for a background image"
    echo "magick ../$BGIM -crop $SIZE$xSIZE+$RANDX+$RANDY ./input/$i.bmp"
    magick ../$BGIM -crop $SIZE$xSIZE+$RANDX+$RANDY ./input/$i.bmp

    # make the target image and the mask image
    TARGET=$((RANDOM % $NUM_OF_TARGET))
    declare -i RANDC
    RANDC=$((RANDOM % $SIZE))
    if [ $RANDC -lt $(($SIZE / 2)) ]; then
      RANDC=$(($SIZE / 2))
    fi
    xRANDC=x$RANDC
    echo "resizing the ball image"
    echo "magick ../images/$TARGET.png -resize $RANDC$xRANDC tmp.png"
    magick ../images/$TARGET.png -resize $RANDC$xRANDC tmp.png
    echo "magick ../images/$TARGET.png -resize $RANDC$xRANDC tmp.png"
    magick ../masks/$TARGET.png -resize $RANDC$xRANDC det.png

    # composite images
    RAND_X=$((RANDOM % $SIZE))
    RAND_Y=$((RANDOM % $SIZE))
    LIMIT=$(($SIZE - $RANDC))
    if [ $RAND_X -gt $LIMIT ]; then
      RAND_X=$LIMIT
    fi
    if [ $RAND_Y -gt $LIMIT ]; then
      RAND_Y=$LIMIT
    fi
    # composite images
    echo "compositing images"
    echo "magick composite -geometry +$RAND_X+$RAND_Y tmp.png ./input/$i.bmp ./input/$i.bmp"
    magick composite -geometry +$RAND_X+$RAND_Y tmp.png ./input/$i.bmp ./input/$i.bmp
    echo "magick composite -geometry +$RAND_X+$RAND_Y det.png ../masks/black.png ./output/$i.bmp"
    magick composite -geometry +$RAND_X+$RAND_Y det.png ../masks/black.png ./output/$i.bmp

    # monorize images
    echo "converting the image into grayscale"
    magick ./input/$i.bmp  -colorspace  Gray -depth 8 -colors 256 -compress NONE BMP3:./input/$i.bmp
    magick ./output/$i.bmp -colorspace  Gray -depth 8 -colors 256 -compress NONE BMP3:./output/$i.bmp

    # update csv file
    echo "./input/$i.bmp,./output/$i.bmp" >> $CSVFILE

    # separator
    echo " "

  done
  rm tmp.png det.png
  cd ..
}

# generate train data
mk_segmentation_data train $NUM_OF_TRAIN

# generate valid data
mk_segmentation_data valid $NUM_OF_VALID

