function [tp,fp,fn] = calc_tp_fp_fn(seg_matches,gt_matches)


    % calculate the true-positive number
    cat_vec = vertcat(gt_matches,fliplr(seg_matches));
    tp = length(unique(cat_vec(all(cat_vec,2),1)));

    % calculate the false-positive number
    cat_vec = vertcat(seg_matches,fliplr(gt_matches));
    fp = length(seg_matches) - length(find(unique(cat_vec(all(cat_vec,2),1))));
    
    % calculate the false-negative number
    cat_vec = vertcat(gt_matches,fliplr(seg_matches));
    fn = length(gt_matches) - length(find(unique(cat_vec(all(cat_vec,2),1))));    


end