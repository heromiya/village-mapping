#! /bin/bash

LONMIN=89.996800
LATMIN=24.650100
LONMAX=90.061400
LATMAX=24.686600
PixelSizeX=0.597187500003201
PixelSizeY=0.597148437500437

export EPSG4326="+proj=longlat +datum=WGS84 +no_defs"
export EPSG3857="+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs"

XMIN=`echo $LONMIN $LATMIN | proj $EPSG3857 | awk '{print $1}'`
YMIN=`echo $LONMIN $LATMIN | proj $EPSG3857 | awk '{print $2}'`
XMAX=`echo $LONMAX $LATMAX | proj $EPSG3857 | awk '{print $1}'`
YMAX=`echo $LONMAX $LATMAX | proj $EPSG3857 | awk '{print $2}'`

rm -f  uttam.request.20170304.ref.tif  uttam.request.20170304.img.tif
gdal_rasterize -ot Byte -a_srs EPSG:3857 -a flag -l working_polygon -tr $PixelSizeX $PixelSizeY -te $XMIN $YMIN $XMAX $YMAX working_polygon.sqlite uttam.request.20170304.ref.tif

gdalwarp -te $XMIN $YMIN $XMAX $YMAX -tr $PixelSizeX $PixelSizeY -wm 1024 -co "COMPRESS=Deflate" -co "BIGTIFF=YES" -overwrite Bing/gtiff/18/*.tif uttam.request.20170304.img.tif

