for GADM_GID in LAO.12_1; do
    for ZLEVEL in 17 18; do
	./genTilePoints.sh $GADM_GID $ZLEVEL
    done
done
exit 0

		  
