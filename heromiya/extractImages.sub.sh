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
if [ ! -e $MERGEDTILE ]; then
    export MERGEINPUT="`awk 'BEGIN{FS=\",\"}{printf(\"GMap/gtiff/%i/%i/Z%i.%i.%i.tif \",$3,$1,$3,$1,$2)}' args1.lst`"
    make $MERGEDTILE
fi

eval `gdalinfo $MERGEDTILE | grep "Pixel Size" | sed 's/ //g;s/,/ /;s/-//'`
XMIN=`gdalinfo $MERGEDTILE | grep "Lower Left" | tr -d " " | sed 's/LowerLeft(\([0-9.-]*\),\([0-9.-]*\)).*/\1/;'`
YMIN=`gdalinfo $MERGEDTILE | grep "Lower Left" | tr -d " " | sed 's/LowerLeft(\([0-9.-]*\),\([0-9.-]*\)).*/\2/;'`
XMAX=`gdalinfo $MERGEDTILE | grep "Upper Right" | tr -d " " | sed 's/UpperRight(\([0-9.-]*\),\([0-9.-]*\)).*/\1/;'`
YMAX=`gdalinfo $MERGEDTILE | grep "Upper Right" | tr -d " " | sed 's/UpperRight(\([0-9.-]*\),\([0-9.-]*\)).*/\2/;'`

mkdir -p  sampleImages/vi
VIOUT=sampleImages/vi/r${QKEY}-Z${ZLEVEL}.tif
if [ ! -e $VIOUT ]; then
    TMP=`mktemp`.$QKEY.`date +%F-%T`.sqlite
    ogr2ogr -select digitized_status -spat $LONMIN $LATMIN $LONMAX $LATMAX -t_srs EPSG:3857 -f SQLite $TMP PG:dbname=suvannaket building
#    NFEATURE=$(ogrinfo $TMP -al -summary | grep "Feature Count:" | cut -f 3 -d " ")
#    if [ $NEATURE -gt 0 ]; then
    gdal_rasterize -ot Byte -a_srs EPSG:3857 -a digitized_status -tr ${PixelSize[0]} ${PixelSize[1]} -te $XMIN $YMIN $XMAX $YMAX $TMP $VIOUT
#    else
	
#    fi
fi
#EOF
