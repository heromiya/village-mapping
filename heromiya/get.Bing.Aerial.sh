#! /bin/bash

#LONMIN=104.733
#LATMIN=15.8764
#var LONMAX=106.798;
#var LATMAX=17.1136;
#LONMAX=104.74
#LATMAX=15.88
export ZLEVEL=18

export EPSG4326="+proj=longlat +datum=WGS84 +no_defs"
export EPSG3857="+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs"

for ROI in `cat ROI.lst`; do
    LONMIN=`echo $ROI | cut -d '|' -f 2`
    LATMIN=`echo $ROI | cut -d '|' -f 3`
    LONMAX=`echo $ROI | cut -d '|' -f 4`
    LATMAX=`echo $ROI | cut -d '|' -f 5`
    iojs get.BingAerial.js $LONMIN $LATMIN $LONMAX $LATMAX $ZLEVEL > args.lst
    cat args.lst | xargs parallel --joblog log.txt --jobs 10% "./get.Bing.Aerial.Sub.sh" ::: 
done

cd Bing/gtiff
#gdalbuildvrt Z$ZLEVEL.vrt $ZLEVEL/a*.tif
