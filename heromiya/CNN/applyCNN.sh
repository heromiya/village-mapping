#! /bin/bash

#LONMIN=104.787
#LATMIN=16.568
#LONMAX=104.846
#LATMAX=16.611

LONMIN=99.703184
LATMIN=13.769068
LONMAX=99.703339
LATMAX=13.769164

export ZLEVEL=19
export WINSIZE=18
export NSAMPLE=1000

export EPSG4326="+proj=longlat +datum=WGS84 +no_defs"
export EPSG3857="+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs"

#ls -l | awk '$5 != 3169 { print $9 }' | grep -v -e '^$' -e 'txt' > Z19.txt
#gdalbuildvrt -input_file_list Z19.txt Z19.vrt
#:<<'#EOF'

rm -f tmp.txt
for ARGS in `iojs ../get.BingAerial.js $LONMIN $LATMIN $LONMAX $LATMAX $ZLEVEL`; do
    QKEY=`echo $ARGS | cut -d ',' -f 1`
    if [ `stat -c "%s" ../Bing/gtiff/$ZLEVEL/a${QKEY}.tif` -ne 3169 ]; then
	echo ../Bing/gtiff/$ZLEVEL/a${QKEY}.tif >> tmp.txt
    fi
done
gdalbuildvrt -overwrite -input_file_list tmp.txt tmp_bing.vrt
gdal_translate -co Compress=Deflate tmp_bing.vrt tmp_bing.tif
gdalinfo tmp_bing.vrt > tmp_bing.vrt.info
#EOF

export XMIN=`grep "Upper Left"  tmp_bing.vrt.info | sed 's/^Upper Left  (\([-.0-9]*\), \([-.0-9]*\)) .*/\1/g'`
export YMIN=`grep "Lower Right" tmp_bing.vrt.info | sed 's/^Lower Right (\([-.0-9]*\), \([-.0-9]*\)) .*/\2/g'`
export XMAX=`grep "Lower Right" tmp_bing.vrt.info | sed 's/^Lower Right (\([-.0-9]*\), \([-.0-9]*\)) .*/\1/g'`
export YMAX=`grep "Upper Left"  tmp_bing.vrt.info | sed 's/^Upper Left  (\([-.0-9]*\), \([-.0-9]*\)) .*/\2/g'`

export XRES=`grep "Pixel Size"  tmp_bing.vrt.info | sed 's/Pixel Size = (\([-.0-9]*\),\([-.0-9]*\))/\1/'`
export YRES=`grep "Pixel Size"  tmp_bing.vrt.info | sed 's/Pixel Size = (\([-.0-9]*\),\([-.0-9]*\))/\2/; s/-//'`
eval `g.gisenv`
#:<<'#EOF'
g.proj -c proj4="+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs <>"
g.region n=$YMAX s=$YMIN e=$XMAX w=$XMIN nsres=$YRES ewres=$XRES --overwrite
r.in.gdal -ok input=tmp_bing.tif output=bing --overwrite
db.connect driver=sqlite database=$GISDBASE/$LOCATION_NAME/$MAPSET/db.sqlite
v.in.ogr -o dsn=../working_polygon.sqlite output=gt layer=working_polygon type=boundary --overwrite --quiet
v.to.rast input=gt type=area output=gt_rast use=val --overwrite --quiet
r.null map=gt_rast null=0
#EOF

rm -rf sample_tmp
mkdir -p sample_tmp

r.mask -r
for MASKVAL in 0 1; do
    export MASKVAL
    g.region n=$YMAX s=$YMIN e=$XMAX w=$XMIN nsres=$YRES ewres=$XRES --overwrite
    r.mask -o input=gt_rast maskcats=$MASKVAL
    YINC=`echo $YRES \* $WINSIZE / 2 + 1 | bc`
    XINC=`echo $XRES \* $WINSIZE / 2 + 1 | bc`
    g.region n=n-$YINC s=s+$YINC e=e-$XINC w=w+$XINC nsres=$YRES ewres=$XRES --overwrite
    g.remove -f vect=gt_sample_$MASKVAL
    r.random  input=gt_rast n=$NSAMPLE vector_output=gt_sample_$MASKVAL --overwrite --quiet
    g.region n=$YMAX s=$YMIN e=$XMAX w=$XMIN nsres=$YRES ewres=$XRES --overwrite
    r.mask -r
    v.db.addtable   map=gt_sample_$MASKVAL layer=2 table=gt_sample_$MASKVAL columns='cat integer'
    v.db.connect -o map=gt_sample_$MASKVAL layer=2 table=gt_sample_$MASKVAL
    v.db.addcol     map=gt_sample_$MASKVAL layer=2 columns='x double precision, y double precision'
    v.to.db         map=gt_sample_$MASKVAL layer=1 type=point option=coor columns='x,y'
    v.db.select -c map=gt_sample_$MASKVAL layer=2 columns=x,y | xargs parallel --jobs 20% ./collect_sample.sh :::
done

cat sample_tmp/*_merge.txt | grep -v \* | sed 's/||/|/g; s/|$//g' > training_sample.txt

octave buildKnowledgeBase.m
octave cnnclassify.m

:<<EOF
#ls -l | awk '$5 != 3169 { print $9 }' | grep -v -e '^$' -e 'txt' > Z19.txt
#gdalbuildvrt -input_file_list Z19.txt Z19.vrt

    QKEY=`echo $ARGS | cut -d ',' -f 1`
    TLATMIN=`echo $ARGS |cut -d ',' -f 2`
    TLONMIN=`echo $ARGS |cut -d ',' -f 3`
    TLATMAX=`echo $ARGS |cut -d ',' -f 4`
    TLONMAX=`echo $ARGS |cut -d ',' -f 5`
    XMIN=`echo $LATMIN $LONMIN | cs2cs $EPSG4326 +to $EPSG3857 | awk '{print $1}'`
    YMIN=`echo $LATMIN $LONMIN | cs2cs $EPSG4326 +to $EPSG3857 | awk '{print $2}'`
    XMAX=`echo $LATMAX $LONMAX | cs2cs $EPSG4326 +to $EPSG3857 | awk '{print $1}'`
    YMAX=`echo $LATMAX $LONMAX | cs2cs $EPSG4326 +to $EPSG3857 | awk '{print $2}'`
    export QKEY XMIN YMIN XMAX YMAX
    
    gdalwarp -te $XMIN $YMIN $XMAX $YMAX -tr 

#done
EOF

exit 0
