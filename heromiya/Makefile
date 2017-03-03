FORMAT = png
GMap/$(FORMAT)/$(ZLEVEL)/Z$(ZLEVEL).$(TILEX).$(TILEY).$(FORMAT):
	mkdir -p `dirname $@`
	wget -nc -O $@ "http://localhost:3857/service?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&BBOX=$(TILE_XMIN),$(TILE_YMIN),$(TILE_XMAX),$(TILE_YMAX)&SRS=EPSG:3857&WIDTH=$(WIDTH)&HEIGHT=$(HEIGHT)&LAYERS=Google%20Maps%20Satellite&STYLES=&FORMAT=image/$(FORMAT)"
#	wget --no-check-certificate -nc -O $@ "https://mt0.google.com/vt/lyrs=s@0&hl=en&x=$(TILEX)&y=$(TILEY)&z=$(ZLEVEL)"

GMap/gtiff/$(ZLEVEL)/Z$(ZLEVEL).$(TILEX).$(TILEY).tif: GMap/$(FORMAT)/$(ZLEVEL)/Z$(ZLEVEL).$(TILEX).$(TILEY).$(FORMAT)
	mkdir -p `dirname $@`
	gdal_translate -a_srs EPSG:3857 -a_ullr $(TILE_XMIN) $(TILE_YMAX) $(TILE_XMAX) $(TILE_YMIN) -co COMPRESS=Deflate -expand rgb $< $@

GMap/gtiff/$(ZLEVEL)/Z$(ZLEVEL).$(TILEX).$(TILEY).tif.info: GMap/gtiff/$(ZLEVEL)/Z$(ZLEVEL).$(TILEX).$(TILEY).tif
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
	gdalwarp $+ $@
