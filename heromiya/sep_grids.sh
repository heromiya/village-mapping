#! /bin/bash

TMPSQL=/dev/shm/tmp.sql
rm -f $TMPSQL

echo "DELETE FROM grid_18;" > $TMPSQL
for QKEY in $(psql suvannaket -qAtc "select qkey from grid_17 where validate = 2"); do
    for i in $(seq 1 4); do
	for j in $(seq 1 4); do
	    CHILDQKEY=${QKEY}${i}${j}
	    GEOM=$(echo "var tilebelt=require('@mapbox/tilebelt');console.log(tilebelt.tileToBBOX(tilebelt.quadkeyToTile('$CHILDQKEY')))" | node | sed 's/\[/ST_MakeEnvelope(/; s/\]/, 4326)/')
	    echo "INSERT INTO grid_18 (qkey, geom, validate) VALUES ('$CHILDQKEY', $GEOM, 2 );" >> $TMPSQL 
	done
    done  
done
psql  suvannaket -f $TMPSQL
exit 0
