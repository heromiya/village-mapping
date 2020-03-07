#! /bin/bash
#HOST=18IA1107@login.t3.gsic.titech.ac.jp
HOST=miyazaki@sakurag04.cw503.net

rm -f /home/heromiya/public_html/suvannaket.sqlite

ogr2ogr -overwrite -f SQLite -dsco SPATIALITE=YES /home/heromiya/public_html/suvannaket.sqlite "PG:dbname=suvannaket host=guam"

rsync -azP /home/heromiya/public_html/suvannaket.sqlite $HOST:~/suvannaket.sqlite


exit 0
