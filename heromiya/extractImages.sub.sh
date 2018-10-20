QKEY=$1

COORDS=`psql suvannaket -tc "select st_xmin(geom)+0.0005,st_ymin(geom)+0.0005,st_xmax(geom)-0.0005,st_ymax(geom)-0.0005 from grid where qkey = '$QKEY' limit 1;"`
LONMIN=`echo $COORDS | cut -d '|' -f 1`
LATMIN=`echo $COORDS | cut -d '|' -f 2`
LONMAX=`echo $COORDS | cut -d '|' -f 3`
LATMAX=`echo $COORDS | cut -d '|' -f 4`
echo $LONMIN $LATMIN $LONMAX $LATMAX $ZLEVEL
ARGLST=$(mktemp) 
#rm -f args1.lst
nodejs get.GoogleSat.js $LONMIN $LATMIN $LONMAX $LATMAX $ZLEVEL > $ARGLST
parallel ./getGoogleMaps.Sub.sh :::: $ARGLST
#:<<"#EOF"

export MERGEDTILE=sampleImages/GMap/${ZLEVEL}/a${QKEY}-Z${ZLEVEL}.tif
if [ ! -e $MERGEDTILE ]; then
    export MERGEINPUT="`awk 'BEGIN{FS=\",\"}{printf(\"GMap/gtiff/%i/%i/Z%i.%i.%i.tif \",$3,$1,$3,$1,$2)}' $ARGLST`"
    make $MERGEDTILE
fi

eval `gdalinfo $MERGEDTILE | grep "Pixel Size" | sed 's/ //g;s/,/ /;s/-//'`
XMIN=`gdalinfo $MERGEDTILE | grep "Lower Left" | tr -d " " | sed 's/LowerLeft(\([0-9.-]*\),\([0-9.-]*\)).*/\1/;'`
YMIN=`gdalinfo $MERGEDTILE | grep "Lower Left" | tr -d " " | sed 's/LowerLeft(\([0-9.-]*\),\([0-9.-]*\)).*/\2/;'`
XMAX=`gdalinfo $MERGEDTILE | grep "Upper Right" | tr -d " " | sed 's/UpperRight(\([0-9.-]*\),\([0-9.-]*\)).*/\1/;'`
YMAX=`gdalinfo $MERGEDTILE | grep "Upper Right" | tr -d " " | sed 's/UpperRight(\([0-9.-]*\),\([0-9.-]*\)).*/\2/;'`

mkdir -p  sampleImages/vi/${ZLEVEL}
VIOUT=sampleImages/vi/${ZLEVEL}/r${QKEY}-Z${ZLEVEL}.tif
if [ ! -e $VIOUT ]; then
    TMP=`mktemp`.$QKEY.`date +%F-%T`.sqlite
    ogr2ogr -select digitized_status -spat $LONMIN $LATMIN $LONMAX $LATMAX -t_srs EPSG:3857 -f SQLite $TMP PG:dbname=suvannaket building
    gdal_rasterize -co compress=deflate -ot Byte -a_srs EPSG:3857 -burn 1 -tr ${PixelSize[0]} ${PixelSize[1]} -te $XMIN $YMIN $XMAX $YMAX $TMP $VIOUT

fi
#EOF

rm -f $ARGLST $TMP
