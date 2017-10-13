#! /bin/bash


cd GMap/gtiff/18
find -maxdepth 1 -type f | sed 's/\.[0-9]*\.tif//g; s/\.\/Z18\.//g;' | uniq > dir.lst

for DIR in `cat dir.lst`; do
    mkdir $DIR
    mv ./Z18.$DIR.*.tif $DIR/
done

exit
