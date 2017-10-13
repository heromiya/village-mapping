#! /bin/bash -x 
  
LONMIN=105.6371
LATMIN=16.0363
LONMAX=106.7222
LATMAX=16.9907
PixelSizeX=0.597187500003201
PixelSizeY=0.597148437500437

export EPSG4326="+proj=longlat +datum=WGS84 +no_defs"
export EPSG3857="+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs"

#./getGoogleMaps.sh $LONMIN $LONMAX $LATMIN $LATMAX 18

XMIN=`echo $LONMIN $LATMIN | proj $EPSG3857 | awk '{print $1}'`
YMIN=`echo $LONMIN $LATMIN | proj $EPSG3857 | awk '{print $2}'`
XMAX=`echo $LONMAX $LATMAX | proj $EPSG3857 | awk '{print $1}'`
YMAX=`echo $LONMAX $LATMAX | proj $EPSG3857 | awk '{print $2}'`

OUTIMG=sampleImages/$0.img.tif
OUTREF=sampleImages/$0.ref.tif
OUTVRT=sampleImages/$0.img.vrt

#rm -f  $0.ref.tif  $0.img.tif
#gdal_rasterize -ot Byte -a_srs EPSG:3857 -a flag -l working_polygon -tr $PixelSizeX $PixelSizeY -te $XMIN $YMIN $XMAX $YMAX working_polygon.sqlite $OUTREF

rm -f sampleImages/$0.vrt
find GMap/gtiff/18/ -type f | grep .tif$ | head -n 1 > 18.lst
gdalbuildvrt -te  $XMIN $YMIN $XMAX $YMAX -tr  $PixelSizeX $PixelSizeY -overwrite -input_file_list 18.lst $OUTVRT
gdal_translate -co "COMPRESS=Deflate" -co "BIGTIFF=YES" $OUTVRT $OUTIMG.GMap.tif
#gdalwarp -te $XMIN $YMIN $XMAX $YMAX -tr $PixelSizeX $PixelSizeY -wm 1024 -co "COMPRESS=Deflate" -co "BIGTIFF=YES" -overwrite GMap/gtiff/18/*.tif $OUTIMG.GMap.tif
#gdalwarp -te $XMIN $YMIN $XMAX $YMAX -tr $PixelSizeX $PixelSizeY -wm 1024 -co "COMPRESS=Deflate" -co "BIGTIFF=YES" -overwrite Bing/gtiff/18/*.tif $OUTIMG.Bing.tif

