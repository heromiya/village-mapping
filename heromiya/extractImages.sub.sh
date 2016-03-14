QKEY=$1

COORDS=`echo "select st_minx(geometry),st_miny(geometry),st_maxx(geometry),st_maxy(geometry) from target_tiles where qkey = '$QKEY';" | spatialite ../Data/targetExtents/target_tiles.sqlite`
LONMIN=`echo $COORDS | cut -d '|' -f 1`
LATMIN=`echo $COORDS | cut -d '|' -f 2`
LONMAX=`echo $COORDS | cut -d '|' -f 3`
LATMAX=`echo $COORDS | cut -d '|' -f 4`
iojs get.BingAerial.js $LONMIN $LATMIN $LONMAX $LATMAX $ZLEVEL > args1.lst
cat args1.lst | xargs parallel --joblog log/get.Bing.Aerial.Sub.sh.$$ --jobs 5 "./get.Bing.Aerial.Sub.sh" ::: 

export MERGEDTILE=sampleImages/a${QKEY}-Z${ZLEVEL}.tif
export MERGEINPUT="`awk 'BEGIN{FS=\",\"}{printf(\"Bing/gtiff/19/a%s.tif \",$1)}' args1.lst`"
make $MERGEDTILE

eval `gdalinfo $MERGEDTILE | grep "Pixel Size" | sed 's/ //g;s/,/ /;s/-//'`
XMIN=`gdalinfo $MERGEDTILE | grep "Lower Left" | sed 's/Lower Left *(\([0-9.-]*\), \([0-9.-]*\)) .*/\1/;'`
YMIN=`gdalinfo $MERGEDTILE | grep "Lower Left" | sed 's/Lower Left *(\([0-9.-]*\), \([0-9.-]*\)) .*/\2/;'`
XMAX=`gdalinfo $MERGEDTILE | grep "Upper Right" | sed 's/Upper Right *(\([0-9.-]*\), \([0-9.-]*\)) .*/\1/;'`
YMAX=`gdalinfo $MERGEDTILE | grep "Upper Right" | sed 's/Upper Right *(\([0-9.-]*\), \([0-9.-]*\)) .*/\2/;'`

gdal_rasterize -ot Byte -a_srs EPSG:3857 -a flag -l working_polygon -tr ${PixelSize[0]} ${PixelSize[1]} -te $XMIN $YMIN $XMAX $YMAX working_polygon.sqlite sampleImages/r${QKEY}-Z${ZLEVEL}.tif
