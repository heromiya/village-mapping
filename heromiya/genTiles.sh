#! /bin/bash

ZLEVEL=17 # Tile size is 307 x 307 m
PREREQ="var tilebelt = require('tilebelt');"
DB=geonames.sqlite

#:<<'#EOF'
spatialite $DB <<EOF
DELETE FROM geometry_columns WHERE f_table_name = 'tiles';
DROP TABLE IF EXISTS tiles;
CREATE TABLE tiles (
	gid integer primary key AUTOINCREMENT,
	qkey varchar(64)
);
SELECT AddGeometryColumn('tiles', 'the_geom' ,4326, 'POLYGON', 'XY');
EOF

for ROI in `cat ROI.lst | head -n 1`; do
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
#EOF

spatialite $DB <<EOF
DELETE FROM geometry_columns WHERE f_table_name = 'target_tiles';
DROP TABLE IF EXISTS target_tiles;
CREATE TABLE target_tiles (
	gid integer primary key AUTOINCREMENT,
	qkey varchar(64)
);
SELECT AddGeometryColumn('target_tiles', 'the_geom' ,4326, 'POLYGON', 'XY');
INSERT INTO target_tiles (qkey, the_geom) SELECT DISTINCT tiles.qkey,tiles.the_geom FROM tiles,geonames_ppl WHERE ST_Intersects(tiles.the_geom,geonames_ppl.the_geom_buf);


DELETE FROM geometry_columns WHERE f_table_name = 'target_tiles_la';
DROP TABLE IF EXISTS target_tiles_la;
CREATE TABLE target_tiles_la (
	gid integer primary key AUTOINCREMENT,
	qkey varchar(64)
);
SELECT AddGeometryColumn('target_tiles_la', 'the_geom' ,4326, 'POLYGON', 'XY');
INSERT INTO target_tiles_la (qkey, the_geom) SELECT DISTINCT tiles.qkey,tiles.the_geom FROM tiles,geonames_ppl WHERE ST_Intersects(tiles.the_geom,geonames_ppl.the_geom_buf) AND geonames_ppl.country_code = 'LA';

DELETE FROM geometry_columns WHERE f_table_name = 'target_tiles_th';
DROP TABLE IF EXISTS target_tiles_th;
CREATE TABLE target_tiles_th (
	gid integer primary key AUTOINCREMENT,
	qkey varchar(64)
);
SELECT AddGeometryColumn('target_tiles_th', 'the_geom' ,4326, 'POLYGON', 'XY');
INSERT INTO target_tiles_th (qkey, the_geom) SELECT DISTINCT tiles.qkey,tiles.the_geom FROM tiles,geonames_ppl WHERE ST_Intersects(tiles.the_geom,geonames_ppl.the_geom_buf) AND geonames_ppl.country_code = 'TH';

DELETE FROM geometry_columns WHERE f_table_name = 'target_tiles_ke';
DROP TABLE IF EXISTS target_tiles_ke;
CREATE TABLE target_tiles_ke (
	gid integer primary key AUTOINCREMENT,
	qkey varchar(64)
);
SELECT AddGeometryColumn('target_tiles_ke', 'the_geom' ,4326, 'POLYGON', 'XY');
INSERT INTO target_tiles_ke (qkey, the_geom) SELECT DISTINCT tiles.qkey,tiles.the_geom FROM tiles,geonames_ppl WHERE ST_Intersects(tiles.the_geom,geonames_ppl.the_geom_buf) AND geonames_ppl.country_code = 'KE';

DELETE FROM geometry_columns WHERE f_table_name = 'target_tiles_mm';
DROP TABLE IF EXISTS target_tiles_mm;
CREATE TABLE target_tiles_mm (
	gid integer primary key AUTOINCREMENT,
	qkey varchar(64)
);
SELECT AddGeometryColumn('target_tiles_mm', 'the_geom' ,4326, 'POLYGON', 'XY');
INSERT INTO target_tiles_mm (qkey, the_geom) SELECT DISTINCT tiles.qkey,tiles.the_geom FROM tiles,geonames_ppl WHERE ST_Intersects(tiles.the_geom,geonames_ppl.the_geom_buf) AND geonames_ppl.country_code = 'MM';

EOF

ogr2ogr -overwrite target_tiles geonames.sqlite target_tiles_la target_tiles_th target_tiles_ke target_tiles_mm
exit 0
