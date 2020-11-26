TARGET=nan
cd ..
cd org
cd $TARGET

FILES=`ls`
for file in ${FILES[@]}
do
  FILENAME=`echo $file | sed 's/\.[^\.]*$//'`
  echo "magick $file ../../dataset/$TARGET/$FILENAME.png"
  magick $file ../../dataset/$TARGET/$FILENAME.png
done
