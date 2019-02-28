function seg_im = snake_seg(image,pot_les,its)

[ht wd dp] = size(image);

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

%image = double(im(:,:,1));

%pot_les = bwconvhull(pot_les);

STATS_les = regionprops(pot_les,image,'Image','PixelList','Area','BoundingBox','MeanIntensity');


leaf_mask = false(ht,wd);

%image = double(lab_im(:,:,2));
        
for i=1:size(STATS_les,1)
    
    if STATS_les(i).Area < 10000 && STATS_les(i).Area > 5
        
        pixel_coords = STATS_les(i).PixelList;
        box_idx = get_indices(pixel_coords(:,2),pixel_coords(:,1),ht,wd);
        
        mask = zeros(ht,wd);
        mask(sub2ind([ht,wd],pixel_coords(:,2),pixel_coords(:,1))) = 1;
    
        seg = region_seg(image(box_idx(1):box_idx(2),box_idx(3):box_idx(4)), ...
                          mask(box_idx(1):box_idx(2),box_idx(3):box_idx(4)),round(log10(STATS_les(i).Area)*its),0.25,false);
        
        leaf_mask(box_idx(1):box_idx(2),box_idx(3):box_idx(4)) = ...
        leaf_mask(box_idx(1):box_idx(2),box_idx(3):box_idx(4)) + seg;
    
    
    end
end
close all

%seg_mask = uint8(repmat(leaf_mask,[1 1 3]));


seg_im = leaf_mask;

end

function box_idx = get_indices(row,col,ht,wd)

box_idx = zeros(4,1);

box_idx(1) = min(row) - 25;
box_idx(2) = max(row) + 25;
box_idx(3) = min(col) - 25;
box_idx(4) = max(col) + 25;

box_idx(box_idx<1) = 1;
box_idx(box_idx>wd) = wd;

if box_idx(2) > ht
    
    box_idx(2) = ht;
end


end