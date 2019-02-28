function bound_mask = segment_sobel(im,sob_num)


[ht wd] = size(im(:,:,1));


srgb2lab = makecform('srgb2lab');
lab2srgb = makecform('lab2srgb');


lab_im = applycform(im,srgb2lab);

lab_adjust = lab_im;
lab_adjust(:,:,2) = imadjust(lab_im(:,:,2));
lab_adjust(:,:,3) = imadjust(lab_im(:,:,3));

rgb_adjust = applycform(lab_adjust,lab2srgb);


pot_les = im2bw(rgb_adjust(:,:,1));

[sh sv] = get_sobel_filter(sob_num);

rx = imfilter(double(rgb_adjust(:,:,1)),sh);
ry = imfilter(double(rgb_adjust(:,:,1)),sv);
M = (rx.^2 + ry.^2).^0.5;

bound_mask = zeros(ht,wd);


STATS_les = regionprops(pot_les,'Area','BoundingBox');

for i=1:size(STATS_les,1)
    
    box_temp = ceil(STATS_les(i).BoundingBox);
    box(1) = box_temp(1)-ceil(0.2*box_temp(3));
    box(2) = box_temp(2)-ceil(0.2*box_temp(4));
    box(3) = box_temp(1)+box_temp(3)+ceil(0.2*box_temp(3))-1;
    box(4) = box_temp(2)+box_temp(4)+ceil(0.2*box_temp(4))-1;
        
    if box_temp(1) < ceil(0.2*box_temp(3))+1
        box(1) = 1;
    end
                
    if box_temp(2) < ceil(0.2*box_temp(4))+1
        box(2) = 1;
    end
               
    if (box_temp(1)+box_temp(3)) > (wd-ceil(0.2*box_temp(3)))
        box(3) = wd;
    end
            
    if (box_temp(2)+box_temp(4)) > (ht-ceil(0.2*box_temp(4)))
        box(4) = ht;
    end
            
    les_grad = M(box(2):box(4),box(1):box(3));
    les_x    = rx(box(2):box(4),box(1):box(3));
    les_y    = ry(box(2):box(4),box(1):box(3));
        
    seeds = get_seeds(les_grad);
    
    ridges = ridge_walk(seeds,les_x,les_y);
    
    sum_ridges = sum(uint8(ridges),3); 
    
    
        
    bound_mask(box(2):box(4),box(1):box(3)) = ...
    bound_mask(box(2):box(4),box(1):box(3)) + sum_ridges;
    
    
end


end



function seeds = get_seeds(grad_im)

seeds = zeros(10,2);

for i=1:10
    
    [max_y vex_y] = max(grad_im);
    [max_x idx_x] = max(max_y);
    idx_y = (vex_y(idx_x));
    
    seeds(i,1) = idx_x;
    seeds(i,2) = idx_y;
    
    grad_im(idx_y,idx_x);
end

end






