getGoogleMaps() {
    LONMIN=$1
    LONMAX=$2
    LATMIN=$3
    LATMAX=$4
    NAME=$5

    XYMIN=($(echo $LONMIN $LATMIN | proj +proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs))
    XYMAX=($(echo $LONMAX $LATMAX | proj +proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs))

    gdal_translate -co BIGTIFF=YES -co compress=deflate -tr 0.2986 0.2986 -a_srs EPSG:3857 -projwin ${XYMIN[0]} ${XYMAX[1]} ${XYMAX[0]} ${XYMIN[1]} GoogleMapsSatellite200712.xml GoogleMapsSatellite200712-${NAME}.tif

 #   "WMS:http://hawaii.csis.u-tokyo.ac.jp:3857/service?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&LAYERS=GoogleMapsSatellite200712&SRS=EPSG:900913&BBOX=-20037508.3428,-20037508.3428,20037508.3428,20037508.3428" 
}

#gdalbuildvrt -overwrite GoogleMapsSatellite200712.vrt "WMTS:http://hawaii.csis.u-tokyo.ac.jp:3857/wmts/1.0.0/WMTSCapabilities.xml,layer=GoogleMapsSatellite200712"
#getGoogleMaps 34.7 35.2 -19.9 -19.6 Maputo
getGoogleMaps 32.4 32.7 -26.1 -25.7 Matola
#getGoogleMaps 34.7 35.2 -19.9 -19.6 Beira
