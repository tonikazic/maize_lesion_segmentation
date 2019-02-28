function [lesion_data, STATS_les, midRib] = quantitative_data(seg_im, leaf, leaf_dir)
% here we could use seg_im instead of L as input to this function.
% save all information in lesions_dir
%
% Quantitative data of each lesion.
%
%
% clc;
% full_filename = '/athe/c/maize/analysis_images/tiffs/16r/gimmel/26.7/DSC_0090.tiff';
% full_filename = '/athe/d/avi/mask_DSC_0090.tiff'; 
% I = imread(leaf);
I = leaf;
STATS_les = regionprops(logical(seg_im),'Area','Centroid','MajorAxisLength','MinorAxisLength', ...
                            'Eccentricity','EulerNumber','Orientation', 'Extent', ...
                            'Perimeter','ConvexArea','ConvexHull',...
                            'ConvexImage','EquivDiameter','Extrema', 'FilledArea','FilledImage',...
                            'Solidity','SubarrayIdx','Image','BoundingBox');
                        
% following parameters are not available in 2013b matlab.
% 'PixelIdList',
%                        
%
% initialize variabes to save data values either in matrix or in vector corresponding to parameter.
%
%
    bboxes_matrix = double(zeros(size(STATS_les,1),4));
    centroid_matrix = double(zeros(size(STATS_les,1),2));
    extrema_matrix = double(zeros(8,2));
    lesion_data = double(zeros(size(STATS_les,1),15));

% this is the loop for each segmented lesions. Here n is the number of segmented lesions.
%
%
for n=1:size(STATS_les,1)   
 %  if STATS_les(m).Area< 20000 && STATS_les(m).Area > 10   
    lesion_data(n,1) = cat(1,STATS_les(n).Area); 
    lesion_data(n,2) = cat(1,STATS_les(n).MajorAxisLength);
    lesion_data(n,3) = cat(1,STATS_les(n).MinorAxisLength);
    lesion_data(n,4) = cat(1,STATS_les(n).Eccentricity);
    lesion_data(n,5) = cat(1,STATS_les(n).EulerNumber);
    lesion_data(n,6) = cat(1,STATS_les(n).Orientation);
    lesion_data(n,7) = cat(1,STATS_les(n).Extent);
    lesion_data(n,8) = cat(1,STATS_les(n).Perimeter);
    lesion_data(n,9) = cat(1,STATS_les(n).ConvexArea);
    lesion_data(n,10) = cat(1,STATS_les(n).EquivDiameter);
    lesion_data(n,11) = cat(1,STATS_les(n).FilledArea);
    lesion_data(n,12) = cat(1,STATS_les(n).Solidity);

% following parameters are not having scaler values. These parameter are
% saved as per lesion in different data structure as they need. see below.
%
% vatsa 10.5.2016
%
%  lesion_data(n,2) = cat(1,STATS_les(n).Centroid); 
%  lesion_data(n,19) = cat(1,STATS_les(n).SubarrayIdx);
%  lesion_data(n,11) = cat(1,ceil(STATS_les(n).ConvexHull));
%  lesion_data(n,12) = cat(1,STATS_les(n).ConvexImage);
%  lesion_data(n,14) = cat(1,STATS_les(n).Extrema);
%  lesion_data(n,16) = cat(1,STATS_les(n).FilledImage);
%  lesion_data(n,17) = cat(1,STATS_les(n).PixelIdList);
%  lesion_data(n,23) = ceil(STATS_les(n).BoundingBox);  
  
% image : masking image for individual lesion
%
%
    mask = uint8(STATS_les(n).Image); 
    box = ceil(STATS_les(n).BoundingBox); 
    im = uint8([]);
% extracting lesions from leaf and save as *.tiff.  
%
        im(:,:,1) = I(box(2):(box(2)+box(4)-1),...
                   box(1):(box(1)+box(3)-1),1).*mask;
        im(:,:,2) = I(box(2):(box(2)+box(4)-1),...
                       box(1):(box(1)+box(3)-1),2).*mask;
        im(:,:,3) = I(box(2):(box(2)+box(4)-1),...
                       box(1):(box(1)+box(3)-1),3).*mask;
       % path = strcat('/athe/d/avi/test_output/',num2str(n),'_im.tiff');
       
       
       % form a directory that is output_dir/segext_timestamp/lesions_dir/image_num/ and
       % put the segmented leaf, the individual lesions' matrices and
       % images, and the extracted data in that directory
         path = strcat(leaf_dir,'/',num2str(n),'_','im.tiff');
         imwrite(im(:,:,:),path);  
        
% computing histogram of each color for every lesion 
%
%
        hist_red = imhist(im(:,:,1));
        hist_green = imhist(im(:,:,2));
        hist_blue = imhist(im(:,:,3));
                   
     lesion_data(n,13) = find_hist_mean(hist_red)/255; % column  is red mean
     lesion_data(n,14) = find_hist_mean(hist_green)/255; % column  is green mean
     lesion_data(n,15) = find_hist_mean(hist_blue)/255; % column is blue mean 
    
    
% obtaining and saving boundingbox of each lesion. It saves in matrix form
% for each lesion of the leaf. each row represent each lesion bounding box
% values.
%
% 
% saving parameters those are not having scaler value: BoundingBox, Centroid,
% SubarrayIdx, ConvexHull, ConvexImage, FilledImage, Extrema.
%
%
% vatsa 10.5.2016
     bboxes = reshape(ceil([STATS_les(n).BoundingBox]),4,[]).';
     bboxes_matrix(n,1:4) = vertcat(bboxes);
%    path1 = strcat(lesions_dir,num2str(n),'_DSC_0091.mat');
    save(strcat(leaf_dir,'/', num2str(n),'_bboxes_matrix.mat'),'bboxes_matrix');
    csvwrite(strcat(leaf_dir,'/', num2str(n),'_bboxes_matrix.csv'),bboxes_matrix);


centroid_matrix(n,1:2) = vertcat(reshape(ceil([STATS_les(n).Centroid]),2,[]).');
save(strcat(leaf_dir,'/', num2str(n),'_centroid.mat'),'centroid_matrix');
csvwrite(strcat(leaf_dir,'/', num2str(n),'_centroid_matrix.csv'),centroid_matrix);

subarrayIdx_matrix = double([]);
subarrayIdx_matrix = (cell2mat(STATS_les(n).SubarrayIdx)).';
save(strcat(leaf_dir, '/', num2str(n),'_subarrayIdx_matrix.mat'),'subarrayIdx_matrix');
csvwrite(strcat(leaf_dir,'/', num2str(n),'_subarrayIdx_matrix.csv'),subarrayIdx_matrix);

% very easy way to store structure to array in matlab
%
convexHull_matrix = double([]);
convexHull_matrix =  [STATS_les(n).ConvexHull];
save(strcat(leaf_dir,'/', num2str(n),'_convexHull_matrix.mat'),'convexHull_matrix');
csvwrite(strcat(leaf_dir,'/', num2str(n),'_convexHul_matrix.csv'),convexHull_matrix);


% save all convex images of lesions. of course, will change path as we are
% doing in batch file processing.
%
% path1 = strcat('/athe/d/avi/test_output/',num2str(2),'convexImage.tiff');
imwrite(STATS_les(n).ConvexImage,strcat(leaf_dir,'/', num2str(n),'_convexImage.tiff'));


% path2 = strcat('/athe/d/avi/test_output/',num2str(2),'filledImage.tiff');
imwrite(STATS_les(n).FilledImage,strcat(leaf_dir,'/', num2str(n),'_filledImage.tiff'));

extrema_matrix = STATS_les(n).Extrema;
save(strcat(leaf_dir,'/', num2str(n),'_extrema_matrix.mat'),'extrema_matrix');
csvwrite(strcat(leaf_dir,'/', num2str(n),'_extrema_matrix.csv'),extrema_matrix);
  
% clear individual lesion image in each loop. just to save memory loss.
%
%
  clear im;
% end                
end 
% save parameters those have scaler value
%
save(strcat(leaf_dir,'/', 'quantitativeLesionData.mat'), 'lesion_data');
csvwrite(strcat(leaf_dir,'/', 'quantitativeLesionData.csv'), lesion_data);

% called following function to rid off the mid rib from each leaf and save mid rib tif image. 
%
%
[midRib] = getRidofMidRib(lesion_data,bboxes_matrix,I,leaf_dir);
% imwrite(midRib(:,:,:),strcat(leaf_dir,maxIndex,'_midrib.tiff'));
end




function [midRib] = getRidofMidRib(lesion_data,bboxes_matrix,I, leaf_dir)
% to find out midrib in the segmented leaf, I think once we find the maximuam area of lesion 
% and it's corresponding index. Then it will be helpful to
% remove the midrib from the dataset as well. even we can crop the image to
% see it's detecting correct or wrong lesion as a midrib of corresponding
% image.
%
% vatsa 10.5.2016
%
% [~,maxIndex] = max(areas(:,1));
[~,maxIndex] = max(lesion_data(:,1));
% obtain this bounding box and ensure all floating point is removed
%
midRibBoundingBox = floor(bboxes_matrix(maxIndex,:));

%  the midrib of the particular leaf
%
        midRib(:,:,1) = I(round(midRibBoundingBox(2):(midRibBoundingBox(2)+midRibBoundingBox(4)-1)),...
                       round(midRibBoundingBox(1):(midRibBoundingBox(1)+midRibBoundingBox(3)-1)),1);
        midRib(:,:,2) = I(round(midRibBoundingBox(2):(midRibBoundingBox(2)+midRibBoundingBox(4)-1)),...
                       round(midRibBoundingBox(1):(midRibBoundingBox(1)+midRibBoundingBox(3)-1)),2);
       midRib(:,:,3) = I(round(midRibBoundingBox(2):(midRibBoundingBox(2)+midRibBoundingBox(4)-1)),...
                       round(midRibBoundingBox(1):(midRibBoundingBox(1)+midRibBoundingBox(3)-1)),3);

% now save midRib and show leaf and midrib in single image
%
imwrite(midRib(:,:,:),strcat(leaf_dir,'/', num2str(maxIndex),'_midrib.tiff'));
figure; 
subplot(2,1,1);
imshow(I);
subplot(2,1,2);
imshow(midRib);
 end




function mean = find_hist_mean(hist)
% to find the mean of R,G and B color for each lesion
%
%
hist(1)=0;
sum = 0;
weighted_sum = 0;
for m=1:(size(hist,1))
    weighted_sum = weighted_sum + (m-1)*hist(m);
    sum = sum + hist(m);
end
mean = weighted_sum/sum;
end