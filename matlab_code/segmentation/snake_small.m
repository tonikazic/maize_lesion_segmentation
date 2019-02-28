function seg_im = snake_small(im,pot_les)

[ht wd dp] = size(im);

%srgb2lab = makecform('srgb2lab');
%lab2srgb = makecform('lab2srgb');
%lab_im = applycform(im,srgb2lab);

%lab_im(:,:,2) = imadjust(lab_im(:,:,2));
%lab_im(:,:,3) = imadjust(lab_im(:,:,3));

%rgb_im = applycform(lab_im,lab2srgb);

%pot_les = im2bw(rgb_im(:,:,1));

%ab = double(lab_im(:,:,2:3));
%k_mat = reshape(ab,ht*wd,2);

%[c_idx c_cent] = kmeans(k_mat,3,'Replicates',3);

%[max_b idx_int] = max(c_cent(:,2));

%pixel_labels = reshape(c_idx,ht,wd);

%pot_les = true(ht,wd);

%pot_les(pixel_labels ~= idx_int) = 0;  

image = double(im(:,:,1));

STATS_les = regionprops(pot_les,image,'Area','BoundingBox','MeanIntensity');


leaf_mask = false(size(im,1),size(im,2));

%image = double(lab_im(:,:,2));

for i=1:size(STATS_les,1)
    
%    if STATS_les(i).Area < 50000 && STATS_les(i).Area > 10 && STATS_les(i).MeanIntensity > 0
        
        mask = false(ht,wd);

        box_temp = ceil(STATS_les(i).BoundingBox);
        mask(box_temp(2):(box_temp(2)+box_temp(4)-1),...
             box_temp(1):(box_temp(1)+box_temp(3)-1)) = 1;
        
    
        seg = region_seg(image,mask,50,0.5,false);
        
        leaf_mask(box_temp(2):(box_temp(2)+box_temp(4)-1),...
                  box_temp(1):(box_temp(1)+box_temp(3)-1)) = ...
        leaf_mask(box_temp(2):(box_temp(2)+box_temp(4)-1),...
                  box_temp(1):(box_temp(1)+box_temp(3)-1)) + seg;
    
    
%    end
end
close all

seg_mask = uint8(repmat(leaf_mask,[1 1 3]));


seg_im = im.*seg_mask;

end