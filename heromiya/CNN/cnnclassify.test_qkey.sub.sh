#! /bin/bash

TEST_QKEY=$1
export TILESVRT=tileList/$ZLEVEL/Z$ZLEVEL-$TEST_QKEY.vrt
export TILES=tileList/$ZLEVEL/Z$ZLEVEL-$TEST_QKEY.lst
export TRAINING_QKEY=$TEST_QKEY
make -rR $TILES 
cat $TILES | parallel --jobs 4 --joblog logs/cnnclassify.sub.nsample.conf.sh.$ZLEVEL.$NSAMPLE.$TEST_QKEY.`date +"%F_%T"` ./cnnclassify.sub.nsample.conf.sh :::

exit 0
