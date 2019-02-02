#! /bin/bash

export GADM_GID=$1
export ZLEVEL=$2
export WORKDIR=/dev/shm/tmp.$GADM_GID.$ZLEVEL
export SQL=/dev/shm/tilePoint.insert.$GADM_GID.$ZLEVEL.sql

DB=/mnt/lv0/building_detection_outputs/tilePoints/tilePoint.$GADM_GID.Z$ZLEVEL.sqlite

EXTENT=($(psql -h guam -d suvannaket -F " " -qAtc "SELECT ST_XMin(wkb_geometry), ST_XMax(wkb_geometry), ST_YMin(wkb_geometry), ST_YMax(wkb_geometry) FROM gadm36_level1 WHERE gid_1 = '$GADM_GID';"))

XYMIN=($(echo "var tilebelt = require('tilebelt'); console.log(tilebelt.pointToTile(${EXTENT[0]}, ${EXTENT[3]}, $ZLEVEL));" | nodejs | tr -d '[],'))
XYMAX=($(echo "var tilebelt = require('tilebelt'); console.log(tilebelt.pointToTile(${EXTENT[1]}, ${EXTENT[2]}, $ZLEVEL));" | nodejs | tr -d '[],'))

echo "CREATE TABLE tilepoint (x interger, y integer); SELECT AddGeometryColumn('tilepoint','geom',4326,'POINT','XY');" > $SQL

function tileCenter() {
    X=$1
    Y=$2
    if [ ! -e  $WORKDIR/$X.$Y.sql ]; then
	CENTER=($(echo "var tilebelt = require('tilebelt'); bbox = tilebelt.tileToBBOX(["$X", "$Y", "$ZLEVEL"]); console.log((bbox[0]+bbox[2])/2, (bbox[1]+bbox[3])/2)" | nodejs))
	echo "INSERT INTO tilepoint (x, y, geom) VALUES ("$X","$Y",MakePoint("${CENTER[0]}","${CENTER[1]}",4326));" > $WORKDIR/$X.$Y.sql
    fi
}
export -f tileCenter

parallel -j0 --nice 10 --progress tileCenter {1} {2} ::: $(seq ${XYMIN[0]} ${XYMAX[0]}) ::: $(seq ${XYMIN[1]} ${XYMAX[1]})
cat $WORKDIR/*.sql >> $SQL

rm -f $DB
spatialite $DB < $SQL

exit 0
