function seg_im = snake_seg(image,pot_les,its,alpha,l_size,u_size)


% determine the dimensions of 'image' for further calculations
[ht,wd,dp] = size(image);


% regionprops measures properties for each distinct region in 'pot_les'
STATS_les = regionprops(pot_les,image,'PixelList','Area','BoundingBox');


% preallocate an empty mask. this is the array to which values will be
% assigned. '1' belongs to a lesion and '0' belongs to the background
leaf_mask = false(ht,wd);
        

% for each lesion as measured by 'regionprops'
for i=1:size(STATS_les,1)
    
    if STATS_les(i).Area < u_size && STATS_les(i).Area > l_size
        
        % determine the coordinates of the potential lesion, including a 25
        % pixel window, as the boundaries of the lesion might be outside of
        % the guess
        pixel_coords = STATS_les(i).PixelList;
        box_idx = get_indices(pixel_coords(:,2),pixel_coords(:,1),ht,wd);
        

        
        % allocate the initial guess of the lesion given by 'pot_les'
        mask = zeros(ht,wd);
        mask(sub2ind([ht,wd],pixel_coords(:,2),pixel_coords(:,1))) = 1;
        
        
        % pull out the area surrounding the potential lesion and initiate
        % the active contour algorithm 'region_seg'
        seg = region_seg(image(box_idx(1):box_idx(2),box_idx(3):box_idx(4)), ...
                          mask(box_idx(1):box_idx(2),box_idx(3):box_idx(4)), ...
                          round(log10(STATS_les(i).Area)*its),alpha,false);
        
        % pixels found by 'region_seg' to belong to a lesion are added to 
        % leaf_mask
        
        [row,col] = find(seg);
        
        if ~isempty(col) && (min(col) > 1 || max(col) < wd) && (length(row) > l_size) && (length(row) < u_size)
        
        leaf_mask(box_idx(1):box_idx(2),box_idx(3):box_idx(4)) = ...
        leaf_mask(box_idx(1):box_idx(2),box_idx(3):box_idx(4)) + seg;
        end
    
    end
end

seg_im = leaf_mask;

end

function box_idx = get_indices(row,col,ht,wd)
% determines the coordinates of a window containing the lesion, including a
% 25 pixel expansion. 25 pixels is an arbitrary guess and can be altered or
% made to be dynamic

box_idx = zeros(4,1);

box_idx(1) = min(row) - 25;
box_idx(2) = max(row) + 25;
box_idx(3) = min(col) - 25;
box_idx(4) = max(col) + 25;

box_idx(box_idx<1) = 1;

if box_idx(2) > ht
    
    box_idx(2) = ht;
end

if box_idx(4) > wd
    
    box_idx(4) = wd;
end


end