#! /bin/bash
CENTER=$1

X_CENTER=`echo $CENTER | cut -f 1 -d "|"`
Y_CENTER=`echo $CENTER | cut -f 2 -d "|"`
BASENAME=sample_tmp/${ZLEVEL}/Z${ZLEVEL}-${TRAINING_QKEY}-${MASKVAL}-${X_CENTER}_${Y_CENTER}

rm -f ${BASENAME}.input_coords.txt
RANGE=`seq -$(echo "$WINSIZE / 2" | bc) $(echo "$WINSIZE / 2 - 1" | bc)`

r.what input=bing.1,bing.2,bing.3 cache=30000 east_north=`for Y_SHIFT in $RANGE;do for X_SHIFT in $RANGE; do printf "%lf,%lf," $(echo "$X_CENTER + $X_SHIFT * $XRES" | bc) $(echo "$Y_CENTER + $Y_SHIFT * $YRES" | bc); done; done | sed 's/,$//g'` > $BASENAME.txt

BAND1=`awk 'BEGIN{FS="|"; ORS="|"}{print $4}' $BASENAME.txt`
BAND2=`awk 'BEGIN{FS="|"; ORS="|"}{print $5}' $BASENAME.txt`
BAND3=`awk 'BEGIN{FS="|"; ORS="|"}{print $6}' $BASENAME.txt`

echo "${X_CENTER}|${Y_CENTER}|${MASKVAL}|${BAND1}|${BAND2}|${BAND3}" | sed 's/||/|/g; s/|$//g' > ${BASENAME}_merge.txt

exit 0
