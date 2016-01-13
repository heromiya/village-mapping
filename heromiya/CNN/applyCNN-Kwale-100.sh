#! /bin/bash

export ZLEVEL=$1
export WINSIZE=18
export NSAMPLE=100

export EPSG4326="+proj=longlat +datum=WGS84 +no_defs"
export EPSG3857="+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs"
export OCTAVEOPT="-q --no-history --no-init-file --no-line-editing --no-window-system"

export GRASS_VERBOSE=0
export GRASS_OVERWRITE=1

mkdir -p sample_tmp/$ZLEVEL/$NSAMPLE
eval `g.gisenv`
g.proj -c proj4="$EPSG3857"
db.connect driver=sqlite database='$GISDBASE/$LOCATION_NAME/$MAPSET/sqlite.db'

#cat ../completedSamples_EY.lst ../completedSamples.lst | xargs parallel --jobs 20% --joblog logs/prepareSamples.sh-`date +"%F_%T"` ./prepareSamples.sh :::

#for TRAINING_QKEY in `cat ../completedSamples_EY.lst ../completedSamples.lst`; do

make completedSamples.lst
TARGET_TMP=`mktemp`
iojs ../get.BingAerial.js 39.240627 -4.288781 39.530792 -4.064113 15 | awk 'BEGIN{FS=","}{print $1}' > $TARGET_TMP
#for TRAINING_QKEY in `grep -Ff completedSamples.lst $TARGET_TMP`; do
for TRAINING_QKEY in 300110331111121 300110331111123; do
    export TRAINING_QKEY
    export TILES=tileList/$ZLEVEL/Z$ZLEVEL-$TRAINING_QKEY.lst
    export TILESVRT=tileList/$ZLEVEL/Z$ZLEVEL-$TRAINING_QKEY.vrt
    make $TILES $TILESVRT.tif $TILESVRT.info

    export XMIN=`grep "Upper Left"  $TILESVRT.info | sed 's/^.*(.\([-.0-9]*\), \([-.0-9]*\)) .*/\1/g'`
    export YMIN=`grep "Lower Right" $TILESVRT.info | sed 's/^.*(.\([-.0-9]*\), \([-.0-9]*\)) .*/\2/g'`
    export XMAX=`grep "Lower Right" $TILESVRT.info | sed 's/^.*(.\([-.0-9]*\), \([-.0-9]*\)) .*/\1/g'`
    export YMAX=`grep "Upper Left"  $TILESVRT.info | sed 's/^.*(.\([-.0-9]*\), \([-.0-9]*\)) .*/\2/g'`

    export XRES=`grep "Pixel Size"  $TILESVRT.info | sed 's/.*(\([-.0-9]*\),\([-.0-9]*\))/\1/'`
    export YRES=`grep "Pixel Size"  $TILESVRT.info | sed 's/.*(\([-.0-9]*\),\([-.0-9]*\))/\2/; s/-//'`

    g.region n=$YMAX s=$YMIN e=$XMAX w=$XMIN nsres=$YRES ewres=$XRES --overwrite --quiet

    r.mask -r
    for MASKVAL in 0 1 3; do
	export MASKVAL
	make -rR sample_tmp/${ZLEVEL}/${NSAMPLE}/Z${ZLEVEL}-${TRAINING_QKEY}-${MASKVAL}_${NSAMPLE}_merge_allcoords.txt
    done
done

#export TRAINING_SRC="`grep -Ff completedSamples.lst $TARGET_TMP | awk -v zlevel=$ZLEVEL -v nsample=$NSAMPLE '{printf(\"sample_tmp/%s/%s/Z%s-%s-0_%s_merge_allcoords.txt sample_tmp/%s/%s/Z%s-%s-1_%s_merge_allcoords.txt sample_tmp/%s/%s/Z%s-%s-3_%s_merge_allcoords.txt \",zlevel,nsample,zlevel,$1,nsample,zlevel,nsample,zlevel,$1,nsample,zlevel,nsample,zlevel,$1,nsample)}'`"
export TRAINING_SRC="`printf "300110331111121\n300110331111123" | awk -v zlevel=$ZLEVEL -v nsample=$NSAMPLE '{printf(\"sample_tmp/%s/%s/Z%s-%s-0_%s_merge_allcoords.txt sample_tmp/%s/%s/Z%s-%s-1_%s_merge_allcoords.txt sample_tmp/%s/%s/Z%s-%s-3_%s_merge_allcoords.txt \",zlevel,nsample,zlevel,$1,nsample,zlevel,nsample,zlevel,$1,nsample,zlevel,nsample,zlevel,$1,nsample)}'`"
export TRAINING_DATA=training_data/Z${ZLEVEL}-training_data-$NSAMPLE-road_test.csv
export KNOWLEDGE=knowledgebase/Z${ZLEVEL}-knowledgebase.$NSAMPLE-road_test.mat
make -rR $TRAINING_DATA $KNOWLEDGE


#    `iojs ../get.BingAerial.js 39.304    -4.147    39.328    -4.130    15 | awk 'BEGIN{FS=","}{print $1}'` 
#    `iojs ../get.BingAerial.js 39.327    -4.262    39.366    -4.235    15 | awk 'BEGIN{FS=","}{print $1}'` 
#    `iojs ../get.BingAerial.js 39.240627 -4.288781 39.530792 -4.064113 15 | awk 'BEGIN{FS=","}{print $1}'` 

for TEST_QKEY in 300110331111121 300110331111123; do
    export TILESVRT=tileList/$ZLEVEL/Z$ZLEVEL-$TEST_QKEY.vrt
    export TILES=tileList/$ZLEVEL/Z$ZLEVEL-$TEST_QKEY.lst
    export TRAINING_QKEY=$TEST_QKEY
    make -rR $TILES

    cat $TILES | xargs parallel --jobs 64 --joblog logs/cnnclassify.sub.nsample.conf.sh.$ZLEVEL.$NSAMPLE.$TEST_QKEY.`date +"%F_%T"` ./cnnclassify.sub.nsample.conf.sh :::
done

rm -f $TARGET_TMP
exit 0
