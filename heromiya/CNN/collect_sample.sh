CENTER=$1

X_CENTER=`echo $CENTER | cut -f 1 -d "|"`
Y_CENTER=`echo $CENTER | cut -f 2 -d "|"`
BASENAME=sample_tmp/${ZLEVEL}-${QKEY}-${X_CENTER}_${Y_CENTER}

rm -f ${BASENAME}.input_coords.txt
RANGE=`seq -$(echo "$WINSIZE / 2" | bc) $(echo "$WINSIZE / 2 - 1" | bc)`

for Y_SHIFT in $RANGE;do
    for X_SHIFT in $RANGE; do
	echo `echo "$X_CENTER + $X_SHIFT * $XRES" | bc` `echo "$Y_CENTER + $Y_SHIFT * $YRES" | bc` >> $BASENAME.input_coords.txt
    done
done

#rm sample_tmp/${X_CENTER}_${Y_CENTER}.txt

#for ARGS in `cat  sample_tmp/${X_CENTER}_${Y_CENTER}_input_coords.txt`; do
#    X=`echo $ARGS | cut -f 1 -d " "`
#    Y=`echo $ARGS | cut -f 2 -d " "`
#    gdallocationinfo -l_srs EPSG:3857 -valonly $TILESVRT.tif $X $Y | awk 'BEGIN{ORS="|"}{print}' >> sample_tmp/${X_CENTER}_${Y_CENTER}.txt
#done

r.what input=bing.1,bing.2,bing.3 cache=30000 < $BASENAME.input_coords.txt > sample_tmp/$BASENAME.txt

awk 'BEGIN{FS="|"; ORS="|"}{print $4}' $BASENAME.txt > ${BASENAME}_1.txt
awk 'BEGIN{FS="|"; ORS="|"}{print $5}' $BASENAME.txt > ${BASENAME}_2.txt
awk 'BEGIN{FS="|"; ORS="|"}{print $6}' $BASENAME.txt > ${BASENAME}_3.txt

echo "${X_CENTER}|${Y_CENTER}|${MASKVAL}" > ${BASENAME}_idx.txt
paste -d "|" ${BASENAME}_idx.txt \
    ${BASENAME}_1.txt \
    ${BASENAME}_2.txt \
    ${BASENAME}_3.txt \
    | sed 's/||/|/g; s/|$//g' > ${BASENAME}_merge.txt
