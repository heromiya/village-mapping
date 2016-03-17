#! /bin/bash

export Z13QKEY=$1
export MOSAIC=dataForShao/Z${ZLEVEL}/a${Z13QKEY}-Z${ZLEVEL}.tif
if [ ! -e $MOSAIC ]; then
export MOSAIC_INPUTS="`find ../Bing/gtiff/17 | grep a$Z13QKEY | awk 'BEGIN{ORS=" "}{print}'`"
make $MOSAIC
fi

exit 0
