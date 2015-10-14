# /bin/bash -x

XMIN=11647846.90790291503071785
XMAX=11899688.91161549836397171
YMIN=1775962.98947082902304828
YMAX=1948602.50795785989612341

NTILE=100
#for ZLEVEL in `seq 10 11`; do
for ZLEVEL in 17 18; do
    mkdir -p $ZLEVEL
    for TILEX in `seq 0 $(expr $NTILE - 1)`; do
	for TILEY in `seq 0 $(expr $NTILE - 1)`; do
	    TILE_XMIN=`echo "($XMAX - $XMIN)/$NTILE * $TILEX + $XMIN" | bc`
	    TILE_XMAX=`echo "($XMAX - $XMIN)/$NTILE * ($TILEX + 1) + $XMIN" | bc`
	    TILE_YMIN=`echo "($YMAX - $YMIN)/$NTILE * $TILEY + $YMIN" | bc`
	    TILE_YMAX=`echo "($YMAX - $YMIN)/$NTILE * ($TILEY + 1) + $YMIN" | bc`
	    WIDTH=`echo "1381*2^($ZLEVEL-10) / $NTILE" | bc`
	    HEIGHT=`echo "946*2^($ZLEVEL-10) / $NTILE" | bc`
	    export WIDTH HEIGHT ZLEVEL TILEX TILEY TILE_XMIN TILE_YMIN TILE_XMAX TILE_YMAX
	    make $ZLEVEL/Z$ZLEVEL.$TILEX.$TILEY.tif
	done
    done
    cd ..
done
