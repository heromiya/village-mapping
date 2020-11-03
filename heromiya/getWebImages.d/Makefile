FORMAT = tif
#GMap/$(FORMAT)/$(ZLEVEL)/$(TILEX)/Z$(ZLEVEL).$(TILEX).$(TILEY).$(FORMAT):
GMap/$(LAYER_NAME)/$(ZLEVEL)/$(TILEX)/Z$(ZLEVEL).$(TILEX).$(TILEY).tif:
	mkdir -p `dirname $@`
	wget -q -O $(WORKDIR)/Z$(ZLEVEL).$(TILEX).$(TILEY).tmp.tif "http://hawaii.csis.u-tokyo.ac.jp:3857/service?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&LAYERS=$(LAYER_NAME)&STYLES=&FORMAT=image/geotiff&CRS=EPSG:3857&BBOX=$(TILE_XMIN),$(TILE_YMIN),$(TILE_XMAX),$(TILE_YMAX)&WIDTH=$(WIDTH)&HEIGHT=$(HEIGHT)"
	gdal_translate -q -co compress=deflate $(WORKDIR)/Z$(ZLEVEL).$(TILEX).$(TILEY).tmp.tif $@

GMap/$(LAYER_NAME)/$(ZLEVEL)/$(TILEX)/Z$(ZLEVEL).$(TILEX).$(TILEY).tif.info: GMap/$(LAYER_NAME)/$(ZLEVEL)/$(TILEX)/Z$(ZLEVEL).$(TILEX).$(TILEY).tif
	mkdir -p `dirname $@`
	gdalinfo -mm -stats -hist -checksum -proj4 $< > $@ 2>&1

Bing/jpeg/$(ZLEVEL)/a$(QKEY).jpeg:
	mkdir -p `dirname $@`
	wget --no-check-certificate -O $@ "https://t2.ssl.ak.tiles.virtualearth.net/tiles/a$(QKEY).jpeg?g=3653"
Bing/gtiff/$(ZLEVEL)/a$(QKEY).tif: Bing/jpeg/$(ZLEVEL)/a$(QKEY).jpeg
	mkdir -p `dirname $@`
	gdal_translate -a_ullr $(XMIN) $(YMAX) $(XMAX) $(YMIN) -a_srs EPSG:3857 -co COMPRESS=Deflate $< $@
Bing/gtiff/$(ZLEVEL)/a$(QKEY).tif.info: Bing/gtiff/$(ZLEVEL)/a$(QKEY).tif
	mkdir -p `dirname $@`
	gdalinfo -mm -stats -hist -checksum -proj4 $< > $@ 2>&1


$(MERGEDTILE): $(MERGEINPUT)
	mkdir -p `dirname $@`
	gdalwarp -q -co compress=deflate $+ $@

completedSamples.d/completedSamples.$(GADM_GID).Z$(ZLEVEL).lst:
	psql -h guam -d suvannaket -Atc "SELECT qkey from grid_$(ZLEVEL) where ST_Intersects(geom, (SELECT wkb_geometry FROM gadm36_level1 WHERE gid_1 ='$(GADM_GID)'));" | sort | uniq > $@
