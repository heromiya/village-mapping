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

#ssh -p 20022  heromiya@hawaii.csis.u-tokyo.ac.jp "test -e /mnt/lv0/GMap/png/${ZLEVEL}/${TILEX}/Z${ZLEVEL}.${TILEX}.${TILEY}.png"
#if [ $? -eq 1 ]; then
PNG=GMap/png/${ZLEVEL}/${TILEX}/Z${ZLEVEL}.${TILEX}.${TILEY}.png
GTIFF=GMap/gtiff/${ZLEVEL}/${TILEX}/Z${ZLEVEL}.${TILEX}.${TILEY}.tif
if [ ! -e $GTIFF ]; then
    if [ ! -s $PNG ]; then
	rm -f $PNG
    fi
    if [ -e $PNG ]; then
	if [ ! $(stat --printf="%s" $PNG) -eq 353 ]; then
	    make $GTIFF
	fi
    else
	    make $GTIFF
    fi
fi

exit 

    #rsync -e "ssh -p 20022 heromiya@hawaii.csis.u-tokyo.ac.jp" -avz GMap/gtiff/${ZLEVEL}/${TILEX}/Z${ZLEVEL}.${TILEX}.${TILEY}.tif heromiya@hawaii.csis.u-tokyo.ac.jp:/mnt/lv0/GMap/gtiff/${ZLEVEL}/${TILEX}/Z${ZLEVEL}.${TILEX}.${TILEY}.tif
    #rsync -e "ssh -p 20022 heromiya@hawaii.csis.u-tokyo.ac.jp" -avz GMap/png/${ZLEVEL}/${TILEX}/Z${ZLEVEL}.${TILEX}.${TILEY}.png heromiya@hawaii.csis.u-tokyo.ac.jp:/mnt/lv0/GMap/png/${ZLEVEL}/${TILEX}/Z${ZLEVEL}.${TILEX}.${TILEY}.png
