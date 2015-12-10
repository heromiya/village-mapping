var QKEY=process.argv[2];
var tb = require('tilebelt');
bb=tb.tileToBBOX(tb.quadkeyToTile(QKEY));
process.stdout.write(bb[0]+'|'+bb[1]+'|'+bb[2]+'|'+bb[3]);
