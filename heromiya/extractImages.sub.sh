QKEY=$1

COORDS=`psql suvannaket -tc "select st_xmin(geom),st_ymin(geom),st_xmax(geom),st_ymax(geom) from grid where qkey = '$QKEY';"`
LONMIN=`echo $COORDS | cut -d '|' -f 1`
LATMIN=`echo $COORDS | cut -d '|' -f 2`
LONMAX=`echo $COORDS | cut -d '|' -f 3`
LATMAX=`echo $COORDS | cut -d '|' -f 4`
#echo $LONMIN $LATMIN $LONMAX $LATMAX $ZLEVEL
nodejs get.GoogleSat.js $LONMIN $LATMIN $LONMAX $LATMAX $ZLEVEL > args1.lst
cat args1.lst | xargs parallel --joblog log/getGoogleMaps.Sub.sh.$$ "./getGoogleMaps.Sub.sh" ::: 
#:<<"#EOF"

export MERGEDTILE=sampleImages/GMap/a${QKEY}-Z${ZLEVEL}.tif
export MERGEINPUT="`awk 'BEGIN{FS=\",\"}{printf(\"GMap/gtiff/%i/%i/Z%i.%i.%i.tif \",$3,$1,$3,$1,$2)}' args1.lst`"
make $MERGEDTILE

eval `gdalinfo $MERGEDTILE | grep "Pixel Size" | sed 's/ //g;s/,/ /;s/-//'`
XMIN=`gdalinfo $MERGEDTILE | grep "Lower Left" | sed 's/Lower Left *(\([0-9.-]*\), \([0-9.-]*\)) .*/\1/;'`
YMIN=`gdalinfo $MERGEDTILE | grep "Lower Left" | sed 's/Lower Left *(\([0-9.-]*\), \([0-9.-]*\)) .*/\2/;'`
XMAX=`gdalinfo $MERGEDTILE | grep "Upper Right" | sed 's/Upper Right *(\([0-9.-]*\), \([0-9.-]*\)) .*/\1/;'`
YMAX=`gdalinfo $MERGEDTILE | grep "Upper Right" | sed 's/Upper Right *(\([0-9.-]*\), \([0-9.-]*\)) .*/\2/;'`

mkdir -p  sampleImages/vi
TMP=`mktemp`.$QKEY.`date +%F-%T`.sqlite
ogr2ogr -select digitized_status -spat $LONMIN $LATMIN $LONMAX $LATMAX -t_srs EPSG:3857 -f SQLite $TMP PG:dbname=suvannaket building
gdal_rasterize -ot Byte -a_srs EPSG:3857 -a digitized_status -tr ${PixelSize[0]} ${PixelSize[1]} -te $XMIN $YMIN $XMAX $YMAX $TMP sampleImages/vi/r${QKEY}-Z${ZLEVEL}.tif
#EOF
