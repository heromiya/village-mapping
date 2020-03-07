#! /bin/bash

LON=`echo $1 | cut -d "|" -f 1`
LAT=`echo $1 | cut -d "|" -f 2`
nodejs -e "var tilebelt = require('tilebelt'); XY = tilebelt.pointToTile($LON, $LAT, $ZLEVEL); console.log(XY[0]+'|'+XY[1]);" >> $TILELIST

exit 0
