#! /bin/bash

export ZLEVEL=17
export EPSG4326="+proj=longlat +datum=WGS84 +no_defs"
export EPSG3857="+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs"

export TARGET_EXTENT="104.733 15.8764 106.798 17.1136" # Savannakhet
iojs ../get.BingAerial.js $TARGET_EXTENT 13 | awk 'BEGIN{FS=","}{print $1}' | parallel --jobs 5 ./prepareMosaicForShao.sub.sh :::

exit 0
