function [STATS_seg,STATS_gt,true_positives,false_positives,false_negatives,precision,recall,F1] = calc_concordance_measures(seg_im,gt_im)

[seg_matches,gt_matches] = get_matches(seg_im,gt_im);

% preallocate the array of measures for the segmented image
STATS_seg(length(seg_matches)).matches = [];
STATS_seg(length(seg_matches)).true_positive = [];
STATS_seg(length(seg_matches)).false_positive = [];
STATS_seg(length(seg_matches)).over_segmented = [];
STATS_seg(length(seg_matches)).under_segmented = [];

% preallocate the array of measures for the ground truth image
STATS_gt(length(gt_matches)).matches = [];
STATS_gt(length(gt_matches)).false_negative = [];
STATS_gt(length(gt_matches)).over_segmented = [];
STATS_gt(length(gt_matches)).under_segmented = [];

for i=1:length(seg_matches)
   
    if seg_matches(i,2) == 0
        
        STATS_seg(i).true_positive = 0;
        STATS_seg(i).false_positive = 1;
        
    else

        if ~isempty(STATS_gt(seg_matches(i,2)).matches)
            
            STATS_gt(seg_matches(i,2)).over_segmented = 1;
            STATS_gt(seg_matches(i,2)).under_segmented = 0;
            STATS_seg(i).over_segmented = 1;
            STATS_seg(i).under_segmented = 0;
        end
        
        STATS_gt(seg_matches(i,2)).matches = [STATS_gt(seg_matches(i,2)).matches,seg_matches(i,1)];
        STATS_seg(i).matches = [STATS_seg(i).matches,seg_matches(i,2)];
        STATS_seg(i).true_positive = 1;
        STATS_seg(i).false_positive = 0;
        STATS_gt(seg_matches(i,2)).false_negative = 0;
    end
end


for i=1:length(gt_matches)
    
    if gt_matches(i,2) == 0
        
        if isempty(STATS_gt(i).matches)
            
            STATS_gt(i).false_negative = 1;
        end
        
    else
        
        if ~isempty(STATS_seg(gt_matches(i,2)).matches) && ~ismember(gt_matches(i,2),STATS_seg(gt_matches(i,2)).matches)
            
            STATS_seg(gt_matches(i,2)).over_segmented = 0;
            STATS_seg(gt_matches(i,2)).under_segmented = 1;
            STATS_gt(i).over_segmented = 0;
            STATS_gt(i).under_segmented = 1;
        end

        STATS_seg(gt_matches(i,2)).matches = [STATS_seg(gt_matches(i,2)).matches,gt_matches(i,1)];
        STATS_gt(i).matches = [STATS_gt(i).matches,gt_matches(i,2)];
        STATS_seg(gt_matches(i,2)).true_positive = 1;
        STATS_seg(gt_matches(i,2)).false_positive = 0;
        STATS_gt(i).false_negative = 0;

    end
end

gt_table = struct2table(STATS_gt);
seg_table = struct2table(STATS_seg);

true_positives = length(find(seg_table.true_positive(:)));
false_positives = length(find(seg_table.false_positive(:)));
false_negatives = length(find(gt_table.false_negative(:)));

precision = true_positives / (true_positives + false_positives);
recall = true_positives / (true_positives + false_negatives);
F1 = 2*true_positives/(2*true_positives + false_positives + false_negatives);

end