#! /bin/bash

mkdir -p sampleImages
mkdir -p sampleImagesVRT
export ZLEVEL=18
export EPSG4326="+proj=longlat +datum=WGS84 +no_defs"
export EPSG3857="+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs"
export WIDTH=256
export HEIGHT=256

psql suvannaket -tc "SELECT qkey from grid where validate = 1 or validate = 2;" | sort > completedSamples.lst
cat completedSamples.lst | xargs parallel --joblog log/extractImages.sub.sh.$$ "./extractImages.sub.sh" ::: 

#for QKEY in `cat completedSamples.lst`; do
#done

exit 0
