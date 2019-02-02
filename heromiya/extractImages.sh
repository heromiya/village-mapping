#! /bin/bash

mkdir -p sampleImages
mkdir -p sampleImagesVRT
export GADM_GID=$1
export ZLEVEL=$2
export EPSG4326="+proj=longlat +datum=WGS84 +no_defs"
export EPSG3857="+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs"
export WIDTH=256
export HEIGHT=256

function sub(){
    QKEY=$1

    COORDS=`psql -h guam -d suvannaket -qAtc "select st_xmin(geom),st_ymin(geom),st_xmax(geom),st_ymax(geom) from grid_${ZLEVEL} where qkey = '$QKEY' limit 1;"`
    LONMIN=`echo $COORDS | cut -d '|' -f 1`
    LATMIN=`echo $COORDS | cut -d '|' -f 2`
    LONMAX=`echo $COORDS | cut -d '|' -f 3`
    LATMAX=`echo $COORDS | cut -d '|' -f 4`

:<<'#EOF'

ARGLST=$(mktemp) 

nodejs get.GoogleSat.js $(echo "scale=10;$LONMIN+0.0005"|bc) $(echo "scale=10;$LATMIN+0.0005"|bc) $(echo "scale=10;$LONMAX-0.0005"|bc) $(echo "scale=10;$LATMAX-0.0005"|bc) $ZLEVEL > $ARGLST
parallel --nice 10 --progress ./getGoogleMaps.Sub.sh :::: $ARGLST

export MERGEDTILE=sampleImages/GMap/${ZLEVEL}/a${QKEY}-Z${ZLEVEL}.tif
if [ ! -e $MERGEDTILE ]; then
    export MERGEINPUT="`awk 'BEGIN{FS=\",\"}{printf(\"GMap/gtiff/%i/%i/Z%i.%i.%i.tif \",$3,$1,$3,$1,$2)}' $ARGLST`"
    make -s $MERGEDTILE
fi
#EOF

    TILE=($(echo "var tilebelt = require('@mapbox/tilebelt'); console.log(tilebelt.quadkeyToTile('$QKEY'))" | node |tr -d "[],"))

    export MERGEDTILE=sampleImages/GMap/${TILE[2]}/a${QKEY}-Z${TILE[2]}.tif
    ln -f $(pwd)/GMap/gtiff/${TILE[2]}/${TILE[0]}/Z${TILE[2]}.${TILE[0]}.${TILE[1]}.tif $MERGEDTILE

    eval `gdalinfo $MERGEDTILE | grep "Pixel Size" | sed 's/ //g;s/,/ /;s/-//'`
    XMIN=`gdalinfo $MERGEDTILE | grep "Lower Left" | tr -d " " | sed 's/LowerLeft(\([0-9.-]*\),\([0-9.-]*\)).*/\1/;'`
    YMIN=`gdalinfo $MERGEDTILE | grep "Lower Left" | tr -d " " | sed 's/LowerLeft(\([0-9.-]*\),\([0-9.-]*\)).*/\2/;'`
    XMAX=`gdalinfo $MERGEDTILE | grep "Upper Right" | tr -d " " | sed 's/UpperRight(\([0-9.-]*\),\([0-9.-]*\)).*/\1/;'`
    YMAX=`gdalinfo $MERGEDTILE | grep "Upper Right" | tr -d " " | sed 's/UpperRight(\([0-9.-]*\),\([0-9.-]*\)).*/\2/;'`

    mkdir -p  sampleImages/vi/${ZLEVEL}
    VIOUT=sampleImages/vi/${ZLEVEL}/r${QKEY}-Z${ZLEVEL}.tif
    #rm -f $VIOUT
    if [ ! -e $VIOUT ]; then
	TMP=`mktemp -d`/$QKEY.sqlite
	ogr2ogr -select digitized_status -spat $LONMIN $LATMIN $LONMAX $LATMAX -t_srs EPSG:3857 -f SQLite $TMP PG:"dbname=suvannaket host=guam" building
	gdal_rasterize -co compress=deflate -ot Byte -a_srs EPSG:3857 -burn 1 -tr ${PixelSize[0]} ${PixelSize[1]} -te $XMIN $YMIN $XMAX $YMAX $TMP $VIOUT

    fi
    #EOF

    rm -f $ARGLST $TMP
}
export -f sub
TARGET_SAMPLE_TILES=completedSamples.d/completedSamples.${GADM_GID}.Z${ZLEVEL}.lst
make $TARGET_SAMPLE_TILES
parallel --nice 10 --progress sub :::: $TARGET_SAMPLE_TILES

exit 0
