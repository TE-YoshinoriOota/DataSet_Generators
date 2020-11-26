#!/bin/sh
COUNT=0
echo "Ready for making training data"
for ((i = 0; i < 1500; ++i))
do
  RANDNUM=$((RANDOM % 5841))
  RANDSCR=$((RANDOM % 1591))
  echo "making training data for 4: ./training/4/$i.png "
  magick composite -gravity center -compose over ./Images_for_training/4/trans/$RANDNUM.png ./Images_for_background/$RANDSCR.png ./training/4/$i.png
  magick composite -gravity center -compose over ./Images_for_training/4/trans/$RANDNUM.png ./Images_for_background/$RANDSCR.png ./training/4/$i.png
  RANDNUM=$((RANDOM % 5948))
  RANDSCR=$((RANDOM % 1591))
  echo "making training data for 4: ./training/9/$i.png "
  magick composite -gravity center -compose over ./Images_for_training/9/trans/$RANDNUM.png ./Images_for_background/$RANDSCR.png ./training/9/$i.png
  magick composite -gravity center -compose over ./Images_for_training/9/trans/$RANDNUM.png ./Images_for_background/$RANDSCR.png ./training/9/$i.png
  echo "copy training data of background: ./training/nan/$i.png "
  RANDSCR=$((RANDOM % 1591))
  cp ./Images_for_background/$RANDSCR.png ./training/nan/$i.png
done
COUNT=0
echo "Ready for making validation data"
for ((i = 0; i < 500; ++i))
do
  RANDNUM=$((RANDOM % 981))
  RANDSCR=$((RANDOM % 1591))
  echo "making validation data for 4: ./validation/4/$i.png "
  magick composite -gravity center -compose over ./Images_for_validation/4/trans/$RANDNUM.png ./Images_for_background/$RANDSCR.png ./validation/4/$i.png
  magick composite -gravity center -compose over ./Images_for_validation/4/trans/$RANDNUM.png ./Images_for_background/$RANDSCR.png ./validation/4/$i.png
  RANDNUM=$((RANDOM % 1008))
  RANDSCR=$((RANDOM % 1591))
  echo "making validation data for 4: ./validation/9/$i.png "
  magick composite -gravity center -compose over ./Images_for_validation/9/trans/$RANDNUM.png ./Images_for_background/$RANDSCR.png ./validation/9/$i.png
  magick composite -gravity center -compose over ./Images_for_validation/9/trans/$RANDNUM.png ./Images_for_background/$RANDSCR.png ./validation/9/$i.png
  echo "copy validation data of background: ./validation/nan/$i.png "
  RANDSCR=$((RANDOM % 1591))
  cp ./Images_for_background/$RANDSCR.png ./validation/nan/$i.png
done


