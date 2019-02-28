function orange_im = orange_bounds(im,flow_im)
% this function creates an orange boundary around each unique flow basin in
% flow_im. these basins have been computed by the grad_flow algorithm, and
% each one leads to a unique sink. they are each identified by a unique
% number.

[ht wd dp] = size(im);

max_idx = max(max(flow_im));

orange_r = im(:,:,1);
orange_g = im(:,:,2);
orange_b = im(:,:,3);


for i=1:max_idx
    
    current_pix = flow_im==i;
    
    if ~isempty(find(current_pix,1))
    
    bounds = bwperim(current_pix);
    

    orange_r(bounds) = 255;
    orange_g(bounds) = 165;
    orange_b(bounds) = 0;
    end
    
    
end


orange_im = cat(3,orange_r,orange_g,orange_b);

end