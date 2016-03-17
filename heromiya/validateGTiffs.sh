find Bing/gtiff/17/ -type f | grep tif$ | parallel --jobs 8 ./validateGTiffs.sub.sh :::

exit 0
