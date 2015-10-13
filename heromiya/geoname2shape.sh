#! /bin/bash

spatialite geonames.sqlite <<EOF
DELETE FROM geometry_columns;
DROP TABLE IF EXISTS geonames_ppl ;
CREATE TABLE geonames_ppl (
	geonameid integer,
	name varchar(200),
	asciiname varchar(200),
	alternatenames varchar(10000),
	latitude double precision,
	longitude double precision,
	feature_class char(1),
	feature_code varchar(10),
	country_code char(2),
	cc2 varchar(200),
	admin1_code varchar(20),
	admin2_code varchar(80),
	admin3_code varchar(20),
	admin4_code varchar(20),
	population integer,
	elevation integer,
	dem integer,
	timezone varchar(40),
	modification_date varchar(10)
);
DELETE FROM geometry_columns WHERE f_table_name = 'geonames_ppl';
SELECT AddGeometryColumn('geonames_ppl', 'the_geom' ,4326, 'POINT', 'XY');
SELECT AddGeometryColumn('geonames_ppl', 'the_geom_buf' ,4326, 'POLYGON', 'XY');

DROP TABLE IF EXISTS savannakhet;
DROP TABLE IF EXISTS ubon_rachathani;
DROP TABLE IF EXISTS ratchaburi;
DROP TABLE IF EXISTS xepon;

.loadshp ../Data/targetExtents/Savannakhet savannakhet UTF-8 4326
.loadshp ../Data/targetExtents/Ubon_Rachathani ubon_rachathani UTF-8 4326
.loadshp ../Data/targetExtents/Ratchaburi ratchaburi UTF-8 4326
.loadshp ../Data/targetExtents/Xepon xepon UTF-8 4326
.loadshp ../Data/targetExtents/Kwale_Area kwale UTF-8 4326

DROP TABLE IF EXISTS target_extent;
CREATE TABLE target_extent (
	gid integer primary key AUTOINCREMENT
);
SELECT AddGeometryColumn('target_extent', 'the_geom' ,4326, 'POLYGON', 'XY');

INSERT INTO target_extent (the_geom) SELECT geometry from savannakhet;
INSERT INTO target_extent (the_geom) SELECT geometry from ubon_rachathani;
INSERT INTO target_extent (the_geom) SELECT geometry from ratchaburi;
INSERT INTO target_extent (the_geom) SELECT geometry from xepon;
INSERT INTO target_extent (the_geom) SELECT geometry from kwale;

EOF

for TXT in ../Data/geonames/LA/LA.txt ../Data/geonames/TH/TH.txt ../Data/geonames/KE/KE.txt; do
	TABNAME=geonames_`basename $TXT | sed 's/\.txt//g'`
#`echo $TXT | sed 's/\.txt/\.sqlite/g'`
	spatialite geonames.sqlite  <<EOF
DROP TABLE IF EXISTS $TABNAME ;
CREATE TABLE $TABNAME (
	geonameid integer,
	name varchar(200),
	asciiname varchar(200),
	alternatenames varchar(10000),
	latitude double precision,
	longitude double precision,
	feature_class char(1),
	feature_code varchar(10),
	country_code char(2),
	cc2 varchar(200),
	admin1_code varchar(20),
	admin2_code varchar(80),
	admin3_code varchar(20),
	admin4_code varchar(20),
	population integer,
	elevation integer,
	dem integer,
	timezone varchar(40),
	modification_date varchar(10)
);
.separator \t
.import '$TXT' $TABNAME
DELETE FROM geometry_columns WHERE f_table_name = '`echo $TABNAME| tr A-Z a-z`';
SELECT AddGeometryColumn('$TABNAME', 'the_geom' ,4326, 'POINT', 'XY');
UPDATE $TABNAME SET the_geom = MakePoint(longitude, latitude,4326);

INSERT INTO geonames_ppl
SELECT *
     ,ST_Buffer(the_geom, 0.0041666667)
FROM $TABNAME
WHERE feature_code = 'PPL'
  AND ST_Intersects( the_geom
                   , (SELECT ST_Union(the_geom) FROM target_extent)
				   )
;
EOF

done

exit 0
