function [comb_x,comb_y] = collide_vectors(nav_cell)




comb_x = zeros(size(nav_cell{1,1}));
comb_y = zeros(size(nav_cell{1,1}));




for i=1:length(nav_cell)
    
   [dist_x,dist_y] = meshgrid(1:2^(i-1),1:2^(i-1));
   
   dist_x = dist_x - 2^(i-2) - 0.5;
   dist_y = dist_y - 2^(i-2) - 0.5;
    
   dist_mat = (dist_x.^2 + dist_y.^2).^0.5;
   
   dist_mat = max(max(dist_mat))-dist_mat;
   dist_mat = dist_mat./max(max(dist_mat));
   
   dist_mat(isnan(dist_mat)) = 1;
   
   exp_x = kron(nav_cell{i,2},ones(2^(i-1)));
   exp_y = kron(nav_cell{i,1},ones(2^(i-1)));
   
   conv_x = conv2(exp_x,dist_mat,'symmetric');
   conv_y = conv2(exp_x,dist_mat,'symmetric');
    
   
   comb_x = (comb_x + exp_x)./conv_x;
   comb_y = (comb_y + exp_y)./conv_y;
end






end