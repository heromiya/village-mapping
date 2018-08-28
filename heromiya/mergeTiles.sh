#! /bin/bash

OZLEVEL=15
IZLEVEL=18
LONMIN=105.6371
LATMIN=16.0363
LONMAX=106.7222
LATMAX=16.9907

export EPSG4326="+proj=longlat +datum=WGS84 +no_defs"
export EPSG3857="+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs"

XMIN=`echo $LONMIN $LATMIN | proj $EPSG3857 | awk '{print $1}'`
YMIN=`echo $LONMIN $LATMIN | proj $EPSG3857 | awk '{print $2}'`
XMAX=`echo $LONMAX $LATMAX | proj $EPSG3857 | awk '{print $1}'`
YMAX=`echo $LONMAX $LATMAX | proj $EPSG3857 | awk '{print $2}'`
ARGFNAME=args/args.`basename $0`.lst

nodejs get.GoogleSat.js $LONMIN $LATMIN $LONMAX $LATMAX $OZLEVEL > $ARGFNAME
parallel -j 7 ./mergeTiles.sub.sh < $ARGFNAME
