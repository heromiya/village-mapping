#! /bin/bash

ZLEVEL=15 # Tile size is 1223 x 1223 m
PREREQ="var tilebelt = require('C:/Windows/System32/node_modules/tilebelt');"
DB=geonames.sqlite

spatialite $DB <<EOF
DELETE FROM geometry_columns WHERE f_table_name = 'tiles';
DROP TABLE IF EXISTS tiles;
CREATE TABLE tiles (
	gid integer primary key AUTOINCREMENT,
	qkey varchar(64)
);
SELECT AddGeometryColumn('tiles', 'the_geom' ,4326, 'POLYGON', 'XY');
EOF

for ROI in `cat ROI.lst`; do
	LONMIN=`echo $ROI | cut -f 2 -d '|'`
	LATMIN=`echo $ROI | cut -f 3 -d '|'`
	LONMAX=`echo $ROI | cut -f 4 -d '|'`
	LATMAX=`echo $ROI | cut -f 5 -d '|'`

	XTILEMIN=`iojs -e "$PREREQ Tile=tilebelt.pointToTile($LONMIN, $LATMIN, $ZLEVEL); process.stdout.write(String(Tile[0]))"`
	YTILEMAX=`iojs -e "$PREREQ Tile=tilebelt.pointToTile($LONMIN, $LATMIN, $ZLEVEL); process.stdout.write(String(Tile[1]))"`
	XTILEMAX=`iojs -e "$PREREQ Tile=tilebelt.pointToTile($LONMAX, $LATMAX, $ZLEVEL); process.stdout.write(String(Tile[0]))"`
	YTILEMIN=`iojs -e "$PREREQ Tile=tilebelt.pointToTile($LONMAX, $LATMAX, $ZLEVEL); process.stdout.write(String(Tile[1]))"`
	
	for XTILE in `seq $XTILEMIN $XTILEMAX`; do
		for YTILE in `seq $YTILEMIN $YTILEMAX`; do
			QKey=`iojs -e "$PREREQ process.stdout.write(String(tilebelt.tileToQuadkey([$XTILE,$YTILE,$ZLEVEL])))"`
			TILELONMIN=`iojs -e "$PREREQ BB=tilebelt.tileToBBOX([$XTILE,$YTILE,$ZLEVEL]); process.stdout.write(String(BB[0]))"`
			TILELATMIN=`iojs -e "$PREREQ BB=tilebelt.tileToBBOX([$XTILE,$YTILE,$ZLEVEL]); process.stdout.write(String(BB[1]))"`
			TILELONMAX=`iojs -e "$PREREQ BB=tilebelt.tileToBBOX([$XTILE,$YTILE,$ZLEVEL]); process.stdout.write(String(BB[2]))"`
			TILELATMAX=`iojs -e "$PREREQ BB=tilebelt.tileToBBOX([$XTILE,$YTILE,$ZLEVEL]); process.stdout.write(String(BB[3]))"`
			echo "INSERT INTO tiles (qkey, the_geom) VALUES ('$QKey',ST_GeomFromText('POLYGON (($TILELONMIN $TILELATMIN, $TILELONMIN $TILELATMAX, $TILELONMAX $TILELATMAX, $TILELONMAX $TILELATMIN, $TILELONMIN $TILELATMIN))', 4326));" | spatialite $DB
		done
	done
done

spatialite $DB <<EOF
DELETE FROM geometry_columns WHERE f_table_name = 'target_tiles';
DROP TABLE IF EXISTS target_tiles;
CREATE TABLE target_tiles (
	gid integer primary key AUTOINCREMENT,
	qkey varchar(64)
);
SELECT AddGeometryColumn('target_tiles', 'the_geom' ,4326, 'POLYGON', 'XY');
INSERT INTO target_tiles (qkey, the_geom) SELECT DISTINCT tiles.qkey,tiles.the_geom FROM tiles,geonames_ppl WHERE ST_Intersects(tiles.the_geom,geonames_ppl.the_geom_buf);
EOF

exit 0
