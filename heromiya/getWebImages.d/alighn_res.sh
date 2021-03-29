#! /bin/bash

IN=$1
WORKDIR=$(mktemp -d)
gdal_translate -q -tr 0.2986 0.2986 -co compress=jpeg -co jpeg_quality=100 $IN $WORKDIR/tmp.tif
cp $WORKDIR/tmp.tif $IN
rm -rf $WORKDIR

