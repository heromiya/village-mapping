#! /bin/bash

TMPSQL=/dev/shm/tmp.sql
rm -f $TMPSQL
ZLEVEL=18

echo "DELETE FROM grid_${ZLEVEL};" > $TMPSQL
for QKEY in $(psql suvannaket -qAtc "select qkey from grid_17 where validate = 2"); do
    for i in $(seq 0 3); do
	for j in $(seq 0 3); do
	    CHILDQKEY=${QKEY}${i}${j}
	    GEOM=$(echo "var tilebelt=require('@mapbox/tilebelt');console.log(tilebelt.tileToBBOX(tilebelt.quadkeyToTile('$CHILDQKEY')))" | node | sed 's/\[/ST_MakeEnvelope(/; s/\]/, 4326)/')
	    echo "INSERT INTO grid_${ZLEVEL} (qkey, geom, validate) VALUES ('$CHILDQKEY', $GEOM, 2 );" >> $TMPSQL 
	done
    done  
done
psql  suvannaket -f $TMPSQL
exit 0
