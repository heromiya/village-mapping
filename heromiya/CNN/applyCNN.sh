#! /bin/bash

export ZLEVEL=$1
export WINSIZE=18
export NSAMPLE=1000

export EPSG4326="+proj=longlat +datum=WGS84 +no_defs"
export EPSG3857="+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs"
export OCTAVEOPT="-q --no-history --no-init-file --no-line-editing --no-window-system"

#:<<'#EOF'
mkdir -p sample_tmp/$ZLEVEL
eval `g.gisenv`
g.proj -c proj4="+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs <>"
#db.connect driver=sqlite database=$GISDBASE/$LOCATION_NAME/$MAPSET/db.sqlite
db.connect driver=sqlite database='$GISDBASE/$LOCATION_NAME/$MAPSET/sqlite.db'

for TRAINING_QKEY in `cat ../completedSamples_EY.lst`; do
    export TRAINING_QKEY
    export TILES=tileList/$ZLEVEL/Z$ZLEVEL-$TRAINING_QKEY.lst
    export TILESVRT=tileList/$ZLEVEL/Z$ZLEVEL-$TRAINING_QKEY.vrt
    make $TILES $TILESVRT.tif $TILESVRT.info
    
    export XMIN=`grep "Upper Left"  $TILESVRT.info | sed 's/^Upper Left  (\([-.0-9]*\), \([-.0-9]*\)) .*/\1/g'`
    export YMIN=`grep "Lower Right" $TILESVRT.info | sed 's/^Lower Right (\([-.0-9]*\), \([-.0-9]*\)) .*/\2/g'`
    export XMAX=`grep "Lower Right" $TILESVRT.info | sed 's/^Lower Right (\([-.0-9]*\), \([-.0-9]*\)) .*/\1/g'`
    export YMAX=`grep "Upper Left"  $TILESVRT.info | sed 's/^Upper Left  (\([-.0-9]*\), \([-.0-9]*\)) .*/\2/g'`

    export XRES=`grep "Pixel Size"  $TILESVRT.info | sed 's/Pixel Size = (\([-.0-9]*\),\([-.0-9]*\))/\1/'`
    export YRES=`grep "Pixel Size"  $TILESVRT.info | sed 's/Pixel Size = (\([-.0-9]*\),\([-.0-9]*\))/\2/; s/-//'`

    g.region n=$YMAX s=$YMIN e=$XMAX w=$XMIN nsres=$YRES ewres=$XRES --overwrite --quiet

    r.mask -r
    for MASKVAL in 0 1; do
	export MASKVAL
	make sample_tmp/${ZLEVEL}/Z${ZLEVEL}-${TRAINING_QKEY}-${MASKVAL}_merge.txt
    done
done
#EOF

export TRAINING_DATA=training_data/Z${ZLEVEL}-training_data-$NSAMPLE.csv
export KNOWLEDGE=knowledgebase/Z${ZLEVEL}-knowledgebase.$NSAMPLE.mat
make $TRAINING_DATA $KNOWLEDGE

#for TRAINING_QKEY in `cat ../completedSamples_EY.lst`; do
for TEST_QKEY in `iojs ../get.BingAerial.js 96.1425 16.7656 96.3683 17.0239 15 | awk 'BEGIN{FS=","}{print $1}'`; do
    export TILESVRT=tileList/$ZLEVEL/Z$ZLEVEL-$TEST_QKEY.vrt
    export TILES=tileList/$ZLEVEL/Z$ZLEVEL-$TEST_QKEY.lst
    make $TILES $TILESVRT.tif $TILESVRT.info

    cat $TILES | xargs parallel --jobs 20% --joblog logs/cnnclassify.m-`date +"%F_%T"` ./cnnclassify.sub.sh :::
#    bash -x ./cnnclassify.sub.sh `head -n 1 $TILES`
done
exit 0
