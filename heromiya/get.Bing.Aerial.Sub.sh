#! /bin/bash

ARGS=$1
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
