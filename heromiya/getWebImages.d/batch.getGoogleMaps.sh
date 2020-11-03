#! /bin/bash

export WORKDIR=$(mktemp -d)
export LAYER_NAME=GoogleMapsSatellite200712
export ZLEVEL=19

mkdir -p /mnt/lv0/GMap/$LAYER_NAME/$ZLEVEL

bash getGoogleMaps.sh 34.7 35.2 -19.9 -19.6 $ZLEVEL $LAYER_NAME
bash getGoogleMaps.sh 32.4 32.7 -26.1 -25.7 $ZLEVEL $LAYER_NAME
bash getGoogleMaps.sh 34.7 35.2 -19.9 -19.6 $ZLEVEL $LAYER_NAME

r2p(){
    raster2pgsql -s 3857 -a -R -F -e $1 ${LAYER_NAME}_z$ZLEVEL > $WORKDIR/$(basename $1).sql
}
export -f r2p

#:<<"#EOF"

find /mnt/lv0/GMap/$LAYER_NAME/$ZLEVEL/ -type f -regex ".*\.tif$" > $WORKDIR/tifs.lst
parallel --nice 10 --progress r2p {} :::: $WORKDIR/tifs.lst

echo "DROP VIEW IF EXISTS u_${LAYER_NAME}_z$ZLEVEL; DROP TABLE IF EXISTS ${LAYER_NAME}_z$ZLEVEL; CREATE TABLE ${LAYER_NAME}_z$ZLEVEL (rid serial PRIMARY KEY,rast raster,filename text);" > $WORKDIR/rast.sql
find $WORKDIR/ -type f -regex ".*\.tif\.sql" | xargs cat  >> $WORKDIR/rast.sql
echo "CREATE INDEX ON ${LAYER_NAME}_z$ZLEVEL USING gist (st_convexhull(rast)); ANALYZE ${LAYER_NAME}_z$ZLEVEL; VACUUM ANALYZE ${LAYER_NAME}_z$ZLEVEL; CREATE VIEW u_${LAYER_NAME}_z$ZLEVEL AS SELECT ST_Union(rast) AS u FROM ${LAYER_NAME}_z$ZLEVEL;" >> $WORKDIR/rast.sql
psql -q -d buildingmapping < $WORKDIR/rast.sql
#EOF
