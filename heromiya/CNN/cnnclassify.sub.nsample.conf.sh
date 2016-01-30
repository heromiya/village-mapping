export TARGETTILE=$1
export TRAINING_DATA=
export TILE_QKEY=$(echo $1 | sed "s/..\/Bing\/gtiff\/${ZLEVEL}\/a//g; s/\.tif//g")
#export CNNOUTPUT=$(echo $1 | sed "s/..\/Bing\/gtiff\/${ZLEVEL}\/a/cnnresult\/${ZLEVEL}\/Z${ZLEVEL}-a/g; s/\.tif/\.cnnresult\.tif/g")
#export CNNPROJ=${ZLEVEL}/$(echo $1   | sed "s/..\/Bing\/gtiff\/${ZLEVEL}\/a/cnnproj\/${ZLEVEL}\/Z${ZLEVEL}-a/g; s/\.tif/\.cnnproj\.tif/g")
mkdir -p cnnresult/${ZLEVEL}/${NSAMPLE}
mkdir -p cnnproj/${ZLEVEL}/${NSAMPLE}
mkdir -p cnninput/${ZLEVEL}/${NSAMPLE}
#export CNNOUTPUT=cnnresult/${ZLEVEL}/${NSAMPLE}/Z${ZLEVEL}-${NSAMPLE}-a${TILE_QKEY}.cnnresult-road_test.tif
#export CNNPROJ=cnnproj/${ZLEVEL}/${NSAMPLE}/Z${ZLEVEL}-${NSAMPLE}-a${TILE_QKEY}.cnnproj-road_test.tif

export CNNOUTPUT=cnnresult/${ZLEVEL}/${NSAMPLE}/Z${ZLEVEL}-${NSAMPLE}-a${TILE_QKEY}.cnnresult.tif
export CNNPROJ=cnnproj/${ZLEVEL}/${NSAMPLE}/Z${ZLEVEL}-${NSAMPLE}-a${TILE_QKEY}.cnnproj.tif
export CNNINPUT=cnninput/${ZLEVEL}/Z${ZLEVEL}-${TILE_QKEY}.tif

make -rR $CNNINPUT $CNNOUTPUT $CNNPROJ
