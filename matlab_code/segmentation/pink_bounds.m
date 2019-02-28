function pink_im = pink_bounds(im,bound_mask)


[ht wd] = size(bound_mask);

pink_vec = reshape(im,ht*wd,3);
mask_vec = reshape(bound_mask,ht*wd,1);

pink_vec(mask_vec>0,1) = 255;
pink_vec(mask_vec>0,2) = 20;
pink_vec(mask_vec>0,3) = 147;


pink_im = reshape(pink_vec,ht,wd,3);

end