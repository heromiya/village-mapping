addpath(genpath('DeepLearnToolbox'));
% VillageMapping3
% Try deep learning method for this problem

clear;
close all;

ImgFile  = 'Bing/gtiff/18/tmp_bing.tif';
SampFile = 'Bing/gtiff/18/tmp_GHS.tif';
ClassLabel = {[3 4 5 6], [1 2], [0]};       % Label for positive/negative/unknown

global x_train x_test y_train y_test;

SubArea = [inf];
%SubArea = [1801 2700 3351 3950];
%SubArea = [];

%SampNum  = 15000;
SampNum  = 5000;

opts = [];
opts.alpha = 1;
opts.batchsize = 50;
opts.numepochs = 3;

WinSize  = 18;
cnn.layers = {
              struct('type', 'i') %input layer
              struct('type', 'c', 'outputmaps', 6, 'kernelsize', 5) %convolution layer
              struct('type', 's', 'scale', 2) %sub sampling layer
              struct('type', 'c', 'outputmaps', 12, 'kernelsize', 4) %convolution layer
              struct('type', 's', 'scale', 2) %subsampling layer
};   

warning('off', 'Images:initSize:adjustingMag');

Img = imread(ImgFile);
SampImg = imread(SampFile);

ImgHeight = size(Img, 1);
ImgWidth  = size(Img, 2);    
MaskImg = uint8(zeros(size(SampImg)));

LabelPos = ClassLabel{1};
for nl = 1:length(LabelPos)
  pos = find(SampImg == LabelPos(nl));
  MaskImg(pos) = 2;
end;

LabelNeg = ClassLabel{2};
for nl = 1:length(LabelNeg)
  pos = find(SampImg == LabelNeg(nl));
  MaskImg(pos) = 1;
end;    

iFT = [];
iFT.R = 1;
iFT.G = 2;
iFT.B = 3;

Halfsize = round((WinSize - 1) / 2);
Fidx = zeros(WinSize, WinSize, 3);                  % Dimension 3: color(R/G/B) index

% Feature
Feature = {};
Feature{1} = (single(Img(:, :, 1)) - 127) / 128;
Feature{2} = (single(Img(:, :, 2)) - 127) / 128;
Feature{3} = (single(Img(:, :, 3)) - 127) / 128;

Fidx(Halfsize + 1, Halfsize + 1, iFT.R) = iFT.R;
Fidx(Halfsize + 1, Halfsize + 1, iFT.G) = iFT.G;
Fidx(Halfsize + 1, Halfsize + 1, iFT.B) = iFT.B;

% Record nearby pixels by shifting the image
fcount = length(Feature) + 1;
for nhb = 1:3
  CurrImg = Feature{nhb};
  
  for nhx = -Halfsize:(WinSize - Halfsize - 1)
    if(nhx < 0)
      nhx_idx = [repmat(1, [1 abs(nhx)]) 1:(ImgWidth + nhx)];
    elseif(nhx > 0)
      nhx_idx = [(1 + nhx):ImgWidth repmat(ImgWidth, [1 nhx])];
    else
      nhx_idx = 1:ImgWidth;
    end;
    
    for nhy = -Halfsize:(WinSize - Halfsize - 1)
        
      if(nhx == 0) && (nhy == 0)
        continue;
      end;
      
      if(nhy < 0)
        nhy_idx = [repmat(1, [1 abs(nhy)]) 1:(ImgHeight + nhy)];
      elseif(nhy > 0)
        nhy_idx = [(1 + nhy):ImgHeight repmat(ImgHeight, [1 nhy])];
      else
        nhy_idx = 1:ImgHeight;
      end;                
      
      Feature{fcount} = CurrImg(nhy_idx, nhx_idx, 1);
      
      Fidx(nhy + Halfsize + 1, nhx + Halfsize + 1, nhb) = fcount;
      fcount = fcount + 1;
    end;            
  end;
end;    

TmpImgSize = [WinSize WinSize * 3];
train_x2 = zeros(TmpImgSize(1), TmpImgSize(2), 0, 'single');
train_y2 = zeros(2, 0, 'single');

NewFidx = [ Fidx(:, :, 1);  Fidx(:, :, 2);  Fidx(:, :, 3) ];
SelectF = NewFidx(:);
Fnum = length(SelectF);

x_test = zeros(ImgHeight * ImgWidth, Fnum, 'single');
y_test = ones(ImgWidth * ImgHeight, 1, 'single') * NaN;    
test_x = zeros(TmpImgSize(1), TmpImgSize(2), 0, 'single');
test_y = zeros(2, 0, 'single');

for nsf = 1:Fnum
%for nsf = 1:5
  x_test(:, nsf) = Feature{SelectF(nsf)}(:);
end;

% Prepare training data
for cl = 1:2
  pos = find(MaskImg == cl);       
  
  tmp = x_test(pos, :); % x_test ( Image index, Feature (shifted images) index )
  nelem = length(pos);
  tmp2 = reshape(tmp', [TmpImgSize(1), TmpImgSize(2) nelem]);
  y_test(pos) = cl;
  
  if(nelem > SampNum)            
    tmp3 = randn(nelem, 1);
    [tmp3, tmpidx] = sort(tmp3);
    pos = pos(tmpidx(1:SampNum));
  elseif(rem(nelem, opts.batchsize) ~= 0)
    SampNum = floor(nelem / opts.batchsize) * opts.batchsize;
    tmp3 = randn(nelem, 1);
    [tmp3, tmpidx] = sort(tmp3);
    pos = pos(tmpidx(1:SampNum));
  end;
  tmp = x_test(pos, :); % randomly sampled x_test data
  nelem = length(pos);
  tmp2 = reshape(tmp', [TmpImgSize(1), TmpImgSize(2) nelem]);
  train_x2(:, :, end + (1:nelem)) = tmp2;
  train_y2(cl, end + (1:nelem)) = 1;
end;

% Prepare test data

for cl = 1:2
  pos = find(MaskImg == cl);       
  nelem = length(pos);
  tmp = x_test(pos, :);
  nelem = length(pos);
  
  tmp2 = reshape(tmp', [TmpImgSize(1), TmpImgSize(2) nelem]);        
  test_x(:, :, end + (1:nelem)) = tmp2;
  test_y(cl, end + (1:nelem)) = 1;        
end;    

rand('state',0)

cnn = cnnsetup(cnn, train_x2, train_y2);
cnn = cnntrain(cnn, train_x2, train_y2, opts);

[er_train, bad, train_p2] = cnntest(cnn, train_x2, train_y2);
[~, train_c2] = max(train_y2);
[er_test, bad, test_p] = cnntest(cnn, test_x, test_y);
[~, test_c] = max(test_y);

MaskImg2 = ones(size(MaskImg)) * NaN;       % Unknown pixels
MaskImg2(MaskImg == 1) = 0;                 % Non-village pixels
MaskImg2(MaskImg == 2) = 1;                 % Village pixels

Mask_Cnn = ones(size(MaskImg)) * NaN;
TmpIdx = 0;
for cl = 1:2
  pos = find(MaskImg == cl);       
  nelem = length(pos);
  
  Mask_Cnn(pos) = test_p(TmpIdx + (1:nelem)) - 1;
  TmpIdx = TmpIdx + nelem;      
end; 

imwrite(UIS_CompareMaskImgs(MaskImg2, Mask_Cnn), 'CnnRes.png');

