function [U,V] = multires_nav_stokes(im,depth,mu,lambda,its,display)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


daub_im = daubechies_97(im,depth,'off');

multi_x = cell(depth,1);
multi_y = cell(depth,1);

[sh,sv] = get_sobel_filter(3);

for i=1:depth
    
    multi_x(i) = imfilter(daub_im{i,1},sh,'circular','conv');
    multi_y(i) = imfilter(daub_im{i,1},sv,'circular','conv');
end

multi_Qx = multi_x;
multi_Qy = multi_y;


% kernels representing the finite difference methods described in the paper
% 'Li et al. 2007'
L = [0  1  0 ;...
     1 -4  1 ;...
     0  1  0];

Dxu = [0  0  0 ;...
       1 -2  1 ;...
       0  0  0];
   
Dxv  = [0  0  0 ;...
        0 -1  1 ;...
        0  1 -1];
    
Dyu = [ 0  0  0 ;...
        0 -1  1 ;...
        0  1 -1];

Dyv = [0  1  0 ;...
       0 -2  0 ;...
       0  1  0];


for i=1:its

          [U,V] = compute_nav_stokes(multi_x(j),multi_y(j),L,Dxu,Dxv,Dyu,Dyv,mu,lambda,multi_Qx(j),multi_Qy(j));
       div_mask = kron(divergence(U,V),ones(2));
       div_mask = min(min(div_mask))-div_mask;
       div_mask = max(max(div_mask))./div_mask;
    
   for j=1:depth
        
       [U,V] = compute_nav_stokes(multi_x(j),multi_y(j),L,Dxu,Dxv,Dyu,Dyv,mu,lambda,multi_Qx(j),multi_Qy(j));
       div_mask = kron(divergence(U,V),ones(2));
       div_mask = min(min(div_mask))-div_mask;
       div_mask = max(max(div_mask))./div_mask;
       
       
       
   end
end


end





function [U,V] = compute_nav_stokes(U,V,L,Dxu,Dxv,Dyu,Dyv,mu,lambda,Qx,Qy)

% repeat for the number of iterations specified by 'its'
    
    % calculate each component of the Navier-Stokes equation by convolving
    % the vertical and horizontal component matrices with the appropriate
    % finite difference kernel
    lap_x = imfilter(U,L,'circular','conv');
    lap_y = imfilter(V,L,'circular','conv');
    div_xu = imfilter(U,Dxu,'circular','conv');
    div_xv = imfilter(V,Dxv,'circular','conv');
    div_yu = imfilter(U,Dyu,'circular','conv');
    div_yv = imfilter(V,Dyv,'circular','conv');
    
    % calculate the 
    dU = mu*lap_x + (mu+lambda)*(div_xu+div_xv) + Qx.*(grad_x-U);
    dV = mu*lap_y + (mu+lambda)*(div_yv+div_yu) + Qy.*(grad_y-V);
    
    % update the gradient vector components
    U = U+dU;
    V = V+dV;
    
end
