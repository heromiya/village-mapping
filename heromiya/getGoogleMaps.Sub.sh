#! /bin/bash

ARGS=$1
export EPSG4326="+proj=longlat +datum=WGS84 +no_defs"
export EPSG3857="+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs"
export TILEX=`echo $ARGS |cut -d ',' -f 1`
export TILEY=`echo $ARGS |cut -d ',' -f 2`
TILE_LONMIN=`echo $ARGS |cut -d ',' -f 4`
TILE_LATMIN=`echo $ARGS |cut -d ',' -f 5`
TILE_LONMAX=`echo $ARGS |cut -d ',' -f 6`
TILE_LATMAX=`echo $ARGS |cut -d ',' -f 7`
export TILE_XMIN=`echo $TILE_LONMIN $TILE_LATMIN | proj $EPSG3857 | awk '{print $1}'`
export TILE_YMIN=`echo $TILE_LONMIN $TILE_LATMIN | proj $EPSG3857 | awk '{print $2}'`
export TILE_XMAX=`echo $TILE_LONMAX $TILE_LATMAX | proj $EPSG3857 | awk '{print $1}'`
export TILE_YMAX=`echo $TILE_LONMAX $TILE_LATMAX | proj $EPSG3857 | awk '{print $2}'`

if [ ! -e GMap/gtiff/${ZLEVEL}/Z${ZLEVEL}.${TILEX}.${TILEY}.tif ]; then
    make GMap/gtiff/${ZLEVEL}/Z${ZLEVEL}.${TILEX}.${TILEY}.tif
fi

exit 
