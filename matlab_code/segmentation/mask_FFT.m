function leaf_final = mask_FFT(im)
% This function takes an rgb image and input and masks out the main leaf
% image. To do this, it undergoes several steps:
%
% 1. Identify major classes of pixels in the histogram
%   a. these correspond
%


[ht wd] = size(im(:,:,1)); % determines the height and width for use in loops

hist_red   = imhist(im(:,:,1),64); % creates a histogram of the red and green
hist_green = imhist(im(:,:,2),64); % pixel values, binned to eliminate extremities

% the first minimum greater than the absolute maximum (mode) is used as
% threshold, as this 
thresh_red = thresh(hist_red)*4;
thresh_green = thresh(hist_green)*4;


% creates a vector from the image for more efficient computation
im_vec = reshape(im,ht*wd,3);


%  Finds all values below the threshold for red and green determined from
%  the histograms of their values and sets them equal to 0 (removes them
%  from the mask. 
mask_vec = ones(ht*wd,1);
for i=1:ht*wd
    
    if (im_vec(i,1)<thresh_red) && (im_vec(i,2)<thresh_green)
        
            mask_vec(i,:) = 0;
    end
end

% reshapes the mask into an image
mask = reshape(mask_vec,ht,wd);

% converts the mask to a logical for use in regionprops. regionprops
% creates objects out of all contiguous non-zero pixels and returns
% specified properties of these objects
L = logical(mask);
STATS = regionprops(L,'Area','BoundingBox','Image');

% fills an array with the areas
STATS_cell = struct2cell(STATS);
areas = cell2mat(STATS_cell(1,:))';

% for the images, the four largest objects are desired, as they correspond
% to the leaf, color bars, and tag
indices = zeros(4,1);
for p=1:4
    
    [area I] = max(areas);
    indices(p) = I;
    areas(I) = 0;
end


% the BoundingBox gives the location of the upper left corner of the 
% smallest box containing the object along with the height and width,
% allowing for the object to be located in the original image for further
% processing
leaf_box  = ceil(STATS(indices(1)).BoundingBox);
box_2 = ceil(STATS(indices(2)).BoundingBox);
box_3 = ceil(STATS(indices(3)).BoundingBox);
box_4 = ceil(STATS(indices(4)).BoundingBox);
    

% creates individual masks for the four largest objects (the largest of
% which will be the leaf)
leaf_mask = uint8(STATS(indices(1)).Image);
leaf_mask(:,1)=1; leaf_mask(:,wd)=1;
leaf_mask = repmat(imfill(leaf_mask),[1 1 3]);


% the remaining three objects are created and will be sorted later
mask_2 = repmat(imfill(uint8(STATS(indices(2)).Image)),[1 1 3]);
mask_3 = repmat(imfill(uint8(STATS(indices(3)).Image)),[1 1 3]);
mask_4 = repmat(imfill(uint8(STATS(indices(4)).Image)),[1 1 3]);


% applies the masks to corresponding parts of the original image, located
% via the BoundingBox properties
leaf = im(leaf_box(2):(leaf_box(2)+leaf_box(4)-1),...
          leaf_box(1):(leaf_box(1)+leaf_box(3)-1),:).*leaf_mask;
             
object_2 = im(box_2(2):(box_2(2)+box_2(4)-1),...
              box_2(1):(box_2(1)+box_2(3)-1),:).*mask_2;
                 
object_3 = im(box_3(2):(box_3(2)+box_3(4)-1),...
              box_3(1):(box_3(1)+box_3(3)-1),:).*mask_3;
                 
object_4 = im(box_4(2):(box_4(2)+box_4(4)-1),...
              box_4(1):(box_4(1)+box_4(3)-1),:).*mask_4;
                 
                 
                 
% this next section considers the leaf separate from all other portions.
[ht_leaf wd_leaf] = size(leaf(:,:,1));          

%hsv_leaf = rgb2hsv(leaf); % converting to hsv makes for easier k-means

cform = makecform('srgb2lab');
lab_leaf = applycform(leaf,cform);

% using kmeans, segments the leaf into 3 categories using saturation and 
% value from the hsv transform. each segmented area is this assessed for 
% color (remaining blue) and pattern (using fft)

%k_mat      = double(reshape(lab_leaf(:,:,1),ht_leaf*wd_leaf,1));
%k_mat(:,2) = double(reshape(lab_leaf(:,:,2),ht_leaf*wd_leaf,1));
%k_mat(:,3) = double(reshape(lab_leaf(:,:,3),ht_leaf*wd_leaf,1));

k_mat      = double(reshape(leaf,ht_leaf*wd_leaf,3));

% executes the kmeans algorithm
[cluster_idx cluster_center] = kmeans(k_mat,3,'distance',...
                                      'sqEuclidean','Replicates',3);
% labels which cluster each pixel belongs to. 3 clusters are defined: one
% for the majority of leaf values (green), one for any potential carpet
% tape, and one for the black background.
pixel_labels = reshape(cluster_idx,ht_leaf,wd_leaf);                                 

% creates a cell array in which each segmented image can be stored
im_seg = cell(1,3);
rgb_label = repmat(pixel_labels,[1 1 3]);

% fills the cell array with the segmented images
for k = 1:2
    
    color = leaf;
    color(rgb_label ~= k) = 0;
    im_seg{k} = color;
end


leaf_vec = reshape(leaf,ht_leaf*wd_leaf,3); % creates  an array for quicker computation

for i=1:2
    
    image = im_seg{i}; % selects one of the k-means segmentations
    mask_seg = logical(image(:,:,1)); % creates a logical image for regionprops
    
    STATS_FFT_red   = regionprops(mask_seg,image(:,:,1),'Area','BoundingBox','Image','PixelIdxList','PixelValues');
    STATS_FFT_green = regionprops(mask_seg,image(:,:,2),'PixelValues');
    STATS_FFT_blue  = regionprops(mask_seg,image(:,:,3),'PixelValues');
    length_STATS = size(STATS_FFT_red,1);

    % loops through all of the objects identified by kmeans
    for j = 1:length_STATS
        
        % the blue background will be have higher blue values than red or
        % green
        mean_red   = mean(STATS_FFT_red(j).PixelValues);
        mean_green = mean(STATS_FFT_green(j).PixelValues);
        mean_blue  = mean(STATS_FFT_blue(j).PixelValues);
        
        % the red channel is used for the master mask for convenience
        pixel_list = STATS_FFT_red(j).PixelIdxList;

        obj_box = ceil(STATS_FFT_red(j).BoundingBox);
        leaf_BW = uint8(STATS_FFT_red(j).Image);
        
        
        if  mean_blue > 0 && mean_blue > mean_red && mean_blue > mean_green
            
            leaf_vec(pixel_list,:) = 0;
        else
    
            [h_ob w_ob] = size(leaf_BW);
    
            leaf_red = leaf(obj_box(2):(obj_box(2)+obj_box(4)-1),...
                            obj_box(1):(obj_box(1)+obj_box(3)-1),1).*leaf_BW;
                        
            if h_ob>w_ob
                
                leaf_red = leaf_red'; % transposing helps the texture detecting algorithm
            end
              
            means = sum(leaf_red,1)./sum(leaf_red~=0,1);
            means_sc = means/max(means);
            
            [max_means min_means] = peakdet(means_sc,0.3);
            
            if numel(max_means) > 8
                
                len_means = length(max_means);
                half_means = ceil(len_means/2);
                
                means_lim = means(max_means(half_means-2,1):max_means(half_means+2,1));
        
                means_shift = means_lim-(max(means_lim)+min(means_lim))/2;
            
                FFT_area = fft(means_shift);
                FFT_area(1) = [];
    
                n=length(FFT_area);
                power = abs(FFT_area(1:floor(n/2))).^2;
        
                [val idx] = max(power);
            
                power_scale = power/val;
                [max_pow min_pow] = peakdet(power_scale,0.2);
    
                if size(max_pow,1)>0 && size(max_pow,1)<4 && val>10^5
                
                    leaf_vec(pixel_list,:) = 0;
                end
            end
        end
    end             
end

leaf_final = reshape(leaf_vec,ht_leaf,wd_leaf,3);
%leaf_mask = ~logical(reshape(inv_mask_idx,ht_leaf,wd_leaf));

%STATS_final = regionprops(leaf_mask,'Area','BoundingBox','Image');

%areas_leaf = zeros(size(STATS_final,1),1);
%for p=1:size(areas_leaf,1)
    
%    areas_leaf(p) = STATS_final(p).Area;
%end

%[area_final I_final] = max(areas_leaf);

%final_mask = uint8(STATS_final(I_final).Image);
%box = ceil(STATS_final(I_final).BoundingBox);

%[ht_final wd_final] = size(final_mask);

%leaf_final = uint8(zeros(ht_final,wd_final,3));

%leaf_final(:,:,1) = leaf(box(2):(box(2)+box(4)-1),box(1):(box(1)+box(3)-1),1).*final_mask;
%leaf_final(:,:,2) = leaf(box(2):(box(2)+box(4)-1),box(1):(box(1)+box(3)-1),2).*final_mask;
%leaf_final(:,:,3) = leaf(box(2):(box(2)+box(4)-1),box(1):(box(1)+box(3)-1),3).*final_mask;
 
end


%  Finds the minimum between the two greatest maxima, which corresponds to
%  a value consistently between values belonging to the blue background and
%  leaf
function n = thresh(hist)

[max_hist max_idx] = max(hist);
hist_scale = hist/max_hist;

[max_tab min_tab] = peakdet(hist_scale,0.025); % finds all maxima and minima of the image histogram


[C idx] = max(max_tab(:,2));
max_1 = max_tab(idx,1);
max_tab(idx,2) = 0;
[C idx] = max(max_tab(:,2));
max_2 = max_tab(idx,1);

maxes = sort([max_1 max_2]);

for i=1:size(min_tab,1)
    
    if min_tab(i) > maxes(1) && min_tab(i) < maxes(2)
        
        n=min_tab(i,1);
    end
end

end
