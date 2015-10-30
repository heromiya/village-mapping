CENTER=$1
X_CENTER=`echo $CENTER | cut -f 1 -d "|"`
Y_CENTER=`echo $CENTER | cut -f 2 -d "|"`
rm -f sample_tmp/${X_CENTER}_${Y_CENTER}_input_coords.txt
RANGE=`seq -$(echo "$WINSIZE / 2" | bc) $(echo "$WINSIZE / 2 - 1" | bc)`


for X_SHIFT in $RANGE;do
    for Y_SHIFT in $RANGE; do
	echo `echo "$X_CENTER + $X_SHIFT * $XRES" | bc` `echo "$Y_CENTER + $Y_SHIFT * $YRES" | bc` >> sample_tmp/${X_CENTER}_${Y_CENTER}_input_coords.txt
    done
done

parallel -j 3 "r.what input=bing.{} cache=1000 < sample_tmp/${X_CENTER}_${Y_CENTER}_input_coords.txt | awk 'BEGIN{FS=\"|\"; ORS=\"|\"}{print \$4}' > sample_tmp/${X_CENTER}_${Y_CENTER}_{}.txt" ::: 1 2 3

echo "${X_CENTER}|${Y_CENTER}|${MASKVAL}" > sample_tmp/${X_CENTER}_${Y_CENTER}_idx.txt
paste -d "|" sample_tmp/${X_CENTER}_${Y_CENTER}_idx.txt \
    sample_tmp/${X_CENTER}_${Y_CENTER}_1.txt \
    sample_tmp/${X_CENTER}_${Y_CENTER}_2.txt \
    sample_tmp/${X_CENTER}_${Y_CENTER}_3.txt \
    | sed 's/||/|/g; s/|$//g' > sample_tmp/${X_CENTER}_${Y_CENTER}_merge.txt
