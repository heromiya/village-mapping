clear;
close all;
addpath(genpath('DeepLearnToolbox'));

WINSIZE=18;
opts = [];
opts.alpha = 1;
opts.batchsize = 2;
opts.numepochs = 3;


load cnnknowledgebase;
in = imread('tmp_bing.tif');

i=1;
for y =     WINSIZE/2+1 : size(in,1) - (WINSIZE/2-1)
    for x = WINSIZE/2+1 : size(in,2) - (WINSIZE/2-1)
	test_src(i,:) = in(y-WINSIZE/2:y+(WINSIZE/2-1), x-WINSIZE/2:x+(WINSIZE/2-1),:)(:);
	i++;
    end;
end;


for i = 1:size(test_src,1)
  test_x(:,:,i) = reshape(test_src(i,1:end), [ WINSIZE * 3 WINSIZE ]);
end;

cnn = cnnff(cnn, test_x);
[~, h] = max(cnn.o);
imwrite(h,'test.tif');
