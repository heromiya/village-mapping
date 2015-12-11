#! /bin/bash

export ZLEVEL=18
export WINSIZE=18
export NSAMPLE=100

export EPSG4326="+proj=longlat +datum=WGS84 +no_defs"
export EPSG3857="+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs"
export OCTAVEOPT="-q --no-history --no-init-file --no-line-editing --no-window-system"

:<<'#EOF'

for TRAINING_QKEY in `cat ../completedSamples_EY.lst`; do
    export TRAINING_QKEY
    export TILES=tileList/Z$ZLEVEL-$TRAINING_QKEY.lst
    export TILESVRT=tileList/Z$ZLEVEL-$TRAINING_QKEY.vrt
    make $TILES $TILESVRT.tif $TILESVRT.info
    
    export XMIN=`grep "Upper Left"  $TILESVRT.info | sed 's/^Upper Left  (\([-.0-9]*\), \([-.0-9]*\)) .*/\1/g'`
    export YMIN=`grep "Lower Right" $TILESVRT.info | sed 's/^Lower Right (\([-.0-9]*\), \([-.0-9]*\)) .*/\2/g'`
    export XMAX=`grep "Lower Right" $TILESVRT.info | sed 's/^Lower Right (\([-.0-9]*\), \([-.0-9]*\)) .*/\1/g'`
    export YMAX=`grep "Upper Left"  $TILESVRT.info | sed 's/^Upper Left  (\([-.0-9]*\), \([-.0-9]*\)) .*/\2/g'`

    export XRES=`grep "Pixel Size"  $TILESVRT.info | sed 's/Pixel Size = (\([-.0-9]*\),\([-.0-9]*\))/\1/'`
    export YRES=`grep "Pixel Size"  $TILESVRT.info | sed 's/Pixel Size = (\([-.0-9]*\),\([-.0-9]*\))/\2/; s/-//'`
    eval `g.gisenv`

    g.proj -c proj4="+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs <>"
    g.region n=$YMAX s=$YMIN e=$XMAX w=$XMIN nsres=$YRES ewres=$XRES --overwrite --quiet
    r.in.gdal -ok input=$TILESVRT.tif output=bing --overwrite --quiet
    db.connect driver=sqlite database=$GISDBASE/$LOCATION_NAME/$MAPSET/db.sqlite
    v.in.ogr -o dsn=../working_polygon_EY.shp output=gt layer=working_polygon_EY type=boundary --overwrite --quiet
    v.to.rast input=gt type=area output=gt_rast use=val --overwrite --quiet
    r.null map=gt_rast null=0 --overwrite --quiet

    r.mask -r
    for MASKVAL in 0 1; do
	export MASKVAL
	make sample_tmp/Z${ZLEVEL}-${TRAINING_QKEY}-${MASKVAL}_merge.txt
    done
done
#EOF

TRAINING_DATA=training_data/training_data-`date +'%F-%T' | sed 's/[-:]//g'`-$$
rm -f $TRAINING_DATA
cat sample_tmp/Z${ZLEVEL}-[0-9]*-[01]_merge.txt | grep -v \* | sed 's/||/|/g; s/|$//g' > $TRAINING_DATA

export KNOWLEDGE=knowledgebase/knowledgebase-`date +'%F-%T' | sed 's/[-:]//g'`-$$

#octave $OCTAVEOPT buildKnowledgeBase.m $WINSIZE $TRAINING_DATA $KNOWLEDGE

for TRAINING_QKEY in `cat ../completedSamples_EY.lst | head -n 1`; do
    export TILESVRT=tileList/Z$ZLEVEL-$TRAINING_QKEY.vrt
    export TILES=tileList/Z$ZLEVEL-$TRAINING_QKEY.lst
    cat $TILES | xargs parallel --jobs 50% --joblog logs/cnnclassify.m-`date +"%F_%T"` ./cnnclassify.sub.sh :::
#    bash -x ./cnnclassify.sub.sh `head -n 1 $TILES`
#sed 's/\.\.\/Bing\/gtiff\/18\/a/cnninput\/Z18-/;' 
done
exit 0
