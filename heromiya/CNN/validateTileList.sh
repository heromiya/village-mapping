#! /bin/bash

for TILELIST in tileList/18/*.lst; do
    L15QKEYFNAME=`echo $TILELIST | sed 's/tileList\/18\/Z18-\([0-9]*\)\.lst/\1/g'`
    L15QKEYLIST=`cat $TILELIST | sed 's/.*\([0-9]\{15\}\)[0-9]\{3\}.*/\1/g' | sort | uniq`

    if [ "$L15QKEYFNAME" = "$L15QKEYLIST" ]; then
	echo $L15QKEYFNAME true
    else
	echo $L15QKEYFNAME false
	rm $TILELIST
    fi
done

exit 0
