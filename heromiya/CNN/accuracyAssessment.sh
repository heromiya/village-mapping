#! /bin/bash

export GRASS_MESSAGE_FORMAT=silent
export GRASS_OVERWRITE=1
export GRASS_VERBOSE=0
export ZLEVEL=18

TARGET_TILES="300110331111121 300110331111123"

for RESULT in cnnproj cnnproj-road_test; do
    r.mask -r
    for TILES in $TARGET_TILES; do sed 's#../Bing/gtiff/18/a##; s#.tif##' tileList/18/Z18-${TILES}.lst | awk -v result=$RESULT '{printf("cnnproj/18/100/Z18-100-a%s.%s.tif\n",$1,result)}'; done > Kwale-${RESULT}.lst
    gdalbuildvrt -q -a_srs "EPSG:3857" -input_file_list Kwale-${RESULT}.lst -overwrite Kwale-${RESULT}.vrt
    CLASSRASTNAME=`echo Kwale_${RESULT} | sed 's/-/_/g'`
    r.in.gdal -ok input=Kwale-${RESULT}.vrt output=$CLASSRASTNAME memory=2048 
    g.region rast=$CLASSRASTNAME
    eval `g.region -g`
    v.in.ogr -o dsn=groundTruth.sqlite output=work_${ZLEVEL}  spatial=${w},${s},${e},${n} layer=gt_merge type=boundary
    v.in.ogr -o dsn=groundTruth.sqlite output=cloud_${ZLEVEL} spatial=${w},${s},${e},${n} layer=cloud_merge type=boundary
    v.in.ogr -o dsn=groundTruth.sqlite output=road_${ZLEVEL}  spatial=${w},${s},${e},${n} layer=road_merge type=boundary
    v.to.rast input=work_${ZLEVEL}  type=area output=work_rast_${ZLEVEL}  use=attr column=flag 
    v.to.rast input=cloud_${ZLEVEL} type=area output=cloud_rast_${ZLEVEL} use=attr column=flag 
    v.to.rast input=road_${ZLEVEL}  type=area output=road_rast_${ZLEVEL}  use=attr column=flag
    r.null map=work_rast_${ZLEVEL} null=0
    r.null map=road_rast_${ZLEVEL} null=0
    if [ $RESULT = cnnproj-road_test ];then
	r.mapcalc "gt_rast_${ZLEVEL}_cnnproj_road_test = if(isnull(cloud_rast_${ZLEVEL}), if(road_rast_${ZLEVEL}==3,3,if(work_rast_${ZLEVEL}==0,2,if(work_rast_${ZLEVEL}==2,0,1))),0)"
    else
	r.mapcalc "gt_rast_${ZLEVEL}_${RESULT} = if(isnull(cloud_rast_${ZLEVEL}), if(work_rast_${ZLEVEL}==0,2,if(work_rast_${ZLEVEL}==2,0,1)),0)"
    fi
    r.mask -io input=`echo gt_rast_${ZLEVEL}_${RESULT} | sed 's/-/_/g'` maskcats=0 
    r.kappa -w classification=$CLASSRASTNAME reference=`echo gt_rast_${ZLEVEL}_${RESULT} | sed 's/-/_/g'` output=r.kappa.${RESULT}
    r.mask -r
    r.out.gdal -c input=`echo gt_rast_${ZLEVEL}_${RESULT} | sed 's/-/_/g'` type=Byte output=gt_rast_${ZLEVEL}_${RESULT}.tif createopt="COMPRESS=Deflate" 
done

r.mask -io input=gt_rast_${ZLEVEL}_cnnproj_road_test maskcats=0 
r.mapcalc "gt_rast_${ZLEVEL}_cnnproj_road_mod = if(gt_rast_${ZLEVEL}_cnnproj_road_test == 3 , 2, gt_rast_${ZLEVEL}_cnnproj_road_test)"
r.mapcalc "Kwale_cnnproj_road_test_mod = if(Kwale_cnnproj_road_test == 3 , 2, Kwale_cnnproj_road_test)"
r.kappa -w classification=Kwale_cnnproj_road_test_mod reference=gt_rast_${ZLEVEL}_cnnproj_road_mod output=r.kappa.cnnproj_road_test_mod
    r.mask -r

exit 0


