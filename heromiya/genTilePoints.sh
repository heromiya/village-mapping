#! /bin/bash

DB=/media/HDD3/tilePoint.sqlite
export SQL=/dev/shm/tilePoint.insert.sql
export ZLEVEL=17
LONMIN=30.2
LONMAX=41.0
LATMIN=-26.9
LATMAX=-10.4


XYMIN=($(echo "var tilebelt = require('tilebelt'); console.log(tilebelt.pointToTile($LONMIN, $LATMAX, $ZLEVEL));" | nodejs | tr -d '[],'))
XYMAX=($(echo "var tilebelt = require('tilebelt'); console.log(tilebelt.pointToTile($LONMAX, $LATMIN, $ZLEVEL));" | nodejs | tr -d '[],'))

echo "CREATE TABLE tilepoint_z17 (x interger, y integer); SELECT AddGeometryColumn('tilepoint_z17','geom',4326,'POINT','XY');" > $SQL

function tileCenter() {
    X=$1
    Y=$2
    CENTER=($(echo "var tilebelt = require('tilebelt'); bbox = tilebelt.tileToBBOX(["$X", "$Y", "$ZLEVEL"]); console.log((bbox[0]+bbox[2])/2, (bbox[1]+bbox[3])/2)" | nodejs))
    echo "INSERT INTO tilepoint_z17 (x, y, geom) VALUES ("$X","$Y",MakePoint("${CENTER[0]}","${CENTER[1]}",4326));" >> $SQL
}
export -f tileCenter

parallel --nice 10 --progress tileCenter {1} {2} ::: $(seq ${XYMIN[0]} ${XYMAX[0]}) ::: $(seq ${XYMIN[1]} ${XYMAX[1]})
#parallel --nice 10 --progress tileCenter {1} {2} ::: $(seq ${XYMIN[0]} $(expr ${XYMIN[0]} + 10)) ::: $(seq ${XYMIN[1]} $(expr ${XYMIN[1]} + 10))

rm -f $DB
spatialite $DB < $SQL

exit 0
