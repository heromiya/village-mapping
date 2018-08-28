#! /bin/bash

for TYPE in gtiff png; do
    cd GMap/$TYPE/18
    find -maxdepth 1 -type f | sed 's/\.[0-9]*\.[a-z]..//g; s/\.\/Z18\.//g;' | uniq > dir.lst

    for DIR in `cat dir.lst`; do
	echo $DIR
	mkdir $DIR
	mv ./Z18.$DIR.* $DIR/
    done
    cd ../../../
done

exit