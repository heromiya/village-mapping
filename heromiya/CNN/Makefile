completedSamples.lst: ../../Data/groundTruth/*.xlsx
	for f in $+; do xlsx2csv -a $$f | sed 's/^[0-9],//g; s/^[0-9].,//g; s/^[0-9]..,//g; s/^[0-9]...,//g' | grep ^[0-9] | awk 'BEGIN{FS=","}/C/{printf("%s\n",$$1)}'; done | sort | uniq > $@

#	for f in $+; do for s in `ogrinfo $$f | grep "^[0-9]:" | cut -f 2 -d " "`; do in2csv --sheet $$s $$f | sed 's/^[0-9],//g; s/^[0-9].,//g; s/^[0-9]..,//g; s/^[0-9]...,//g' | grep ^[0-9] | awk 'BEGIN{FS=","}/C/{print $$1}'; done; done | sort | uniq > $@

$(TILESVRT).tif: $(TILESVRT)
	gdal_translate -co Compress=Deflate $< $@

$(TILES):
	BB=`iojs inqTileBB.js $(TRAINING_QKEY)` && \
	LONMIN=$$(echo "`echo $$BB | cut -f 1 -d '|'` + 0.0001" | bc) && \
	LATMIN=$$(echo "`echo $$BB | cut -f 2 -d '|'` + 0.0001" | bc) && \
	LONMAX=$$(echo "`echo $$BB | cut -f 3 -d '|'` - 0.0001" | bc) && \
	LATMAX=$$(echo "`echo $$BB | cut -f 4 -d '|'` - 0.0001" | bc) && \
	for ARGS in `iojs ../get.BingAerial.js $$LONMIN $$LATMIN $$LONMAX $$LATMAX $$ZLEVEL`; do \
	cd .. && \
	QKEY=`echo $${ARGS} | cut -d ',' -f 1` && \
	TLATMIN=`echo $${ARGS} |cut -d ',' -f 2` && \
	TLONMIN=`echo $${ARGS} |cut -d ',' -f 3` && \
	TLATMAX=`echo $${ARGS} |cut -d ',' -f 4` && \
	TLONMAX=`echo $${ARGS} |cut -d ',' -f 5` && \
	XMIN=`echo $${TLATMIN} $${TLONMIN} | cs2cs $(EPSG4326) +to $(EPSG3857) | awk '{print $$1}'` && \
	YMIN=`echo $${TLATMIN} $${TLONMIN} | cs2cs $(EPSG4326) +to $(EPSG3857) | awk '{print $$2}'` && \
	XMAX=`echo $${TLATMAX} $${TLONMAX} | cs2cs $(EPSG4326) +to $(EPSG3857) | awk '{print $$1}'` && \
	YMAX=`echo $${TLATMAX} $${TLONMAX} | cs2cs $(EPSG4326) +to $(EPSG3857) | awk '{print $$2}'` && \
	export QKEY XMIN YMIN XMAX YMAX && \
	make -rR Bing/gtiff/$(ZLEVEL)/a$$QKEY.tif && \
	cd CNN && \
	if [ `stat -c "%s" ../Bing/gtiff/$(ZLEVEL)/a$$QKEY.tif` -ne 3169 ]; then echo ../Bing/gtiff/$(ZLEVEL)/a$$QKEY.tif >> $@; fi; done
$(TILESVRT): $(TILES)
	gdalbuildvrt -overwrite -input_file_list $< $@
$(TILESVRT).info: $(TILESVRT).tif
	gdalinfo $< > $@ 

YINC = $(shell echo $(YRES) \* $(WINSIZE) / 2 + 1 | bc)
XINC = $(shell echo $(XRES) \* $(WINSIZE) / 2 + 1 | bc)

groundTruth.sqlite: ../../Data/groundTruth/*.sqlite
	for f in $+; do ogr2ogr -append -f SQLite -a_srs "EPSG:3857" -dsco "SPATIALITE=YES" $@ $$f -nln working_polygon -nlt PROMOTE_TO_MULTI working_polygon; done && \
	for f in ../../Data/cloud/*.sqlite; do ogr2ogr -append -f SQLite -a_srs "EPSG:3857" -dsco "SPATIALITE=YES" $@ $$f -nln cloud -nlt PROMOTE_TO_MULTI cloud; done &&  \
	echo "CREATE TABLE gt_merge (id INTEGER PRIMARY KEY, flag INTEGER); SELECT AddGeometryColumn ('gt_merge','geometry',3857,'GEOMETRY',2); INSERT INTO gt_merge (geometry,flag) SELECT UnaryUnion(ST_Collect(MakeValid(geometry))) as geometry,CASE WHEN flag = '0' THEN '2' ELSE flag END FROM working_polygon GROUP BY flag;" | spatialite $@ && \
	echo "CREATE TABLE cloud_merge (id INTEGER PRIMARY KEY, flag INTEGER); SELECT AddGeometryColumn ('cloud_merge','geometry',3857,'GEOMETRY',2); INSERT INTO cloud_merge (geometry,flag) SELECT UnaryUnion(ST_Collect(MakeValid(geometry))) as geometry,'2' FROM cloud;" | spatialite $@

groundTruth/$(ZLEVEL)/GT-Z$(ZLEVEL)-$(TRAINING_QKEY).tif: groundTruth.sqlite
	mkdir -p `dirname  $@`
	gdal_rasterize -init 2 -a flag -l working_polygon -a_srs "EPSG:3857" -co COMPRESS=Deflate -te $(XMIN) $(YMIN) $(XMAX) $(YMAX) -tr $(XRES) $(YRES) -ot Byte groundTruth.sqlite $< /dev/shm/heromiya/working_polygon_$(ZLEVEL)_$(TRAINING_QKEY).tif && \
	gdal_rasterize -init 2 -burn 0 -l cloud -a_srs "EPSG:3857" -co COMPRESS=Deflate -te $(XMIN) $(YMIN) $(XMAX) $(YMAX) -tr $(XRES) $(YRES) -ot Byte groundTruth.sqlite $< /dev/shm/heromiya/cloud_$(ZLEVEL)_$(TRAINING_QKEY).tif && \
	gdal_calc.py -A /dev/shm/heromiya/working_polygon_$(ZLEVEL)_$(TRAINING_QKEY).tif -B /dev/shm/heromiya/cloud_$(ZLEVEL)_$(TRAINING_QKEY).tif --calc="minimum(A,B)" --outfile=$@ --type=Byte --co=COMPRESS=Deflate --overwrite

sample_tmp/$(ZLEVEL)/$(NSAMPLE)/Z$(ZLEVEL)-$(TRAINING_QKEY)-$(MASKVAL)_$(NSAMPLE)_merge_allcoords.txt: $(TILESVRT).tif groundTruth.sqlite
	r.in.gdal -ok input=$< output=bing --overwrite --quiet && \
	v.in.ogr -o dsn=groundTruth.sqlite output=work_$(ZLEVEL)_$(TRAINING_QKEY)  spatial=$(XMIN),$(YMIN),$(XMAX),$(YMAX) layer=working_polygon type=boundary --overwrite && \
	v.in.ogr -o dsn=groundTruth.sqlite output=cloud_$(ZLEVEL)_$(TRAINING_QKEY) spatial=$(XMIN),$(YMIN),$(XMAX),$(YMAX) layer=cloud           type=boundary --overwrite && \
	v.to.rast input=work_$(ZLEVEL)_$(TRAINING_QKEY)  type=area output=work_rast_$(ZLEVEL)_$(TRAINING_QKEY)  use=val --overwrite --quiet && \
	v.to.rast input=cloud_$(ZLEVEL)_$(TRAINING_QKEY) type=area output=cloud_rast_$(ZLEVEL)_$(TRAINING_QKEY) use=val --overwrite --quiet && \
	r.null map=work_rast_$(ZLEVEL)_$(TRAINING_QKEY) null=0 --overwrite --quiet && \
	r.mapcalc "gt_rast_$(ZLEVEL)_$(TRAINING_QKEY) = if(cloud_$(ZLEVEL)_$(TRAINING_QKEY) == 2, 2, work_$(ZLEVEL)_$(TRAINING_QKEY))" && \
	g.region n=$(YMAX) s=$(YMIN) e=$(XMAX) w=$(XMIN) nsres=$(YRES) ewres=$(XRES) --overwrite && \
	r.mask -o input=gt_rast_$(ZLEVEL)_$(TRAINING_QKEY) maskcats=$(MASKVAL) && \
	g.region n=n-$(YINC) s=s+$(YINC) e=e-$(XINC) w=w+$(XINC) nsres=$(YRES) ewres=$(XRES) --overwrite && \
	g.remove -f vect=gt_sample_$(MASKVAL)_$(ZLEVEL)_$(TRAINING_QKEY) && \
	CELLNUM=`r.stats -cn MASK | cut -f 2 -d " "` && if [ $$CELLNUM -gt $(NSAMPLE) ]; then SAMPLENUM=$(NSAMPLE); else SAMPLENUM=100%; fi && \
	if [ -n "$$CELLNUM" ]; then r.random input=gt_rast_$(ZLEVEL)_$(TRAINING_QKEY) n=$$SAMPLENUM vector_output=gt_sample_$(MASKVAL)_$(ZLEVEL)_$(TRAINING_QKEY) --overwrite --quiet && \
	g.region n=$(YMAX) s=$(YMIN) e=$(XMAX) w=$(XMIN) nsres=$(YRES) ewres=$(XRES) --overwrite && \
	r.mask -r  --overwrite --quiet && \
	v.db.addtable   map=gt_sample_$(MASKVAL)_$(ZLEVEL)_$(TRAINING_QKEY) layer=2 table=gt_sample_$(MASKVAL)_$(ZLEVEL)_$(TRAINING_QKEY) columns='cat integer'  --overwrite --quiet && \
	v.db.connect -o map=gt_sample_$(MASKVAL)_$(ZLEVEL)_$(TRAINING_QKEY) layer=2 table=gt_sample_$(MASKVAL)_$(ZLEVEL)_$(TRAINING_QKEY)  --overwrite --quiet && \
	v.db.addcol     map=gt_sample_$(MASKVAL)_$(ZLEVEL)_$(TRAINING_QKEY) layer=2 columns='x double precision, y double precision'  --overwrite --quiet && \
	v.to.db         map=gt_sample_$(MASKVAL)_$(ZLEVEL)_$(TRAINING_QKEY) layer=1 type=point option=coor columns='x,y' --overwrite --quiet && \
	v.db.select -c  map=gt_sample_$(MASKVAL)_$(ZLEVEL)_$(TRAINING_QKEY) layer=2 columns=x,y > sample_tmp/$(ZLEVEL)/$(NSAMPLE)/Z$(ZLEVEL)-$(TRAINING_QKEY)-$(MASKVAL)_$(NSAMPLE).lst && \
	cat sample_tmp/$(ZLEVEL)/$(NSAMPLE)/Z$(ZLEVEL)-$(TRAINING_QKEY)-$(MASKVAL)_$(NSAMPLE).lst | xargs parallel --jobs 20% ./collect_sample.sh ::: && \
	cat `awk 'BEGIN{FS="|"}{printf("sample_tmp/$(ZLEVEL)/Z$(ZLEVEL)-$(TRAINING_QKEY)-$(MASKVAL)-%s_%s_merge.txt ",$$1,$$2)}' sample_tmp/$(ZLEVEL)/$(NSAMPLE)/Z$(ZLEVEL)-$(TRAINING_QKEY)-$(MASKVAL)_$(NSAMPLE).lst` > $@; fi

#$(TRAINING_DATA): sample_tmp/$(ZLEVEL)/$(NSAMPLE)/Z$(ZLEVEL)-*_$(NSAMPLE)_merge_allcoords.txt	
$(TRAINING_DATA): $(TRAINING_SRC)
	cat $+ | grep -v \* | sed 's/||/|/g; s/|$$//g' > $@

$(KNOWLEDGE): $(TRAINING_DATA)
	octave $(OCTAVEOPT) buildKnowledgeBase.m $(WINSIZE) $< $@

define init_coords
PixelSize=`gdalinfo $(TARGETTILE) | grep "Pixel Size"` && \
export XRES=`echo $$PixelSize | sed 's/.*(\([0-9.]*\),-\([0-9.]*\))/\1/'` && \
export YRES=`echo $$PixelSize | sed 's/.*(\([0-9.]*\),-\([0-9.]*\))/\2/'` && \
BB=`iojs inqTileBB.js $(TILE_QKEY)` && \
export LONMIN=`echo $$BB | cut -f 1 -d '|'` && \
export LATMIN=`echo $$BB | cut -f 2 -d '|'` && \
export LONMAX=`echo $$BB | cut -f 3 -d '|'` && \
export LATMAX=`echo $$BB | cut -f 4 -d '|'` && \
export QLONMIN=`echo "$$LONMIN - 0.0001" | bc` && \
export QLATMIN=`echo "$$LATMIN - 0.0001" | bc` && \
export QLONMAX=`echo "$$LONMAX + 0.0001" | bc` && \
export QLATMAX=`echo "$$LATMAX + 0.0001" | bc` && \
export XMIN=$$(echo "`echo $$LONMIN $$LATMIN | cs2cs $(EPSG4326) +to $(EPSG3857) | awk '{print $$1}'` - $$XRES * ($(WINSIZE)/2-1)" | bc) && \
export YMIN=$$(echo "`echo $$LONMIN $$LATMIN | cs2cs $(EPSG4326) +to $(EPSG3857) | awk '{print $$2}'` - $$YRES * ($(WINSIZE)/2-1)" | bc) && \
export XMAX=$$(echo "`echo $$LONMAX $$LATMAX | cs2cs $(EPSG4326) +to $(EPSG3857) | awk '{print $$1}'` + $$XRES * ($(WINSIZE)/2+1)" | bc) && \
export YMAX=$$(echo "`echo $$LONMAX $$LATMAX | cs2cs $(EPSG4326) +to $(EPSG3857) | awk '{print $$2}'` + $$YRES * ($(WINSIZE)/2+1)" | bc)
endef

$(CNNINPUT):
	$(init_coords) && cd .. && iojs get.BingAerial.js $$QLONMIN $$QLATMIN $$QLONMAX $$QLATMAX $$ZLEVEL | xargs parallel --joblog log.txt --jobs 10% "./get.Bing.Aerial.Sub.sh" ::: && cd CNN && \
	gdalwarp -te $$XMIN $$YMIN $$XMAX $$YMAX -tr $$XRES $$YRES -wm 2048 -multi -q -co COMPRESS=Deflate -overwrite `iojs ../get.BingAerial.js $$QLONMIN $$QLATMIN $$QLONMAX $$QLATMAX $(ZLEVEL) | awk -v zlevel=$(ZLEVEL) 'BEGIN{FS=","}{printf("../Bing/gtiff/%d/a%s.tif ",zlevel,$$1)}'` $@

$(CNNOUTPUT): $(CNNINPUT) $(KNOWLEDGE)
	octave $(OCTAVEOPT) cnnclassify.m $(WINSIZE) $< $(KNOWLEDGE) $@

$(CNNPROJ): $(CNNOUTPUT)
	$(init_coords) && gdal_translate -a_srs EPSG:3857 -a_ullr $$XMIN $$YMAX $$XMAX $$YMIN -a_nodata 0 -co COMPRESS=Deflate $< $@
