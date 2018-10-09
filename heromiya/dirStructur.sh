#! /bin/bash
ZLEVEL=17
for TYPE in gtiff png; do
    cd GMap/$TYPE/$ZLEVEL
    find -maxdepth 1 -type f | sed "s/\.[0-9]*\.[a-z]..//g; s/\.\/Z$ZLEVEL\.//g;" | uniq > /tmp/dir.lst

    for DIR in `cat /tmp/dir.lst`; do
#	echo $DIR
	mkdir -p $DIR
	mv ./Z$ZLEVEL.$DIR.* $DIR/
    done
    cd ../../../
done

exit
