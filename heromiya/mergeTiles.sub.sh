#! /bin/bash

ARGS=$1
OTILE_X=`echo $ARGS | cut -f 1 -d ","`
OTILE_Y=`echo $ARGS | cut -f 2 -d ","`
OTILE_LONMIN=`echo "scale=15; $(echo $ARGS | cut -f 4 -d ,) + 0.001" | bc`
OTILE_LATMIN=`echo "scale=15; $(echo $ARGS | cut -f 5 -d ,) + 0.001" | bc`
OTILE_LONMAX=`echo "scale=15; $(echo $ARGS | cut -f 6 -d ,) - 0.001" | bc`
OTILE_LATMAX=`echo "scale=15; $(echo $ARGS | cut -f 7 -d ,) - 0.001" | bc`
OTILE_ARGFNAME=args/args.$OZLEVEL.$OTILE_X.$OTILE_Y.lst
OTILE_MERGELIST=args/tiles.$OZLEVEL.$OTILE_X.$OTILE_Y.lst
OTILE=sampleImages/Z.$OZLEVEL.$IZLEVEL/Z.$OZLEVEL.$IZLEVEL.$OTILE_X.$OTILE_Y.tif
mkdir -p `dirname $OTILE`

nodejs get.GoogleSat.js $OTILE_LONMIN $OTILE_LATMIN $OTILE_LONMAX $OTILE_LATMAX $IZLEVEL > $OTILE_ARGFNAME
awk 'BEGIN{FS=","} {printf("GMap/gtiff/18/%d/Z18.%d.%d.tif\n",$1,$1,$2)}' $OTILE_ARGFNAME > $OTILE_MERGELIST
gdalbuildvrt -input_file_list $OTILE_MERGELIST -overwrite $OTILE_MERGELIST.vrt
gdal_translate -co compress=deflate $OTILE_MERGELIST.vrt $OTILE
