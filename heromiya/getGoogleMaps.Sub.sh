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

TILE_XYMIN=(`echo $TILE_LONMIN $TILE_LATMIN | proj $EPSG3857`)
export TILE_XMIN=${TILE_XYMIN[0]}
export TILE_YMIN=${TILE_XYMIN[1]}

TILE_XYMAX=(`echo $TILE_LONMAX $TILE_LATMAX | proj $EPSG3857`)
export TILE_XMAX=${TILE_XYMAX[0]}
export TILE_YMAX=${TILE_XYMAX[1]}

PNG=GMap/png/${ZLEVEL}/${TILEX}/Z${ZLEVEL}.${TILEX}.${TILEY}.png
GTIFF=GMap/gtiff/${ZLEVEL}/${TILEX}/Z${ZLEVEL}.${TILEX}.${TILEY}.tif

if [ -e $PNG ]; then
    if [ ! -s $PNG ]; then
	rm -f  $PNG
    fi
fi
if [ ! -e $GTIFF ]; then
    if [ -e $PNG ]; then

	if [ $(stat --printf="%s" $PNG) -gt 353 ]; then
	    make -s $GTIFF
	else
	    grep "invalid bbox" $PNG
	    if [ $? -eq 0 ]; then
		rm -f $PNG
		make $GTIFF
	    fi
	fi
    else
	make -s $GTIFF
    fi
fi
:<<'#EOF'
if [ ! -e $GTIFF ]; then
    if [ ! -s $PNG ]; then
	rm -f $PNG
    fi
    if [ -e $PNG ]; then
	if [ $(stat --printf="%s" $PNG) -gt 353 ]; then
	    make $GTIFF
	fi
    else
	    make $GTIFF
    fi
fi
#EOF

exit 0
