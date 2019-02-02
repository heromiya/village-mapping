#! /bin/bash

function sub() {
    INQKEY=$1
    OUTSQL=$WORKDIR/$INQKEY.sql
    if [ ${#INQKEY} -eq $ZLEVEL ]; then	
	GEOM=$(echo "var tilebelt=require('@mapbox/tilebelt');console.log(tilebelt.tileToBBOX(tilebelt.quadkeyToTile('$INQKEY')))" | node | sed 's/\[/ST_MakeEnvelope(/; s/\]/, 4326)/')
	echo "INSERT INTO grid_${ZLEVEL} (qkey, geom, validate) VALUES ('$INQKEY', $GEOM, 2 );" > $OUTSQL 
    elif [ ${#INQKEY} -lt $ZLEVEL ]; then
	DIFF_ZLEVEL=$(expr $ZLEVEL - ${#INQKEY})
	for CHILD in $(parallel echo $(echo $(for i in $(seq 1 $DIFF_ZLEVEL); do printf "{$i}"; done) $(for i in $(seq 1 $DIFF_ZLEVEL); do printf " ::: 0 1 2 3"; done))); do
	    CHILDQKEY=${INQKEY}${CHILD}
	    GEOM=$(echo "var tilebelt=require('@mapbox/tilebelt');console.log(tilebelt.tileToBBOX(tilebelt.quadkeyToTile('$CHILDQKEY')))" | node | sed 's/\[/ST_MakeEnvelope(/; s/\]/, 4326)/')
	    echo "INSERT INTO grid_${ZLEVEL} (qkey, geom, validate) VALUES ('$CHILDQKEY', $GEOM, 2 );" > $OUTSQL 
	done
    fi
}

export -f sub

for ZLEVEL in 17 18; do
    export TMPSQL=/dev/shm/tmp${ZLEVEL}.sql
    rm -f $TMPSQL
    export ZLEVEL

    export WORKDIR=$(mktemp -d -p /dev/shm)
    parallel --nice 10 --progress sub {} ::: $(psql -h guam suvannaket -qAtc "select qkey from grid where validate = 2")
    echo "DROP TABLE IF EXISTS grid_${ZLEVEL}; CREATE TABLE grid_${ZLEVEL} (qkey varchar(254), validate smallint); SELECT AddGeometryColumn('grid_${ZLEVEL}','geom',4326,'Polygon',2);" > $TMPSQL
    cat $WORKDIR/*.sql >> $TMPSQL
    psql -q -h guam suvannaket -f $TMPSQL
    rm -rf $WORKDIR
done

exit 0
