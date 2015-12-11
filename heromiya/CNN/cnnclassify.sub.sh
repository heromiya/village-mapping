export TARGETTILE=$1

export CNNOUTPUT=$(echo $1 | sed 's/..\/Bing\/gtiff\/18\/a/cnnresult\/Z18-a/g; s/\.tif/\.cnnresult\.tif/g')
export CNNPROJ=$(echo $1 | sed 's/..\/Bing\/gtiff\/18\/a/cnnproj\/Z18-a/g; s/\.tif/\.cnnproj\.tif/g')
export TILE_QKEY=$(echo $1 | sed 's/..\/Bing\/gtiff\/18\/a//g; s/\.tif//g')
export XRES=`gdalinfo $TARGETTILE | grep "Pixel Size" | sed 's/.*(\([0-9.]*\),-\([0-9.]*\))/\1/'`
export YRES=`gdalinfo $TARGETTILE | grep "Pixel Size" | sed 's/.*(\([0-9.]*\),-\([0-9.]*\))/\2/'`

BB=`iojs inqTileBB.js $TILE_QKEY`
export LONMIN=`echo $BB | cut -f 1 -d '|'`
export LATMIN=`echo $BB | cut -f 2 -d '|'`
export LONMAX=`echo $BB | cut -f 3 -d '|'`
export LATMAX=`echo $BB | cut -f 4 -d '|'`

export QLONMIN=`echo "$LONMIN - 0.0001" | bc`
export QLATMIN=`echo "$LATMIN - 0.0001" | bc`
export QLONMAX=`echo "$LONMAX + 0.0001" | bc`
export QLATMAX=`echo "$LATMAX + 0.0001" | bc`

export XMIN=`echo "$(echo ${LONMIN} ${LATMIN} | cs2cs $EPSG4326 +to $EPSG3857 | awk '{print $1}') - $WINSIZE / 2 * $XRES" | bc`
export YMIN=`echo "$(echo ${LONMIN} ${LATMIN} | cs2cs $EPSG4326 +to $EPSG3857 | awk '{print $2}') - $WINSIZE / 2 * $YRES" | bc`
export XMAX=`echo "$(echo ${LONMAX} ${LATMAX} | cs2cs $EPSG4326 +to $EPSG3857 | awk '{print $1}') + ($WINSIZE / 2 - 1) * $XRES" | bc`
export YMAX=`echo "$(echo ${LONMAX} ${LATMAX} | cs2cs $EPSG4326 +to $EPSG3857 | awk '{print $2}') + ($WINSIZE / 2 - 1) * $YRES" | bc`

export CNNINPUT=cnninput/Z${ZLEVEL}-${TILE_QKEY}.tif

make -rR $CNNINPUT $CNNOUTPUT $CNNPROJ
