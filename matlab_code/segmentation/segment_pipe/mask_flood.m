function [leaf_final tag colorbar] = mask_flood(image,range_fudge)








im = image;

[ht wd] = size(im(:,:,1)); % determines the height and width for use in loops



hist_red   = imhist(im(:,:,1),64); % creates a histogram of the red and green
hist_green = imhist(im(:,:,2),64); % pixel values, binned to eliminate extremities
figure,bar(hist_red);
title('R');
figure,bar(hist_green);
title('G');

[max_red min_red] = peakdet(hist_red,1000);
[max_green min_green] = peakdet(hist_green,1000);




% finds the minima returned by peakdet that fall in the range of good
% masking values.
for i=1:length(min_red)
    if min_red(i,1) > 10 && min_red(i,1) < 30
        
        thresh_red = 4*min_red(i,1);
    end
end

for i=1:length(min_green)
    if min_green(i,1) > 10 && min_green(i,1) < 30
        
        thresh_green = 4*min_green(i,1);
    end
end                  


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
for w=1:wd_leaf
    
    for h=1:ht_leaf
        
        if abs(leaf(h,w,1)-leaf(h,w,2))<10 && ...
           abs(leaf(h,w,1)-leaf(h,w,3))<25 && ...
           abs(leaf(h,w,2)-leaf(h,w,3))<25 && ...
           (leaf(h,w,1)>80 && leaf(h,w,2)>80 || leaf(h,w,3)>80) ...
        || (leaf(h,w,3)>leaf(h,w,2) && leaf(h,w,2)<thresh_green) 
            
            leaf_mask(h,w) = 0;
        end
    end
end

% after the mask has been altered, the image is inverted. the black areas
% are now objects to be evaluated by region props. 
inv_leaf_mask = ~logical(leaf_mask);

% the rangefilt function is used to find areas with large ranges of values
% (characteristic of the carpet tape)
range_green = rangefilt(im(leaf_box(2):(leaf_box(2)+leaf_box(4)-1),...
                 leaf_box(1):(leaf_box(1)+leaf_box(3)-1),2));

STATS_range = regionprops(inv_leaf_mask,range_green,'Area','BoundingBox',...
                          'PixelIdxList','PixelValues','Solidity');
STATS_red   = regionprops(inv_leaf_mask,leaf(:,:,1),'PixelValues');
STATS_green = regionprops(inv_leaf_mask,leaf(:,:,2),'PixelValues');
STATS_blue  = regionprops(inv_leaf_mask,leaf(:,:,3),'PixelValues');

% turns the leaf mask into a 1D array for use in the loop below
inv_leaf_mask = reshape(inv_leaf_mask,ht_leaf*wd_leaf,1);

% finds the global standard deviation of the rangefilt of green leaf values
std_range = std(double(reshape(range_green,ht_leaf*wd_leaf,1)));



% evaluates all of the objects created by inverting the altered mask.
% values that do not match the profile of the carpet tape or blue
% background are set to zero
for n=1:size(STATS_range,1)
    
    pixels = STATS_range(n).PixelIdxList;
    std_range_green = std(double(STATS_range(n).PixelValues)); 
    mean_red   = mean(double(STATS_red(n).PixelValues));
    mean_green = mean(double(STATS_green(n).PixelValues));
    mean_blue  = mean(double(STATS_blue(n).PixelValues));

    
    if (std_range_green<std_range*(1+range_fudge) && mean_green>mean_blue) || ...
       (std_range_green<std_range*(1+range_fudge) && mean_red>mean_blue) || STATS_range(n).Area<50
        
        inv_leaf_mask(pixels) = 0;
    end
end

% the mask is once again reshaped and inverted, creating a mask which only
% removes the areas that meet the profile of the blue background or carpet
% tape. region props is called again in case any bits of previous leaves
% remained on the carpet tape
leaf_mask = ~reshape(inv_leaf_mask,ht_leaf,wd_leaf);
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


%  determines which object is the tag by finding the average RGB values and
%  setting the object with the highest (whitest on average) to be the tag
hist_obj2 = imhist(object_2(:,:,1));
hist_obj3 = imhist(object_3(:,:,1));
hist_obj4 = imhist(object_4(:,:,1));

mean_objs(1) = find_hist_mean(hist_obj2);
mean_objs(2) = find_hist_mean(hist_obj3);
mean_objs(3) = find_hist_mean(hist_obj4);

[mean_obj I_obj] = max(mean_objs);

if I_obj==1
    
    tag = object_2;
    
    if box_3(2)<box_4(2)
        
        colorbar = im(box_3(2):(box_4(2)+box_4(4)-1),...
                      box_3(1):(box_4(1)+box_4(3)-1),:);
    else
        
        colorbar = im(box_4(2):(box_3(2)+box_3(4)-1),...
                      box_4(1):(box_3(1)+box_3(3)-1),:);
    end
    
elseif I_obj==2
    
    tag = object_3;
    
    if box_2(2)<box_4(2)
        
        colorbar = im(box_2(2):(box_4(2)+box_4(4)-1),...
                      box_2(1):(box_4(1)+box_4(3)-1),:);
    else
        
        colorbar = im(box_4(2):(box_2(2)+box_2(4)-1),...
                      box_4(1):(box_2(1)+box_2(3)-1),:);
    end
    
else
    
    tag = object_4;
    
    if box_2(2)<box_3(2)
        
        colorbar = im(box_2(2):(box_3(2)+box_3(4)-1),...
                      box_2(1):(box_3(1)+box_3(3)-1),:);
    else
        
        colorbar = im(box_3(2):(box_2(2)+box_2(4)-1),...
                      box_3(1):(box_2(1)+box_2(3)-1),:);
    end
end


% writes the leaf, tag, and colorbar to a single .tif file
%imwrite(leaf_final,output,'tif');
%imwrite(tag,output,'WriteMode','append');
%imwrite(colorbar,output,'WriteMode','append');
    
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




