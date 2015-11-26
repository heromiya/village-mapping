#! /bin/bash

mkdir -p sampleImages
mkdir -p sampleImagesVRT
export ZLEVEL=19
export EPSG4326="+proj=longlat +datum=WGS84 +no_defs"
export EPSG3857="+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs"

cat completedSamples.lst | xargs parallel --joblog log/extractImages.sub.sh.$$ --jobs 10% "./extractImages.sub.sh" ::: 

#for QKEY in `cat completedSamples.lst`; do
#done

exit 0
