#! /bin/bash

export ZLEVEL=18
export EPSG4326="+proj=longlat +datum=WGS84 +no_defs"
export EPSG3857="+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs"

make completedSamples.lst
TARGET_TMP=`mktemp`
iojs ../get.BingAerial.js 39.240627 -4.288781 39.530792 -4.064113 15 | awk 'BEGIN{FS=","}{print $1}' > $TARGET_TMP

for QKEY in `grep -Ff completedSamples.lst $TARGET_TMP`; do
#for QKEY in 300111202222131; do
    GTIFF=`printf "tileList/18/Z18-%s.vrt.tif" $QKEY`
    export TILESVRT=`printf "tileList/18/Z18-%s.vrt" $QKEY`
    make $TILESVRT.tif $TILESVRT.info
    XMIN=`grep "Lower Left" $TILESVRT.info | sed 's/.*(.\([-.0-9]*\),.\([-.0-9]*\)).*/\1/'`
    YMIN=`grep "Lower Left" $TILESVRT.info | sed 's/.*(.\([-.0-9]*\),.\([-.0-9]*\)).*/\2/'`
    XMAX=`grep "Upper Right" $TILESVRT.info | sed 's/.*(.\([-.0-9]*\),.\([-.0-9]*\)).*/\1/'`
    YMAX=`grep "Upper Right" $TILESVRT.info | sed 's/.*(.\([-.0-9]*\),.\([-.0-9]*\)).*/\2/'`
    XRES=`grep "Pixel Size" $TILESVRT.info | sed 's/.*(\([.0-9]*\).,-\([.0-9]*\))/\1/'`
    YRES=`grep "Pixel Size" $TILESVRT.info | sed 's/.*(\([.0-9]*\).,-\([.0-9]*\))/\2/'`
    gdal_rasterize -l gt_merge    -a flag -init 0 -te $XMIN $YMIN $XMAX $YMAX -tr $XRES $YRES -ot Byte -q groundTruth.sqlite work${QKEY}.tif
    gdal_rasterize -l cloud_merge -a flag -init 0 -te $XMIN $YMIN $XMAX $YMAX -tr $XRES $YRES -ot Byte -q groundTruth.sqlite cloud${QKEY}.tif
    gdal_calc.py -A work${QKEY}.tif -B cloud${QKEY}.tif --calc="where(B==2,2,A)" --outfile=dataForShao/r${QKEY}-Z${ZLEVEL}.tif
    gdal_translate $TILESVRT.tif dataForShao/a${QKEY}-Z${ZLEVEL}.tif
    rm -f work${QKEY}.tif cloud${QKEY}.tif
done

exit 0
