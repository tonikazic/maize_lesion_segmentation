% this is code to process the segmented color bar from leaf. These color
% bar will be used for color adjustment of the leaf.
%
%  computation of mean of each color (total 12) on color bar.
%
% vatsa 10.14.2016

% imColorbarLeft = imread('/athe/d/avi/test_output/leftPiece_colorBar.tiff');
% imColorbarRight = imread('/athe/d/avi/test_output/rightPiece_colorBar.tiff');
%

function colorMean = rightColorbarColorMean(imColorbarRight)
 I = imColorbarRight;
[ht wd] = size(I(:,:,1));
I = I(1:335,1:1035,:);
% bw = im2bw(I, graythresh(I));  %  graythresh(I) = 0.4745
 bw = im2bw(I,0.30);
bw2 = imfill(bw,'holes');

% use ether bwlavel or bwboundaries
%
 L = bwlabel(bw2);
%
% [B,L,N] = bwboundaries(bw2,8,'holes');


s = regionprops(L, 'BoundingBox','Area','Image');
  
    colorMean = double(zeros(size(s,1),1));

    for n = 1:size(s,1)
        % if s(m).Area< 15000 && s(m).Area > 40 
    if s(n).Area > 50  
       mask = uint8(s(n).Image); % masking image of individual piece of color from colorbar
       box = ceil(s(n).BoundingBox); 
       im = uint8([]);
    
        im(:,:,1) = I(box(2):(box(2)+box(4)-1),...
                       box(1):(box(1)+box(3)-1),1).*mask;
        im(:,:,2) = I(box(2):(box(2)+box(4)-1),...
                       box(1):(box(1)+box(3)-1),2).*mask;
        im(:,:,3) = I(box(2):(box(2)+box(4)-1),...
                       box(1):(box(1)+box(3)-1),3).*mask;   
        path = strcat('/athe/d/avi/test_output/',num2str(n),'_right_im.tiff');   
                   imwrite(im(:,:,:),path);
                   
        hist_red = imhist(im(:,:,1));
        hist_green = imhist(im(:,:,2));
        hist_blue = imhist(im(:,:,3));
                   
        colorMean(n,1) = find_hist_mean(hist_red)/255; % column 1 is red mean
        colorMean(n,2) = find_hist_mean(hist_green)/255; % column 2 is green mean
        colorMean(n,3) = find_hist_mean(hist_blue)/255; % column 3 is blue mean 
        colorMean(n,4) = cat(1,s(n).Area);
    end             
    end 
 save('/athe/d/avi/test_output/rightBar_colorMean.mat', 'colorMean');
  csvwrite('/athe/d/avi/test_output/rightBar_colorMean.csv',colorMean);
end




function mean = find_hist_mean(hist)
hist(1)=0;
sum = 0;
weighted_sum = 0;
for m=1:(size(hist,1))
    
    weighted_sum = weighted_sum + (m-1)*hist(m);
    sum = sum + hist(m);
end
mean = weighted_sum/sum;
end