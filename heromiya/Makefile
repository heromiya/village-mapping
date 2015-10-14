$(ZLEVEL)/Z$(ZLEVEL).$(TILEX).$(TILEY).png:
	wget --no-check-certificate -nc -O $@ "http://localhost:3857/service?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&BBOX=$(TILE_XMIN),$(TILE_YMIN),$(TILE_XMAX),$(TILE_YMAX)&SRS=EPSG:3857&WIDTH=$(WIDTH)&HEIGHT=$(HEIGHT)&LAYERS=Google%20Maps%20Satellite&STYLES=&FORMAT=image/png"

$(ZLEVEL)/Z$(ZLEVEL).$(TILEX).$(TILEY).tif: $(ZLEVEL)/Z$(ZLEVEL).$(TILEX).$(TILEY).png
	gdal_translate -a_srs EPSG:3857 -a_ullr $(TILE_XMIN) $(TILE_YMAX) $(TILE_XMAX) $(TILE_YMIN) -co COMPRESS=Deflate -expand rgb $< $@

Bing/jpeg/$(ZLEVEL)/a$(QKEY).jpeg:
	mkdir -p `dirname $@`
	wget --no-check-certificate -O $@ "https://t2.ssl.ak.tiles.virtualearth.net/tiles/a$(QKEY).jpeg?g=3653"
Bing/gtiff/$(ZLEVEL)/a$(QKEY).tif: Bing/jpeg/$(ZLEVEL)/a$(QKEY).jpeg
	mkdir -p `dirname $@`
	gdal_translate -a_ullr $(XMIN) $(YMAX) $(XMAX) $(YMIN) -a_srs EPSG:3857 -co COMPRESS=Deflate $< $@
