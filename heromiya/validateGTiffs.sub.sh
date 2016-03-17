#! /bin/bash

FILE=$1
export ZLEVEL=`echo $FILE | sed 's#Bing/gtiff/\([0-9].\)/a\([0-9]*\).tif#\1#g'`
export QKEY=`echo $FILE | sed 's#Bing/gtiff/\([0-9].\)/a\([0-9]*\).tif#\2#g'`
make $FILE.info

#if [ -n "`gdalchksum.py $FILE | grep ^0$`" ]; then
#    rm $FILE
#    echo "$FILE is removed"
#fi
