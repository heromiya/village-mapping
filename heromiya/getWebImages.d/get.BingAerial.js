// the inputs are in Long/Lat

var LONMIN=parseFloat(process.argv[2]);
var LATMIN=parseFloat(process.argv[3]);
var LONMAX=parseFloat(process.argv[4]);
var LATMAX=parseFloat(process.argv[5]);
var ZLEVEL=parseInt(process.argv[6]);

var tilebelt = require('tilebelt');
var XYMIN = tilebelt.pointToTile(LONMIN, LATMAX, ZLEVEL);
var XYMAX = tilebelt.pointToTile(LONMAX, LATMIN, ZLEVEL);

for (tilex = XYMIN[0]; tilex <= XYMAX[0]; tilex++) {
    for (tiley = XYMIN[1]; tiley <= XYMAX[1]; tiley++) {
	process.stdout.write(tilebelt.tileToQuadkey([tilex, tiley, ZLEVEL]) + ',' + tilebelt.tileToBBOX([tilex, tiley, ZLEVEL]) + '\n');
    }
}
