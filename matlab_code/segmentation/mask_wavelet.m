function [leaf_im = mask_wavelet(image)


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
    
    [area,I] = max(areas);
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








end