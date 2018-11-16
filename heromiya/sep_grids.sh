#! /bin/bash

TMPSQL=/dev/shm/tmp.sql
rm -f $TMPSQL

echo "DELETE FROM grid_17;"
for QKEY in $(psql suvannaket -qAtc "select qkey from grid where validate = 2 limit 3"); do
    for i in $(seq 1 4); do
	for j in $(seq 1 4); do
	    CHILDQKEY=${QKEY}${i}${j}
	    GEOM=$(echo "var tilebelt=require('@mapbox/tilebelt');console.log(tilebelt.tileToBBOX(tilebelt.quadkeyToTile('$CHILDQKEY')))" | node | sed 's/\[/ST_MakeEnvelope(/; s/\]/, 4326)/')
	    echo "INSERT INTO grid_17 (qkey, geom) VALUES ('$CHILDQKEY', $GEOM );" >> $TMPSQL 
	done
    done  
done
psql  suvannaket $TMPSQL
exit 0
