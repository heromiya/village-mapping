#find Bing/gtiff/17/ -type f | grep tif$ | parallel --jobs 8 ./validateGTiffs.sub.sh :::

#pexec -f input_list.lst -e IN -n 20 -o log.output.validateGTiffs.sh -u log.error.validateGTiffs.sh -c -- "export ZLEVEL=`echo $IN | sed 's#Bing/gtiff/\([0-9].\)/a\([0-9]*\).tif#\1#g'`; export QKEY=`echo $IN | sed 's#Bing/gtiff/\([0-9].\)/a\([0-9]*\).tif#\2#g'`; make $IN.info"

find Bing/gtiff/17/ -type f | grep tif$ > input_list.lst
#cat input_list.lst | parallel -j 30 --joblog validateGTiff.sh.log "export ZLEVEL=`echo {} | sed 's#Bing/gtiff/\([0-9].\)/a\([0-9]*\).tif#\1#g'`; export QKEY=`echo {} | sed 's#Bing/gtiff/\([0-9].\)/a\([0-9]*\).tif#\2#g'`; make {}.info" :::
cat input_list.lst | parallel -j 30 --joblog validateGTiff.sh.log "if [ ! -e {}.info ]; then gdalinfo -mm -stats -hist -checksum -proj4 {} > {}.info 2>&1; fi" :::

exit 0
