export TARGETTILE=$1
export TRAINING_DATA=
export TILE_QKEY=$(echo $1 | sed "s/..\/Bing\/gtiff\/${ZLEVEL}\/a//g; s/\.tif//g")
#export CNNOUTPUT=$(echo $1 | sed "s/..\/Bing\/gtiff\/${ZLEVEL}\/a/cnnresult\/${ZLEVEL}\/Z${ZLEVEL}-a/g; s/\.tif/\.cnnresult\.tif/g")
#export CNNPROJ=${ZLEVEL}/$(echo $1   | sed "s/..\/Bing\/gtiff\/${ZLEVEL}\/a/cnnproj\/${ZLEVEL}\/Z${ZLEVEL}-a/g; s/\.tif/\.cnnproj\.tif/g")
export CNNOUTPUT=cnnresult/${ZLEVEL}/Z${ZLEVEL}-a${TILE_QKEY}.cnnresult.tif
export CNNPROJ=cnnproj/${ZLEVEL}/Z${ZLEVEL}-a${TILE_QKEY}.cnnproj.tif
export CNNINPUT=cnninput/${ZLEVEL}/Z${ZLEVEL}-${TILE_QKEY}.tif

PixelSize=`gdalinfo $TARGETTILE | grep "Pixel Size"`
export XRES=`echo $PixelSize | sed 's/.*(\([0-9.]*\),-\([0-9.]*\))/\1/'`
export YRES=`echo $PixelSize | sed 's/.*(\([0-9.]*\),-\([0-9.]*\))/\2/'`

BB=`iojs inqTileBB.js $TILE_QKEY`
export LONMIN=`echo $BB | cut -f 1 -d '|'`
export LATMIN=`echo $BB | cut -f 2 -d '|'`
export LONMAX=`echo $BB | cut -f 3 -d '|'`
export LATMAX=`echo $BB | cut -f 4 -d '|'`

export QLONMIN=`echo "$LONMIN - 0.0001" | bc`
export QLATMIN=`echo "$LATMIN - 0.0001" | bc`
export QLONMAX=`echo "$LONMAX + 0.0001" | bc`
export QLATMAX=`echo "$LATMAX + 0.0001" | bc`

export XMIN=$(echo "`echo $LONMIN $LATMIN | cs2cs $EPSG4326 +to $EPSG3857 | awk '{print $1}'` - $XRES * ($WINSIZE/2-1)" | bc)
export YMIN=$(echo "`echo $LONMIN $LATMIN | cs2cs $EPSG4326 +to $EPSG3857 | awk '{print $2}'` - $YRES * ($WINSIZE/2-1)" | bc)
export XMAX=$(echo "`echo $LONMAX $LATMAX | cs2cs $EPSG4326 +to $EPSG3857 | awk '{print $1}'` + $XRES * ($WINSIZE/2+1)" | bc)
export YMAX=$(echo "`echo $LONMAX $LATMAX | cs2cs $EPSG4326 +to $EPSG3857 | awk '{print $2}'` + $YRES * ($WINSIZE/2+1)" | bc)

make -rR $CNNINPUT $CNNOUTPUT $CNNPROJ
