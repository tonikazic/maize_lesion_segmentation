function [seg_matches,gt_matches] = get_matches(seg_im,gt_im)


STATS_seg = regionprops(logical(seg_im),'Centroid');
STATS_gt = regionprops(logical(gt_im),'Centroid');

seg_idx = find(seg_im);
gt_idx = find(gt_im);

[ht wd dp] = size(seg_im);

seg_matches = [(1:max(max(seg_im)))' zeros(max(max(seg_im)),1)];

gt_matches = [(1:max(max(gt_im)))' zeros(max(max(gt_im)),1)];

for i=1:length(STATS_seg)
    
    cent_idx = round(STATS_seg(i).Centroid);
    cent_idx = sub2ind([ht,wd],cent_idx(2),cent_idx(1));
    
    if ismember(cent_idx,gt_idx)
        
        seg_matches(i,2) = gt_im(cent_idx);
    end
    
end

for j=1:length(STATS_gt)
   
    cent_idx = round(STATS_gt(j).Centroid);
    cent_idx = sub2ind([ht,wd],cent_idx(2),cent_idx(1));
    
    if ismember(cent_idx,seg_idx)
        
        gt_matches(j,2) = seg_im(cent_idx);
    end
end





end