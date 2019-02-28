function seg_im = segment_sinks(flow_im,im)
% this function segments independent sinks (sinks with different values)
% using the active contours algorithm 'region_seg.'


[ht,wd,dp] = size(im);

% the highest value in the flow matrix corresponds to the number of 
% independent sinks found by the 'grad_flow' algorithm
num_sinks = max(max(flow_im)); 
seg_im = zeros(ht,wd);


for i=1:num_sinks
    
    mask = flow_im==i;
    
    [row,col] = find(mask);
   
    if length(row) > 10 && length(row) < 50000 && ...
       length(col) > 10 && length(col) < 50000
        
        box_idx = get_indices(row,col,ht,wd);
    
        seg_les = region_seg(im(box_idx(1):box_idx(2),box_idx(3):box_idx(4)), ...
                           mask(box_idx(1):box_idx(2),box_idx(3):box_idx(4)),50,0.25,false);
                   
        seg_im(box_idx(1):box_idx(2),box_idx(3):box_idx(4)) = ...
        seg_im(box_idx(1):box_idx(2),box_idx(3):box_idx(4)) + seg_les;
    
    elseif length(row) > 2 && length(col) > 2
        
        seg_im(flow_im==i) = 1;
    end
    
end


end



function box_idx = get_indices(row,col,ht,wd)

box_idx = zeros(4,1);

box_idx(1) = min(row) - 25;
box_idx(2) = max(row) + 25;
box_idx(3) = min(col) - 25;
box_idx(4) = max(col) + 25;

box_idx(box_idx<1) = 1;
box_idx(box_idx>wd) = wd;

if box_idx(2) > ht
    
    box_idx(2) = ht;
end


end