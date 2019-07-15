#! /bin/bash
#HOST=18IA1107@login.t3.gsic.titech.ac.jp
HOST=miyazaki@sakurag04.cw503.net

rm -f $HOME/public_html/suvannaket.sqlite

ogr2ogr -overwrite -f SQLite -dsco SPATIALITE=YES $HOME/public_html/suvannaket.sqlite "PG:dbname=suvannaket host=guam"

rsync -azP $HOME/public_html/suvannaket.sqlite $HOST:~/suvannaket.sqlite


exit 0
