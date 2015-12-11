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

sample_tmp/Z$(ZLEVEL)-$(TRAINING_QKEY)-$(MASKVAL)_merge.txt: $(TILESVRT).tif
	g.region n=$(YMAX) s=$(YMIN) e=$(XMAX) w=$(XMIN) nsres=$(YRES) ewres=$(XRES) --overwrite && \
	r.mask -o input=gt_rast maskcats=$(MASKVAL) && \
	g.region n=n-$(YINC) s=s+$(YINC) e=e-$(XINC) w=w+$(XINC) nsres=$(YRES) ewres=$(XRES) --overwrite && \
	g.remove -f vect=gt_sample_$(MASKVAL) && \
	r.random input=gt_rast n=$(NSAMPLE) vector_output=gt_sample_$(MASKVAL) --overwrite --quiet && \
	g.region n=$(YMAX) s=$(YMIN) e=$(XMAX) w=$(XMIN) nsres=$(YRES) ewres=$(XRES) --overwrite && \
	r.mask -r  --overwrite --quiet && \
	v.db.addtable   map=gt_sample_$(MASKVAL) layer=2 table=gt_sample_$(MASKVAL) columns='cat integer'  --overwrite --quiet && \
	v.db.connect -o map=gt_sample_$(MASKVAL) layer=2 table=gt_sample_$(MASKVAL)  --overwrite --quiet && \
	v.db.addcol     map=gt_sample_$(MASKVAL) layer=2 columns='x double precision, y double precision'  --overwrite --quiet && \
	v.to.db         map=gt_sample_$(MASKVAL) layer=1 type=point option=coor columns='x,y' --overwrite --quiet && \
	v.db.select -c  map=gt_sample_$(MASKVAL) layer=2 columns=x,y | xargs parallel --jobs 20% ./collect_sample.sh ::: && \
	cat sample_tmp/Z$(ZLEVEL)-$(TRAINING_QKEY)-$(MASKVAL)-*_merge.txt > $@

$(CNNINPUT):
	gdalwarp -te $(XMIN) $(YMIN) $(XMAX) $(YMAX) -tr $(XRES) $(YRES) -wm 2048 -multi -q -co COMPRESS=Deflate -overwrite `iojs ../get.BingAerial.js $(QLONMIN) $(QLATMIN) $(QLONMAX) $(QLATMAX) $(ZLEVEL) | awk -v zlevel=$(ZLEVEL) 'BEGIN{FS=","}{printf("../Bing/gtiff/%d/a%s.tif ",zlevel,$$1)}'` $@

$(CNNOUTPUT): $(CNNINPUT)
	octave $(OCTAVEOPT) cnnclassify.m $(WINSIZE) $< $(KNOWLEDGE) $@

$(CNNPROJ): $(CNNOUTPUT)
	BB=`iojs inqTileBB.js $(TILE_QKEY)` && \
	LONMIN=`echo $$BB | cut -f 1 -d '|'` && \
	LATMIN=`echo $$BB | cut -f 2 -d '|'` && \
	LONMAX=`echo $$BB | cut -f 3 -d '|'` && \
	LATMAX=`echo $$BB | cut -f 4 -d '|'` && \
	XMIN=$$(echo $${LONMIN} $${LATMIN} | cs2cs $(EPSG4326) +to $(EPSG3857) | awk '{print $$1}') && \
	YMIN=$$(echo $${LONMIN} $${LATMIN} | cs2cs $(EPSG4326) +to $(EPSG3857) | awk '{print $$2}') && \
	XMAX=$$(echo $${LONMAX} $${LATMAX} | cs2cs $(EPSG4326) +to $(EPSG3857) | awk '{print $$1}') && \
	YMAX=$$(echo $${LONMAX} $${LATMAX} | cs2cs $(EPSG4326) +to $(EPSG3857) | awk '{print $$2}') && \
	gdal_translate -a_srs EPSG:3857 -a_ullr $$XMIN $$YMAX $$XMAX $$YMIN -co COMPRESS=Deflate $< $@

#	XMIN=`echo "$$(echo $${LONMIN} $${LATMIN} | cs2cs $(EPSG4326) +to $(EPSG3857) | awk '{print $$1}') + $(WINSIZE) / 2 * $(XRES)" |bc` && \
	YMIN=`echo "$$(echo $${LONMIN} $${LATMIN} | cs2cs $(EPSG4326) +to $(EPSG3857) | awk '{print $$2}') + $(WINSIZE) / 2 * $(YRES)" |bc` && \
	XMAX=`echo "$$(echo $${LONMAX} $${LATMAX} | cs2cs $(EPSG4326) +to $(EPSG3857) | awk '{print $$1}') - ($(WINSIZE) / 2 - 1) * $(XRES)"|bc` && \
	YMAX=`echo "$$(echo $${LONMAX} $${LATMAX} | cs2cs $(EPSG4326) +to $(EPSG3857) | awk '{print $$2}') - ($(WINSIZE) / 2 - 1) * $(YRES)"|bc` && \
