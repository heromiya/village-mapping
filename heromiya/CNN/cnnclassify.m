clear;
close all;
addpath(genpath('DeepLearnToolbox'));

WINSIZE=28;

load cnnknowledgebase;
in = imread('tmp_bing.tif');

i=1;
for y =     WINSIZE/2+1 : size(in,1) - (WINSIZE/2 - 1)
    for x = WINSIZE/2+1 : size(in,2) - (WINSIZE/2 - 1)
	tmp = in(y-WINSIZE/2:y+(WINSIZE/2-1), x-WINSIZE/2:x+(WINSIZE/2-1),:);
	test_x(:,:,i) = cat(2,tmp(:,:,1),tmp(:,:,2),tmp(:,:,3));
#	printf('%d\n',i);
	i++;
    end;
end;
test_x = double(test_x)/255;

cnn = cnnff(cnn, test_x);
[~, h] = max(cnn.o);

imwrite(reshape (h,[ size(in,1)-WINSIZE+1 size(in,2)-WINSIZE+1 ]),'test.tif');
save -binary cnnclassify.result
