
function ovIm = UIS_CompareMaskImgs(Img1, Img2)
    
    ImgHeight = size(Img1, 1);
    ImgWidth  = size(Img1, 2);
    
    if( (size(Img2, 1) ~= ImgHeight) || (size(Img2, 2) ~= ImgWidth) )
        error('Incorrect input: unmatched image size');
    end;
    
%     Colors = [ ...
%         255   0   0;                % For mask (1, 0)
%           0 150 255;                % For mask (0, 1)
%         255   0 255;                % For mask (1, 1)
%         ];

    Colors = [ ...
        255   0   0;                % For mask (1, 0)
          0   0 255;                % For mask (0, 1)
          0 255   0;                % For mask (1, 1)
        ];
    Color_Invalid = [127 127 127];  % For NaN pixels in Img1

    ovIm = zeros(ImgHeight, ImgWidth, 3);
    
%     ovIm = UIS_FlattenMaskOverlay(ovIm, (Img1==1), 1.0,'r');
%     ovIm = UIS_FlattenMaskOverlay(ovIm, (Img2==1), 0.5,'b');
    
    pos0 = find(isnan(Img1));
    pos1 = find( (Img1 == 1) & (Img2 ~= 1) );
    pos2 = find( (Img1 ~= 1) & (Img2 == 1) );
    pos3 = find( (Img1 == 1) & (Img2 == 1) );    
    
    for nb = 1:3
        band = zeros(ImgHeight, ImgWidth);
        band(pos1) = Colors(1, nb);
        band(pos2) = Colors(2, nb);
        band(pos3) = Colors(3, nb);        
        band(pos0) = Color_Invalid(nb);
        ovIm(:, :, nb) = band;
    end;
    
    ovIm = uint8(ovIm);
    gcf;
    imshow(ovIm, []);
    
    

