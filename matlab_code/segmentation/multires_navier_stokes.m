function [nav_x nav_y] = multires_navier_stokes(im,dp,mu,lambda,thresh,its,display)




daub_im = daubechies_97(im,dp,'off');

im = expand_im(im,dp);

[ht wd] = size(im);

[dp br] = size(daub_im);

grad_cell = cell(dp+1,2);


[sh sv] = get_sobel_filter(3);

% calculate the vertical and horizontal gradients on original image
grad_cell{1,1} = imfilter(im,sv,'symmetric');
grad_cell{1,2} = imfilter(im,sh,'symmetric');

% calculate the vertical and horizontal gradients for all resolutions
for i=1:dp
    
    grad_cell{i+1,1} = imfilter(daub_im{i,1},sv,'symmetric');
    grad_cell{i+1,2} = imfilter(daub_im{i,2},sh,'symmetric');
end


[X Y] = meshgrid(1:size(im,2),1:size(im,1));
X_vec = reshape(X,ht*wd,1);
Y_vec = reshape(Y,ht*wd,1);

delt_cell = grad_cell;

U = grad_cell{1,2};
V = grad_cell{1,1};

G = fspecial('laplacian');

Dxu = [0  0  0 ;...
       1 -2  1 ;...
       0  0  0];
   
Dxv = [0  0  0 ;...
       0 -1  1 ;...
       0  1 -1];
    
Dyu = [0  0  0 ;...
       0 -1  1 ;...
       0  1 -1 ];

Dyv = [0  1  0 ;...
       0 -2  0 ;...
       0  1  0 ];
   
delt_x = zeros(ht,wd,dp+1);
delt_y = zeros(ht,wd,dp+1);
delt_m = zeros(ht,wd,dp+1);

for i=1:its

    for j=1:dp+1
        
        lap_x = imfilter(delt_cell{j,2},G,'circular','conv');
        lap_y = imfilter(delt_cell{j,1},G,'circular','conv');
        div_xu = imfilter(delt_cell{j,2},Dxu,'circular','conv');
        div_xv = imfilter(delt_cell{j,1},Dxv,'circular','conv');
        div_yu = imfilter(delt_cell{j,2},Dyu,'circular','conv');
        div_yv = imfilter(delt_cell{j,1},Dyv,'circular','conv');
    
        delt_cell{j,2} = mu*lap_x + (mu+lambda)*(div_xu+div_xv) + (grad_cell{j,2}-delt_cell{j,2});
        delt_cell{j,1} = mu*lap_y + (mu+lambda)*(div_yv+div_yu) + (grad_cell{j,1}-delt_cell{j,1});
      
        delt_x(:,:,j) = kron(delt_cell{j,2},ones(2^(j-1)));
        delt_y(:,:,j) = kron(delt_cell{j,1},ones(2^(j-1)));
%        delt_m(:,:,j) = (delt_x(:,:,j).^2 + delt_y(:,:,j).^2).^0.5;
        
    end
    
%    [C idx] = max(delt_m,[],3); % find the slice with the gratest change
%    idx_vec = reshape(idx,ht*wd,1);
    
    %lin_idx = sub2ind(size(delt_m),Y_vec,X_vec,idx_vec);
    
    %dU = reshape(delt_x(lin_idx),ht,wd);
    %dV = reshape(delt_y(lin_idx),ht,wd);
    
    dU = mean(delt_x,3);
    dV = mean(delt_y,3);
    
    U = U + dU;
    V = V + dV;
    
%    imshow(mat2gray((U.^2 + V.^2).^0.5*3));

if strcmpi(display,'on')
    imshow(mat2gray(divergence(U,V))),colormap(jet);
%    quiver(flipud(U(293:345,1870:1937)),flipud(-V(293:345,1870:1937)));
%    quiver(flipud(U(41:53,205:227)),flipud(-V(41:53,205:227)));
    %quiver(U,V);
    pause(0.001);
end
    
end


nav_x = U;
nav_y = V;

    
end