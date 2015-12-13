clear;
close all;
addpath(genpath('DeepLearnToolbox'));
#pkg load parallel;

arg_list = argv();
WINSIZE = str2num(arg_list{1});
INPUT=arg_list{2};
KNOWLEDGE=arg_list{3};
OUTPUT=arg_list{4};

in = imread(INPUT);
D1RANGE = size(in,1)-WINSIZE+1;
D2RANGE = size(in,2)-WINSIZE+1;

function test_data = mymerge1 (d2,d1,in,WINSIZE)
  D1CELLS=d1-WINSIZE/2:d1+(WINSIZE/2-1);
  D2CELLS=d2-WINSIZE/2:d2+(WINSIZE/2-1);
  test_data = horzcat(in(D1CELLS, D2CELLS,1),in(D1CELLS, D2CELLS,2),in(D1CELLS, D2CELLS,3));
endfunction;

for d1 = WINSIZE/2+1 : size(in,1) - (WINSIZE/2 - 1)
  for d2 = WINSIZE/2+1 : size(in,2) - (WINSIZE/2 - 1)
    test_x(1:WINSIZE,1:WINSIZE*3,(d2 - (WINSIZE/2+1)) + 1 + (d1 - (WINSIZE/2+1)) * D2RANGE) = mymerge1(d2,d1,in,WINSIZE);
  end;
end;

test_x = (double(test_x)-127)/128;

load(KNOWLEDGE);
cnn = cnnff(cnn, test_x);
[~, h] = max(cnn.o);
outimg = vertcat( zeros( WINSIZE/2, size(in,2) ), horzcat( zeros(D1RANGE,WINSIZE/2), reshape(uint8(h),[ size(in,1)-WINSIZE+1 size(in,2)-WINSIZE+1 ]) , zeros(D1RANGE,WINSIZE/2-1) ), zeros( WINSIZE/2-1, size(in,2)));

imwrite(fliplr(rot90(outimg,-1)),OUTPUT);
