#! /bin/bash

ARGS=$1
export EPSG4326="+proj=longlat +datum=WGS84 +no_defs"
export EPSG3857="+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs"
QKEY=`echo $ARGS | cut -d ',' -f 1`
TLATMIN=`echo $ARGS |cut -d ',' -f 2`
TLONMIN=`echo $ARGS |cut -d ',' -f 3`
TLATMAX=`echo $ARGS |cut -d ',' -f 4`
TLONMAX=`echo $ARGS |cut -d ',' -f 5`
XMIN=`echo $TLATMIN $TLONMIN | cs2cs $EPSG4326 +to $EPSG3857 | awk '{print $1}'`
YMIN=`echo $TLATMIN $TLONMIN | cs2cs $EPSG4326 +to $EPSG3857 | awk '{print $2}'`
XMAX=`echo $TLATMAX $TLONMAX | cs2cs $EPSG4326 +to $EPSG3857 | awk '{print $1}'`
YMAX=`echo $TLATMAX $TLONMAX | cs2cs $EPSG4326 +to $EPSG3857 | awk '{print $2}'`
export QKEY XMIN YMIN XMAX YMAX
make Bing/gtiff/${ZLEVEL}/a${QKEY}.tif

exit 0
