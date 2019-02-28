function oce_val = oce_calculator(imA,imB,flag)



imA = logical(imA);
imB = logical(imB);



[ht wd dp] = size(imA);



STATSA = regionprops(imA,'Area','PixelIdxList');
STATSB = regionprops(imB,'Area','PixelIdxList');



imB_idx = find(imB);
imA_idx = find(imA);



areaA = length(find(imA));




M = length(STATSA);
N = length(STATSB);



oce_val = 0;



A_overlap = zeros(ht,wd);
B_overlap = zeros(ht,wd);



for j=1:M
    
    PixelIdxList = STATSA(j).PixelIdxList;
    
    A_overlap(PixelIdxList(ismember(PixelIdxList,imB_idx))) = j;
end 



for i=1:N
    
   PixelIdxList = STATSB(i).PixelIdxList; 
    
   B_overlap(PixelIdxList(ismember(PixelIdxList,imA_idx))) = i;  
end 



for j = 1:M
   
    W_j = STATSA(j).Area / areaA;
    
    B_idx = unique(B_overlap(A_overlap == j));

    N_sum = 0;
    
    
    
    if ~isempty(B_idx)
    
        for i=1:length(B_idx)
    
            W_ji = STATSB(B_idx(i)).Area / sum([STATSB(B_idx).Area]);
            
            
            
            if strcmpi(flag,'dice')
                
                N_sum = N_sum + (length(find(A_overlap == j)) / ...
                (STATSA(j).Area + STATSB(B_idx(i)).Area)) * W_ji;
                
            
            
            else
                
                N_sum = N_sum + (length(find(A_overlap == j)) / ...
                (STATSA(j).Area + STATSB(B_idx(i)).Area - length(find(A_overlap == j)))) * W_ji;
            end
        end
        
        
        oce_val = oce_val + (1 - N_sum) * W_j;
        
    else
        
        oce_val = oce_val + W_j;
    end 
end
    
    
   
end