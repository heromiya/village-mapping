# /bin/bash -x

# The script needs MapProxy 1.8
# Extent: (106.368585, 16.628645) - (106.421923 16.662368)
#XMIN=11647846.90790291503071785
#XMAX=11899688.91161549836397171
#YMIN=1775962.98947082902304828
#YMAX=1948602.50795785989612341
LONMIN=106.368585
LONMAX=106.421923
LATMIN=16.628645
LATMAX=16.662368

#LONMIN=$1
#LONMAX=$2
#LATMIN=$3
#LATMAX=$4

#export ZLEVEL=$5
export ZLEVEL=17
export EPSG4326="+proj=longlat +datum=WGS84 +no_defs"
export EPSG3857="+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs"
export WIDTH=256
export HEIGHT=256

nodejs --max_old_space_size=16384 get.GoogleSat.js $LONMIN $LATMIN $LONMAX $LATMAX $ZLEVEL > args.lst
parallel --jobs 16 ./getGoogleMaps.Sub.sh {} < args.lst

:<<'#EOF'
for ARGS in `cat args.lst`;do
	export TILEX=`echo $ARGS |cut -d ',' -f 1`
	export TILEY=`echo $ARGS |cut -d ',' -f 2`
	TILE_LONMIN=`echo $ARGS |cut -d ',' -f 4`
	TILE_LATMIN=`echo $ARGS |cut -d ',' -f 5`
	TILE_LONMAX=`echo $ARGS |cut -d ',' -f 6`
	TILE_LATMAX=`echo $ARGS |cut -d ',' -f 7`
	export TILE_XMIN=`echo $TILE_LONMIN $TILE_LATMIN | proj $EPSG3857 | awk '{print $1}'`
	export TILE_YMIN=`echo $TILE_LONMIN $TILE_LATMIN | proj $EPSG3857 | awk '{print $2}'`
	export TILE_XMAX=`echo $TILE_LONMAX $TILE_LATMAX | proj $EPSG3857 | awk '{print $1}'`
	export TILE_YMAX=`echo $TILE_LONMAX $TILE_LATMAX | proj $EPSG3857 | awk '{print $2}'`
#    if [ ! -e  GMap/png/$ZLEVEL/$TILEX/Z$ZLEVEL.$TILEX.$TILEY.png ]; then
	make -BR GMap/gtiff/$ZLEVEL/$TILEX/Z$ZLEVEL.$TILEX.$TILEY.tif
#    fi
done
#EOF
