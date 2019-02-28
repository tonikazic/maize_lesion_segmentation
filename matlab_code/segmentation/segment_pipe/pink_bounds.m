function pink_im = pink_bounds(im,bound_mask)
% 'pink_bounds' creates an image where all positive pixels in the image
% 'bound mask' will be made to be pink in the image 'im'. 'pink_im' is then
% returned

% dimensions of 'bound_mask' to be used in further calculations
[ht,wd] = size(bound_mask);

% create vectors to avoid loops, allowing for logical indexing to be
% utilized
pink_vec = reshape(im,ht*wd,3);
mask_vec = reshape(bound_mask,ht*wd,1);

% make appropriate pixels in 'im' pink
pink_vec(mask_vec>0,1) = 255;
pink_vec(mask_vec>0,2) = 20;
pink_vec(mask_vec>0,3) = 147;


pink_im = reshape(pink_vec,ht,wd,3);

end