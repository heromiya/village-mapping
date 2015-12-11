clear;
close all;
addpath(genpath('DeepLearnToolbox'));
pkg load parallel;

global arg_list = argv();
global WINSIZE = str2num(arg_list{1});
global INPUT=arg_list{2};
KNOWLEDGE=arg_list{3};
OUTPUT=arg_list{4};

global in = imread(INPUT);
global YRANGE = size(in,1)-WINSIZE+1;
global XRANGE = size(in,2)-WINSIZE+1;

function test_data = mymerge1 (x,y,in,WINSIZE)
  YCELLS=y-WINSIZE/2:y+(WINSIZE/2-1);
  XCELLS=x-WINSIZE/2:x+(WINSIZE/2-1);
  test_data = horzcat(in(YCELLS, XCELLS,1),in(YCELLS, XCELLS,2),in(YCELLS, XCELLS,3));
endfunction;

function test_data = mymerge2 (k)
  arg_list = argv();
  WINSIZE = str2num(arg_list{1});
  in = imread(arg_list{2});
  YRANGE = size(in,1)-WINSIZE+1;
  XRANGE = size(in,2)-WINSIZE+1;
  y = ceil(k / XRANGE) + WINSIZE / 2;
  x = k - (y-1-WINSIZE/2) * XRANGE + WINSIZE/2;
  YCELLS=y-WINSIZE/2:y+(WINSIZE/2-1);
  XCELLS=x-WINSIZE/2:x+(WINSIZE/2-1);
  test_data = cat(2,in(YCELLS, XCELLS,1),in(YCELLS, XCELLS,2),in(YCELLS, XCELLS,3))
endfunction

for y = WINSIZE/2+1 : size(in,1) - (WINSIZE/2 - 1)
  for x = WINSIZE/2+1 : size(in,2) - (WINSIZE/2 - 1)
    test_x(1:WINSIZE,1:WINSIZE*3,(x - (WINSIZE/2+1)) + 1 + (y - (WINSIZE/2+1)) * XRANGE) = mymerge1(x,y,in,WINSIZE);
  end;
end;

test_x = (double(test_x)-127)/128;

load KNOWLEDGE;
cnn = cnnff(cnn, test_x);
[~, h] = max(cnn.o);
outimg = reshape(h,[ size(in,1)-WINSIZE+1 size(in,2)-WINSIZE+1 ])),-1));
zeros(size(in,1),size(in,2));

imwrite(fliplr(rot90(uint8(      ),-1)),OUTPUT);
