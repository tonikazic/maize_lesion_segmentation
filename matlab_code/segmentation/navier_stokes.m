function [U,V] = navier_stokes(del_x,del_y,mu,lambda,thresh,its,display)

%
% This function is an application of the method described in "3D cell 
% nuclei segmentation based on gradient flow tracking", Li et al. 2007
% (found at http://www.biomedcentral.com/1471-2121/8/40.) In the original
% article, the method is applied in three dimensions, but in this 
% application it has been reduced to two.
%
%
%

% determine the dimensions of the matrices for future calculations
[ht,wd,dp] = size(del_x);

% grad_x 
grad_x = del_x;
grad_y = del_y;

U = grad_x;
V = grad_y;

M = (U.^2 + V.^2).^0.5;
thresh_idx = M<thresh;

Qx = grad_x;
Qy = grad_y;

Qx(thresh_idx) = 0;
Qy(thresh_idx) = 0;


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

    
    % display the divergence of the field being calculated, colored
    % according to the relative values
    if strcmpi(display,'on')
        imshow(mat2gray(divergence(U,V))),colormap(jet);
        pause(0.001);
    end
    
end

    
end




