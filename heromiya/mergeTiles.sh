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

nodejs get.GoogleSat.js $LONMIN $LATMIN $LONMAX $LATMAX $OZLEVEL > args/args.`basename $0`.lst
for ARGS in `cat $ARGFNAME | head -n 1`; do
    OTILE_X=`echo $ARGS | sed 's/\([0-9]*\),\([0-9]*\),\([0-9]*\),\([0-9]*\),\([0-9]*\),\([0-9]*\),\([0-9]*\)/\1/g'`
    OTILE_Y=`echo $ARGS | sed 's/\([0-9]*\),\([0-9]*\),\([0-9]*\),\([0-9]*\),\([0-9]*\),\([0-9]*\),\([0-9]*\)/\2/g'`    
    OTILE_LONMIN=`echo $ARGS | sed 's/\([0-9]*\),\([0-9]*\),\([0-9]*\),\([0-9]*\),\([0-9]*\),\([0-9]*\),\([0-9]*\)/\4/g'`       
    OTILE_LATMIN=`echo $ARGS | sed 's/\([0-9]*\),\([0-9]*\),\([0-9]*\),\([0-9]*\),\([0-9]*\),\([0-9]*\),\([0-9]*\)/\5/g'`
    OTILE_LONMAX=`echo $ARGS | sed 's/\([0-9]*\),\([0-9]*\),\([0-9]*\),\([0-9]*\),\([0-9]*\),\([0-9]*\),\([0-9]*\)/\6/g'`                                                                                                  
    OTILE_LATMAX=`echo $ARGS | sed 's/\([0-9]*\),\([0-9]*\),\([0-9]*\),\([0-9]*\),\([0-9]*\),\([0-9]*\),\([0-9]*\)/\7/g'`                                                                                                  
    OTILE_ARGFNAME=args/args.$OZLEVEL.$OTILE_X.$OTILE_Y.lst
    OTILE_MERGELIST=args/tiles.$OZLEVEL.$OTILE_X.$OTILE_Y.lst
    OTILE=sampleImages/Z.$OZLEVEL.$IZLEVEL/Z.$OZLEVEL.$IZLEVEL.$OTILE_X.$OTILE_Y.tif
    
    nodejs get.GoogleSat.js $OTILE_LONMIN $OTILE_LATMIN $OTILE_LONMAX $OTILE_LATMAX $IZLEVEL > $OTILE_ARGFNAME
    awk 'BEGIN{FS=","} {printf("GMap/gtiff/18/%d/Z18.%d.%d.tif\n",$1,$1,$2)}' $OTILE_ARGFNAME > $OTILE_MERGELIST
    gdalbuildvrt -input_file_list $OTILE_MERGELIST -overwrite $OTILE_MERGELIST.vrt
    gdal_translate -co compress=deflate $OTILE_MERGELIST.vrt $OTILE
done                                                                                                           
