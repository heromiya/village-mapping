#! /bin/bash

mkdir -p sampleImages
export ZLEVEL=19
export EPSG4326="+proj=longlat +datum=WGS84 +no_defs"
export EPSG3857="+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs"

for QKEY in `cat completedSamples.lst`; do
    COORDS=`echo "select st_minx(geometry),st_miny(geometry),st_maxx(geometry),st_maxy(geometry) from target_tiles where qkey = '$QKEY';" | spatialite ../Data/targetExtents/target_tiles.sqlite`
    LONMIN=`echo $COORDS | cut -d '|' -f 1`
    LATMIN=`echo $COORDS | cut -d '|' -f 2`
    LONMAX=`echo $COORDS | cut -d '|' -f 3`
    LATMAX=`echo $COORDS | cut -d '|' -f 4`
    iojs get.BingAerial.js $LONMIN $LATMIN $LONMAX $LATMAX $ZLEVEL > args1.lst
    cat args1.lst | xargs parallel --joblog log.txt --jobs 10% "./get.Bing.Aerial.Sub.sh" ::: 

    gdalwarp `find -type f | grep ".*gtiff.*$QKEY.*tif"` sampleImages/a${QKEY}-Z${ZLEVEL}.tif
#    gdal_rasterize 
done

exit 0
