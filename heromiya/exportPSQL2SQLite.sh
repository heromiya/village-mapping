#! /bin/bash

rm -f $HOME/public_html/suvannaket.sqlite
ogr2ogr -overwrite -f SQLite -dsco SPATIALITE=YES $HOME/public_html/suvannaket.sqlite "PG:dbname=suvannaket"
rsync -azP $HOME/public_html/suvannaket.sqlite 18IA1107@login.t3.gsic.titech.ac.jp:~/miyazaki/suvannaket.sqlite

exit 0
