function leaf_final = mask_kmeans(im)


[ht wd] = size(im(:,:,1)); % determines the height and width for use in loops

hist_red   = imhist(im(:,:,1),64); % creates a histogram of the red and green
hist_green = imhist(im(:,:,2),64); % pixel values, binned to eliminate extremities


% calls the find_min function, which finds the local minima of a given histogram
min_red   = find_min(hist_red);   
min_green = find_min(hist_green);


% finds the index of the absolute maximum for a given histogram, for use 
% with the local minima to find a threshold                                         
[mode_green I_green] = max(hist_green);
[mode_red I_red]     = max(hist_red);   
                                        
                                        
% the first minimum greater than the absolute maximum (mode) is used as
% threshold, as this 
thresh_red   = min_red(thresh(min_red,I_red))*4;
thresh_green = min_green(thresh(min_green,I_green))*4;


%  Finds all values below the threshold for red and green determined from
%  the histograms of their values and sets them equal to 0 (removes them
%  from the mask. 
mask = ones(ht,wd);
for w=1:wd
    
    for h=1:ht
        
        if (im(h,w,1)<thresh_red) && (im(h,w,2)<thresh_green)
        
            mask(h,w) = 0;
        end
    end
end


% converts the mask to a logical for use in regionprops. regionprops
% creates objects out of all contiguous non-zero pixels and returns
% specified properties of these objects
L = logical(mask);
STATS = regionprops(L,'Area','BoundingBox','Image');


areas = zeros(size(STATS,1),1);
for p=1:size(STATS,1)
    
    areas(p) = STATS(p).Area;
end


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
leaf_mask = imfill(leaf_mask);


mask_2 = imfill(uint8(STATS(indices(2)).Image));
mask_3 = imfill(uint8(STATS(indices(3)).Image));
mask_4 = imfill(uint8(STATS(indices(4)).Image));


% applies the masks to corresponding parts of the original image, located
% via the BoundingBox properties
leaf(:,:,1) = im(leaf_box(2):(leaf_box(2)+leaf_box(4)-1),...
                 leaf_box(1):(leaf_box(1)+leaf_box(3)-1),1).*leaf_mask;
leaf(:,:,2) = im(leaf_box(2):(leaf_box(2)+leaf_box(4)-1),...
                 leaf_box(1):(leaf_box(1)+leaf_box(3)-1),2).*leaf_mask;
leaf(:,:,3) = im(leaf_box(2):(leaf_box(2)+leaf_box(4)-1),...
                 leaf_box(1):(leaf_box(1)+leaf_box(3)-1),3).*leaf_mask;
             
object_2(:,:,1) = im(box_2(2):(box_2(2)+box_2(4)-1),...
                     box_2(1):(box_2(1)+box_2(3)-1),1).*mask_2;
object_2(:,:,2) = im(box_2(2):(box_2(2)+box_2(4)-1),...
                     box_2(1):(box_2(1)+box_2(3)-1),2).*mask_2;
object_2(:,:,3) = im(box_2(2):(box_2(2)+box_2(4)-1),...
                     box_2(1):(box_2(1)+box_2(3)-1),3).*mask_2;
                 
object_3(:,:,1) = im(box_3(2):(box_3(2)+box_3(4)-1),...
                     box_3(1):(box_3(1)+box_3(3)-1),1).*mask_3;
object_3(:,:,2) = im(box_3(2):(box_3(2)+box_3(4)-1),...
                     box_3(1):(box_3(1)+box_3(3)-1),2).*mask_3;
object_3(:,:,3) = im(box_3(2):(box_3(2)+box_3(4)-1),...
                     box_3(1):(box_3(1)+box_3(3)-1),3).*mask_3;
                 
object_4(:,:,1) = im(box_4(2):(box_4(2)+box_4(4)-1),...
                     box_4(1):(box_4(1)+box_4(3)-1),1).*mask_4;
object_4(:,:,2) = im(box_4(2):(box_4(2)+box_4(4)-1),...
                     box_4(1):(box_4(1)+box_4(3)-1),2).*mask_4;
object_4(:,:,3) = im(box_4(2):(box_4(2)+box_4(4)-1),...
                     box_4(1):(box_4(1)+box_4(3)-1),3).*mask_4;
                 
                 
                 
% this next section considers the leaf separate from all other portions.
[ht_leaf wd_leaf] = size(leaf(:,:,1));          


% eliminates all pixels where the RGB values are within a certain range
% and above a given value (white or similar), or pixels that match the
% characteristics of the blue background (the blue values are greater than
% green values and the green values are above the green threshold used
% above
hsv_leaf = rgb2hsv(leaf);
range_hue = rangefilt(hsv_leaf(:,:,1));

for w=1:wd_leaf
    
    for h=1:ht_leaf
           
        if abs(leaf(h,w,1)-leaf(h,w,2))<10 && ...
           abs(leaf(h,w,1)-leaf(h,w,3))<30 && ...
           abs(leaf(h,w,2)-leaf(h,w,3))<30 && ...
           hsv_leaf(h,w,2) < 0.3 || ...
          (leaf(h,w,3)>leaf(h,w,1) && leaf(h,w,3)>leaf(h,w,2))
            
            leaf_mask(h,w) = 0;
        end
    end
end

% after the mask has been altered, the image is inverted. the black areas
% are now objects to be evaluated by region props. 
inv_leaf_mask = ~logical(leaf_mask);


%STATS_hue  = regionprops(inv_leaf_mask,hsv_leaf(:,:,1),'PixelValues','PixelIdxList');
%STATS_sat  = regionprops(inv_leaf_mask,hsv_leaf(:,:,2),'PixelValues','PixelIdxList');
STATS_range = regionprops(inv_leaf_mask,range_hue,'PixelValues','PixelIdxList');
%STATS_gradX = regionprops(inv_leaf_mask,grad_sat_X,'PixelValues','PixelIdxList');
%STATS_gradY = regionprops(inv_leaf_mask,grad_sat_Y,'PixelValues','PixelIdxList');

k_mat = zeros(size(STATS_range,1),1);

for n=1:size(STATS_range,1)
    
%    k_mat(n,1) = mean(double(STATS_hue(n).PixelValues));
%    k_mat(n,2) = mean(double(STATS_sat(n).PixelValues));
%    k_mat(n,1) = mean(double(STATS_range(n).PixelValues));
    k_mat(n) = var(double(STATS_range(n).PixelValues));
%    k_mat(n,3) = double(STATS_range(n).Area);
end

%obj_idx = kmeans(k_mat,2,'Replicates',3);

inv_mask_idx = reshape (inv_leaf_mask,ht_leaf*wd_leaf,1);

for n=1:size(STATS_range,1)
    
    if k_mat(n)<0.005
        
        inv_mask_idx(STATS_range(n).PixelIdxList) = 0;
        
    end
end

leaf_mask = ~reshape(inv_mask_idx,ht_leaf,wd_leaf);

STATS_final = regionprops(leaf_mask,'Area','BoundingBox','Image');

areas_leaf = zeros(size(STATS_final,1),1);
for p=1:size(areas_leaf,1)
    
    areas_leaf(p) = STATS_final(p).Area;
end

[area_final I_final] = max(areas_leaf);

final_mask = uint8(STATS_final(I_final).Image);
box = ceil(STATS_final(I_final).BoundingBox);

[ht_final wd_final] = size(final_mask);

leaf_final = uint8(zeros(ht_final,wd_final,3));

leaf_final(:,:,1) = leaf(box(2):(box(2)+box(4)-1),box(1):(box(1)+box(3)-1),1).*final_mask;
leaf_final(:,:,2) = leaf(box(2):(box(2)+box(4)-1),box(1):(box(1)+box(3)-1),2).*final_mask;
leaf_final(:,:,3) = leaf(box(2):(box(2)+box(4)-1),box(1):(box(1)+box(3)-1),3).*final_mask;
 
end



% This function finds the minima of a histogram
function mins = find_min(hist)

mins = [];
k = 1;         % counter for the minimums array

for i=2:(size(hist,1)-1)
    
    if hist(i)<hist(i-1) && hist(i)<hist(i+1)
        
        mins(k) = i;
        k = k+1;
    end    
end

end


%  Finds the first minimum greater than the mode, which corresponds to
%  the lowest value that will be consistently greater than that 
function n = thresh(mins,I)

for m=1:size(mins,2)
    
    if(mins(m) > I)
        
        n=m;
        break
    end
end

end


% Finds the mean value from the calculated histogram

function mean = find_hist_mean(hist)

sum = 0;
weighted_sum = 0;
for m=2:(size(hist,1))
    
    weighted_sum = weighted_sum + m*hist(m);
    sum = sum + hist(m);
end
mean = weighted_sum/sum;
end




