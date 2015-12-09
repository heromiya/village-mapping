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
  test_data = cat(2,in(YCELLS, XCELLS,1),in(YCELLS, XCELLS,2),in(YCELLS, XCELLS,3));
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

#test_x = cell(WINSIZE,WINSIZE*18,10);
for y = WINSIZE/2+1 : size(in,1) - (WINSIZE/2 - 1)
#  printf('%d %s\n',y,asctime(localtime(time)));
  for x = WINSIZE/2+1 : size(in,2) - (WINSIZE/2 - 1)
    test_x(1:WINSIZE,1:WINSIZE*3,(x - (WINSIZE/2+1)) + 1 + (y - (WINSIZE/2+1)) * XRANGE) = mymerge1(x,y,in,WINSIZE);
  end;
end;

#for i = 1:XRANGE*YRANGE
#for i = 1:3
    #test_x(1:WINSIZE,1:WINSIZE*3,i) = mymerge2(i);
#    mymerge2(i)
#    printf('%d\n',i);
#end;

#output=pararrayfun(2,@(k)mymerge2(k),[1,2,3]);

#test_x(WINSIZE,WINSIZE*3,1:100)
#test_x = (double(test_x)-127)/128;

load KNOWLEDGE;
cnn = cnnff(cnn, test_x);
[~, h] = max(cnn.o);

imwrite(reshape (h,[ size(in,1)-WINSIZE+1 size(in,2)-WINSIZE+1 ]),OUTPUT);



#    test_x(:,:,1+(XRANGE*(y-1)):XRANGE+(XRANGE*(y-1))) = parcellfun (50, mymerge, WINSIZE/2+1 : size(in,2) - (WINSIZE/2 - 1));
#	tmp = in(y-WINSIZE/2:y+(WINSIZE/2-1), x-WINSIZE/2:x+(WINSIZE/2-1),:);
