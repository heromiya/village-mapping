#! /bin/bash

source setenv.sh
export ZLEVEL=17
export WINSIZE=18
export NSAMPLE=1000
export NPROCESS=8

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

#East Yangon
export TARGET_EXTENT="96.1425 16.7656 96.3683 17.0239"
#Savannakhet
#export TARGET_EXTENT="104.733 15.8764 106.798 17.1136"
#Kwale|39.2406|-4.28878|39.5308|-4.06411

make completedSamples.lst
TARGET_TMP=`mktemp`
iojs ../get.BingAerial.js $TARGET_EXTENT 15 | awk 'BEGIN{FS=","}{print $1}' > $TARGET_TMP

:<<'#EOF'
for TRAINING_QKEY in `grep -Ff completedSamples.lst $TARGET_TMP`; do
    export TRAINING_QKEY
    export TILES=tileList/$ZLEVEL/Z$ZLEVEL-$TRAINING_QKEY.lst
    export TILESVRT=tileList/$ZLEVEL/Z$ZLEVEL-$TRAINING_QKEY.vrt
    make $TILES $TILESVRT.tif $TILESVRT.info

    export XMIN=`grep "Upper Left"  $TILESVRT.info | sed 's/^.*(\([-.0-9 ]*\),\([-.0-9 ]*\)) .*/\1/g; s/ //g'`
    export YMIN=`grep "Lower Right" $TILESVRT.info | sed 's/^.*(\([-.0-9 ]*\),\([-.0-9 ]*\)) .*/\2/g; s/ //g'`
    export XMAX=`grep "Lower Right" $TILESVRT.info | sed 's/^.*(\([-.0-9 ]*\),\([-.0-9 ]*\)) .*/\1/g; s/ //g'`
    export YMAX=`grep "Upper Left"  $TILESVRT.info | sed 's/^.*(\([-.0-9 ]*\),\([-.0-9 ]*\)) .*/\2/g; s/ //g'`

    export XRES=`grep "Pixel Size"  $TILESVRT.info | sed 's/.*(\([-.0-9]*\),\([-.0-9]*\))/\1/'`
    export YRES=`grep "Pixel Size"  $TILESVRT.info | sed 's/.*(\([-.0-9]*\),\([-.0-9]*\))/\2/; s/-//'`

    g.region n=$YMAX s=$YMIN e=$XMAX w=$XMIN nsres=$YRES ewres=$XRES --overwrite --quiet

    r.mask -r
    for MASKVAL in 0 1; do
	export MASKVAL
	make -rR sample_tmp/${ZLEVEL}/${NSAMPLE}/Z${ZLEVEL}-${TRAINING_QKEY}-${MASKVAL}_${NSAMPLE}_merge_allcoords.txt
    done
done

export TRAINING_SRC="`grep -Ff completedSamples.lst $TARGET_TMP | awk -v zlevel=$ZLEVEL -v nsample=$NSAMPLE '{printf(\"sample_tmp/%s/%s/Z%s-%s-0_%s_merge_allcoords.txt sample_tmp/%s/%s/Z%s-%s-1_%s_merge_allcoords.txt \",zlevel,nsample,zlevel,$1,nsample,zlevel,nsample,zlevel,$1,nsample)}'`"
export TRAINING_DATA=training_data/Z${ZLEVEL}-training_data-$NSAMPLE-`echo $TARGET_EXTENT | sed 's/ /_/g'`.csv
export KNOWLEDGE=knowledgebase/Z${ZLEVEL}-knowledgebase.$NSAMPLE-`echo $TARGET_EXTENT | sed 's/ /_/g'`.mat
make -rR $TRAINING_DATA $KNOWLEDGE
#EOF
export KNOWLEDGE=knowledgebase/Z${ZLEVEL}-knowledgebase.$NSAMPLE-`echo $TARGET_EXTENT | sed 's/ /_/g'`.mat

#    `iojs ../get.BingAerial.js 39.304    -4.147    39.328    -4.130    15 | awk 'BEGIN{FS=","}{print $1}'`
#    `iojs ../get.BingAerial.js 39.327    -4.262    39.366    -4.235    15 | awk 'BEGIN{FS=","}{print $1}'`
#    `iojs ../get.BingAerial.js 39.240627 -4.288781 39.530792 -4.064113 15 | awk 'BEGIN{FS=","}{print $1}'`

#iojs ../get.BingAerial.js $TARGET_EXTENT 15 | sort -r | awk 'BEGIN{FS=","}{print $1}' | parallel --jobs ${NPROCESS} ./cnnclassify.test_qkey.sub.sh :::
iojs ../get.BingAerial.js $TARGET_EXTENT 15| awk 'BEGIN{FS=","}{print $1}' | \
    parallel --jobs ${NPROCESS} \
	     --joblog logs/cnnclassify.sub.nsample.conf.sh-`date +"%F_%T"` \
	     'export TILESVRT=tileList/$ZLEVEL/Z$ZLEVEL-{}.vrt; export TILES=tileList/$ZLEVEL/Z$ZLEVEL-{}.lst; export TRAINING_QKEY={}; make -rR $TILES; for TILE in $(cat $TILES); do ./cnnclassify.sub.nsample.conf.sh $TILE; done' :::

:<<'#EOF'
for QKEY in `iojs ../get.BingAerial.js $TARGET_EXTENT 15| awk 'BEGIN{FS=","}{print $1}'`; do
    export TILESVRT=tileList/$ZLEVEL/Z$ZLEVEL-${QKEY}.vrt
    export TILES=tileList/$ZLEVEL/Z$ZLEVEL-${QKEY}.lst
    export TRAINING_QKEY=${QKEY}
    make -rR $TILES
    for TILE in $(cat $TILES); do ./cnnclassify.sub.nsample.conf.sh $TILE; done
done
#EOF

rm -f $TARGET_TMP
exit 0
