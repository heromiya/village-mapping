#! /bin/bash

export WORKDIR=$(mktemp -d)

export ZLEVEL=19

#bash getGoogleMaps.sh 34.7 35.2 -19.9 -19.6 $ZLEVEL
#bash getGoogleMaps.sh 32.4 32.7 -26.1 -25.7 $ZLEVEL
#bash getGoogleMaps.sh 34.7 35.2 -19.9 -19.6 $ZLEVEL

r2p(){
    raster2pgsql -s 3857 -a -R -F -e $1 gmap_z$ZLEVEL > $WORKDIR/$(basename $1).sql
}
export -f r2p

find GMap/gtiff/$ZLEVEL/ -type f -regex ".*\.tif$" > $WORKDIR/tifs.lst
parallel --nice 10 --progress r2p {} :::: $WORKDIR/tifs.lst

echo "DROP TABLE IF EXISTS gmap_z$ZLEVEL; CREATE TABLE gmap_z$ZLEVEL (rid serial PRIMARY KEY,rast raster,filename text);" > $WORKDIR/rast.sql
cat *.sql >> $WORKDIR/rast.sql
echo "CREATE INDEX ON gmap_z$ZLEVEL USING gist (st_convexhull(rast)); ANALYZE gmap_z$ZLEVEL; VACUUM ANALYZE gmap_z$ZLEVEL;" >> $WORKDIR/rast.sql
psql -d buildingmapping < $WORKDIR/rast.sql
