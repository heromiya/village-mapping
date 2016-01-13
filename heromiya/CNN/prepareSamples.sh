#! /bin/bash
export ZLEVEL WINSIZE NSAMPLE EPSG4326 EPSG3857

export TRAINING_QKEY=$1
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
    make sample_tmp/${ZLEVEL}/Z${ZLEVEL}-${TRAINING_QKEY}-${MASKVAL}_merge_allcoords.txt
done

exit 0
