clear;
close all;
addpath(genpath('DeepLearnToolbox'));
WINSIZE=18;

train_src = dlmread("training_sample.txt","|",0,0);

for i = 1:size(train_src,1)
    R = double(reshape(train_src(i,4:(WINSIZE^2)+3), [ WINSIZE WINSIZE ])')/255;
    G = double(reshape(train_src(i,(WINSIZE^2)+4:(WINSIZE^2)*2+3), [ WINSIZE WINSIZE ])')/255;
    B = double(reshape(train_src(i,(WINSIZE^2)*2+4:(WINSIZE^2)*3+3), [ WINSIZE WINSIZE ])')/255;
    train_x(:,:,i) = cat(2,R,G,B);
end;

opts = [];
opts.alpha = 1;
opts.batchsize = 10;
opts.numepochs = 100;

cnn.layers = {
              struct('type', 'i') %input layer
              struct('type', 'c', 'outputmaps', 6, 'kernelsize', 5) %convolution layer
              struct('type', 's', 'scale', 2) %sub sampling layer
              struct('type', 'c', 'outputmaps', 12, 'kernelsize', 4) %convolution layer
              struct('type', 's', 'scale', 2) %subsampling layer
};   
#arg_list{1}

train_y = [train_src(:,3)'; (train_src(:,3)'-1).^2 ];

rand('state',0)
cnn = cnnsetup(cnn, train_x, train_y);
cnn = cnntrain(cnn, train_x, train_y, opts);

save -binary cnnknowledgebase cnn;
