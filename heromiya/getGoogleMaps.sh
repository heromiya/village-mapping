# /bin/bash -x

# The script needs MapProxy 1.9

LONMIN=$1
LONMAX=$2
LATMIN=$3
LATMAX=$4

export ZLEVEL=$5

export EPSG4326="+proj=longlat +datum=WGS84 +no_defs"
export EPSG3857="+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs"
export WIDTH=256
export HEIGHT=256

nodejs --max_old_space_size=65536 get.GoogleSat.js $LONMIN $LATMIN $LONMAX $LATMAX $ZLEVEL > args.lst
parallel --jobs $NPROC ./getGoogleMaps.Sub.sh {} < args.lst
