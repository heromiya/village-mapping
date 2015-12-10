export CNNINPUT=$1
export CNNOUTPUT=$(echo $1 | sed 's/..\/Bing\/gtiff\/18\/a/cnnresult\/Z18-a/g; s/\.tif/\.cnnresult\.tif/g')
export CNNPROJ=$(echo $1 | sed 's/..\/Bing\/gtiff\/18\/a/cnnproj\/Z18-a/g; s/\.tif/\.cnnproj\.tif/g')
export TILE_QKEY=$(echo $1 | sed 's/..\/Bing\/gtiff\/18\/a//g; s/\.tif//g')
export XRES=`gdalinfo $CNNINPUT | grep "Pixel Size" | sed 's/.*(\([0-9.]*\),-\([0-9.]*\))/\1/'`
export YRES=`gdalinfo $CNNINPUT | grep "Pixel Size" | sed 's/.*(\([0-9.]*\),-\([0-9.]*\))/\2/'`

BB=`iojs inqTileBB.js $(TILE_QKEY)`
LONMIN=$(echo "`echo $$BB | cut -f 1 -d '|'` - 0.0001" | bc)
LATMIN=$(echo "`echo $$BB | cut -f 2 -d '|'` - 0.0001" | bc)
LONMAX=$(echo "`echo $$BB | cut -f 3 -d '|'` + 0.0001" | bc)
LATMAX=$(echo "`echo $$BB | cut -f 4 -d '|'` + 0.0001" | bc)


make -rR $CNNOUTPUT $CNNPROJ
