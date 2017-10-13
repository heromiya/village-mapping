INSERT INTO working_polygon (GEOMETRY , id, flag,time)  SELECT GEOMETRY,0,1,date() from multipolygons  where building = 'yes';;

