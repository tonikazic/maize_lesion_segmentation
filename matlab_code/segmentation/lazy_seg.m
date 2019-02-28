function seg_im = lazy_seg(im,image,pot_les)


[ht wd dp] = size(im);


STATS_les = regionprops(pot_les,image,'Area','BoundingBox','Image','MaxIntensity','MinIntensity');


leaf_mask = false(ht,wd);


for i=1:size(STATS_les,1)
    
    if STATS_les(i).Area < 50000 && STATS_les(i).Area > 10
        
        box_temp = ceil(STATS_les(i).BoundingBox);
        box(1) = box_temp(1);
        box(2) = box_temp(2);
        box(3) = box_temp(1)+box_temp(3)-1;
        box(4) = box_temp(2)+box_temp(4)-1;
            
        lesion = image(box(2):box(4),box(1):box(3));
        
        seg = lesion > STATS_les(i).MaxIntensity-0.5*(STATS_les(i).MaxIntensity-STATS_les(i).MinIntensity);
        
        leaf_mask(box(2):box(4),box(1):box(3)) = ...
        leaf_mask(box(2):box(4),box(1):box(3)) + seg;
    
    end
end
close all

seg_mask = uint8(repmat(leaf_mask,[1 1 3]));


seg_im = im.*seg_mask;

end