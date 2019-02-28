% this is code to process the segmented color bar from leaf. These color
% bar will be used for color adjustment of the leaf.
%
%  computation of mean of each color (total 24) on color bar.
%
% vatsa 10.14.2016

% imColorbarLeft = imread('/athe/d/avi/test_output/leftPiece_colorBar.tiff');
% imColorbarRight = imread('/athe/d/avi/test_output/rightPiece_colorBar.tiff');
%

function colorMean = leftColorbarColorMean(imColorbarLeft)
     I = imColorbarLeft;
     [ht wd] = size(I(:,:,1));
     I = I(1:(ht-39),1:(wd-62),:);
% % bw = im2bw(I, graythresh(I));    % graythresh(I) value is 0.4353.
%     bw = im2bw(I,0.29);
%     bw2 = imfill(bw,'holes');

% trying different segmentation algorithms are as follows:
%
% bwlavel or bwboundaries
%
%     L = bwlabel(bw2); % segment all colors except purple. 
%     [B, L, N] = bwboundaries(bw2,8,'holes'); % segment all colors except purple. 



% k means segmentation algorithm
%
%
%     img=rgb2gray(I);
%     k=3;
%     [mu,mask] = kmeans(double(img),k);
% 
% % find 12 regions in the image
% %
% %
% b=uint8(mask == 1);
%  b1=b*255;
% figure, imshow(b1), title('Classification of Object-1');
% 
% c = uint8(mask==2);
% c1=c*255;
% figure, imshow(c1), title('Classfication for object2');

% another form of k-means for color segmentation
%
%
cform = makecform('srgb2lab');
lab_he = applycform(I,cform);
ab = double(lab_he(:,:,2:3));
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);
nColors = 3;
% repeat the clustering 3 times to avoid local minima
[cluster_idx, cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean', ...
                                      'Replicates',3);
pixel_labels = reshape(cluster_idx,nrows,ncols);
imshow(pixel_labels,[]), title('image labeled by cluster index');
segmented_images = cell(1,3);
rgb_label = repmat(pixel_labels,[1 1 3]);

for k = 1:nColors
    color = I;
    color(rgb_label ~= k) = 0;
    segmented_images{k} = color;
end
imshow(segmented_images{1}), title('objects in cluster 1');
close all
imshow(segmented_images{1}), title('objects in cluster 1');
imshow(segmented_images{2}), title('objects in cluster 2');
figure,imshow(segmented_images{2}), title('objects in cluster 2');
figure,imshow(segmented_images{3}), title('objects in cluster 3');

% segment the nuclei of segmented image

% mean_cluster_value = mean(cluster_center,2);
% [tmp, idx] = sort(mean_cluster_value);
% blue_cluster_num = idx(1);
% 
% L = lab_he(:,:,1);
% blue_idx = find(pixel_labels == blue_cluster_num);
% L_blue = L(blue_idx);
% is_light_blue = imbinarize(L_blue);
% 
% % Use the mask is_light_blue to label which pixels belong to the blue nuclei. 
% % Then display the blue nuclei in a separate image.
% %
% nuclei_labels = repmat(uint8(0),[nrows ncols]);
% nuclei_labels(blue_idx(is_light_blue==false)) = 1;
% nuclei_labels = repmat(nuclei_labels,[1 1 3]);
% blue_nuclei = he;
% blue_nuclei(nuclei_labels ~= 1) = 0;
% imshow(blue_nuclei), title('blue nuclei');



% Binary image segmentation using Fast Marching Method
% imsegfmm function
%
% this method is work on binary image only
% create mask first 
%
%
% mask = false(size(I));
% mask = false(size(im2bw(I,0.29)));
% mask(170,70) = true;
% W = graydiffweight(im2bw(I,0.29), mask, 'GrayDifferenceCutoff', 25);
% thresh = 0.01;
% [BW, D] = imsegfmm(W, mask, thresh);
% figure
% imshow(BW)


% Color-Based Segmentation Using the L*a*b* Color Space
% 
%  Calculate Sample Colors in L*a*b* Color Space for Each Region
%
% load regioncoordinates;
% 
% nColors = 6;
% sample_regions = false([size(I,1) size(I,2) nColors]);
% for count = 1:nColors
%   sample_regions(:,:,count) = roipoly(I,region_coordinates(:,1,count),...
%                                       region_coordinates(:,2,count));
% end
% 
% 
% imshow(sample_regions(:,:,2)),title('sample region for red');
% 
% lab_fabric = rgb2lab(I);
% a = lab_fabric(:,:,2);
% b = lab_fabric(:,:,3);
% color_markers = zeros([nColors, 2]);
% 
% for count = 1:nColors
%   color_markers(count,1) = mean2(a(sample_regions(:,:,count)));
%   color_markers(count,2) = mean2(b(sample_regions(:,:,count)));
% end
% 
% fprintf('[%0.3f,%0.3f] \n',color_markers(2,1),color_markers(2,2));
% 
% color_labels = 0:nColors-1;
% 
% a = double(a);
% b = double(b);
% distance = zeros([size(a), nColors]);
% 
% for count = 1:nColors
%   distance(:,:,count) = ( (a - color_markers(count,1)).^2 + ...
%                       (b - color_markers(count,2)).^2 ).^0.5;
% end
% 
% [~, label] = min(distance,[],3);
% label = color_labels(label);
% clear distance;
% 
% rgb_label = repmat(label,[1 1 3]);
% segmented_images = zeros([size(I), nColors],'uint8');
% 
% for count = 1:nColors
%   color = I;
%   color(rgb_label ~= color_labels(count)) = 0;
%   segmented_images(:,:,:,count) = color;
% end
% 
% figure,imshow(segmented_images(:,:,:,2)), title('red objects');
% figure,imshow(segmented_images(:,:,:,3)), title('green objects');
% figure,imshow(segmented_images(:,:,:,4)), title('purple objects');
% figure,imshow(segmented_images(:,:,:,5)), title('magenta objects');
% figure,imshow(segmented_images(:,:,:,6)), title('yellow objects');
% 




% here start the subimage operation from colorbar and 
% save these subimages, area and color mean values 
%
% k-means output is segmented_images{1}, segmented_images{2} and
% segmented_images{3}

L1 = segmented_images{1};
L = L1(:,:,2); 
s = regionprops(L, 'BoundingBox','Area','Image');
  
  %  bboxes_matrix = double(zeros(size(s,1),4));
    colorMean = double(zeros(size(s,1),1));

    for n = 1:size(s,1)
 % if s(m).Area< 15000 && s(m).Area > 40 
 %  if s(n).Area > 10  % for leftcolorbar  
       mask = uint8(s(n).Image); % masking image of individual piece of color from colorbar
       box = ceil(s(n).BoundingBox); 
       im = uint8([]);
    
        im(:,:,1) = I(box(2):(box(2)+box(4)-1),...
                       box(1):(box(1)+box(3)-1),1).*mask;
        im(:,:,2) = I(box(2):(box(2)+box(4)-1),...
                       box(1):(box(1)+box(3)-1),2).*mask;
        im(:,:,3) = I(box(2):(box(2)+box(4)-1),...
                       box(1):(box(1)+box(3)-1),3).*mask; 
        path = strcat('/athe/d/avi/test_output/',num2str(n),'_left_im.tiff');    
    %    path = strcat('/athe/d/avi/test_output/',num2str(n),'_right_im.tiff');   
         
                   imwrite(im(:,:,:),path);
                   
        hist_red = imhist(im(:,:,1));
        hist_green = imhist(im(:,:,2));
        hist_blue = imhist(im(:,:,3));
                   
        colorMean(n,1) = find_hist_mean(hist_red)/255; % column 1 is red mean
        colorMean(n,2) = find_hist_mean(hist_green)/255; % column 2 is green mean
        colorMean(n,3) = find_hist_mean(hist_blue)/255; % column 3 is blue mean 
        colorMean(n,4) = cat(1,s(n).Area);
  % end             
    end 
  save('/athe/d/avi/test_output/leftBar_colorMean.mat', 'colorMean');
  csvwrite('/athe/d/avi/test_output/leftBar_colorMean.csv',colorMean);
  
  % save('/athe/d/avi/test_output/rightBar_colorMean.mat', 'colorMean');
%  csvwrite('/athe/d/avi/test_output/rightBar_colorMean.csv',colorMean);
  
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