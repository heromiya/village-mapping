#! /bin/bash

mkdir -p sampleImages/GMap

#for ARGS in $(psql -h guam suvannaket -qAtc "select qkey,ST_XMIN(ST_Transform(geom,3857)),ST_YMIN(ST_Transform(geom,3857)),ST_XMAX(ST_Transform(geom,3857)),ST_YMAX(ST_Transform(geom,3857)),gadm0,x,y,z,validate from grid where validate = 1 OR validate = 2 limit 10"); do
function getImage(){
    ARGS=$1
    QKEY=$(echo $ARGS | cut -f 1 -d "|")
    XMIN=$(echo $ARGS | cut -f 2 -d "|")
    YMIN=$(echo $ARGS | cut -f 3 -d "|")
    XMAX=$(echo $ARGS | cut -f 4 -d "|")
    YMAX=$(echo $ARGS | cut -f 5 -d "|")
    GADM=$(echo $ARGS | cut -f 6 -d "|")
    X=$(echo $ARGS | cut -f 7 -d "|")
    Y=$(echo $ARGS | cut -f 8 -d "|")
    Z=$(echo $ARGS | cut -f 9 -d "|")
    V=$(echo $ARGS | cut -f 10 -d "|")
    HEIGHT=$(perl -e "print int(($YMAX - $YMIN)/0.29858214 + 0.5)")
    WIDTH=$(perl  -e "print int(($XMAX - $XMIN)/0.29858214 + 0.5)")

    WORKDIR=$(mktemp -d)
    wget -q -O $WORKDIR/i${QKEY}-${X}-${Y}-${Z}-${GADM}-${V}.tif "http://hawaii.csis.u-tokyo.ac.jp:3857/service?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&LAYERS=Google%20Maps%20Satellite&STYLES=&WIDTH=${WIDTH}&HEIGHT=${HEIGHT}&FORMAT=image/geotiff&CRS=EPSG:3857&BBOX=${XMIN},${YMIN},${XMAX},${YMAX}"
    rm -f  sampleImages/GMap/i${QKEY}-${X}-${Y}-${Z}-${GADM}-${V}.tif
    gdal_translate -q -of GTiff -co "compress=JPEG" -co "JPEG_QUALITY=75" $WORKDIR/i${QKEY}-${X}-${Y}-${Z}-${GADM}-${V}.tif sampleImages/GMap/i${QKEY}-${X}-${Y}-${Z}-${GADM}-${V}.tif
    rm -rf $WORKDIR
}
export -f getImage
parallel --progress getImage {} ::: $(psql -h guam suvannaket -qAtc "select qkey,ST_XMIN(ST_Transform(geom,3857)),ST_YMIN(ST_Transform(geom,3857)),ST_XMAX(ST_Transform(geom,3857)),ST_YMAX(ST_Transform(geom,3857)),gadm1,x,y,z,validate from grid where validate = 1 OR validate = 2")
#done
