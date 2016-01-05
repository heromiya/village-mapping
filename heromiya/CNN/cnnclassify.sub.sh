export TARGETTILE=$1
export TRAINING_DATA=
export TILE_QKEY=$(echo $1 | sed "s/..\/Bing\/gtiff\/${ZLEVEL}\/a//g; s/\.tif//g")
#export CNNOUTPUT=$(echo $1 | sed "s/..\/Bing\/gtiff\/${ZLEVEL}\/a/cnnresult\/${ZLEVEL}\/Z${ZLEVEL}-a/g; s/\.tif/\.cnnresult\.tif/g")
#export CNNPROJ=${ZLEVEL}/$(echo $1   | sed "s/..\/Bing\/gtiff\/${ZLEVEL}\/a/cnnproj\/${ZLEVEL}\/Z${ZLEVEL}-a/g; s/\.tif/\.cnnproj\.tif/g")

export CNNINPUT=cnninput/${ZLEVEL}/Z${ZLEVEL}-${TILE_QKEY}.tif

mkdir -p cnnresult/${ZLEVEL}/EY
export CNNOUTPUT=cnnresult/${ZLEVEL}/EY/Z${ZLEVEL}-${NSAMPLE}-a${TILE_QKEY}.cnnresult.tif

mkdir -p cnnproj/${ZLEVEL}/EY
export CNNPROJ=cnnproj/${ZLEVEL}/EY/Z${ZLEVEL}-${NSAMPLE}-a${TILE_QKEY}.cnnproj.tif

make -rR $CNNINPUT $CNNOUTPUT $CNNPROJ
