function [leaf_coords] = mtlb_mask(img_leaf)
%This function gives the coordinates for the leaf

leaf_coords = edge(img_leaf(:,:,1), 'canny');
se90 = strel('line',3,90);
se0 = strel('line',3,0);
leaf_dil = imdilate(leaf_coords,[se90,se0]);
leaf_dil(:,1) = 1;                  %without setting edges to white, the 
leaf_dil(:,size(leaf_dil,2)) = 1;   %leaf won't fill 
leaf_fill = imfill(leaf_dil, 'holes');
imshow(leaf_fill);
end

