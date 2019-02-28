function [nav_cell,navx_stack,navy_stack,div_cell,div_im,y_coord,x_coord] = multires_sink(image,depth,mu,lambda,thresh,its)
% work in progress. not all arrays assigned are used


% decompose image into different resolution images using the wavelet basis
% described by Ingrid Daubechies
[daub_im,y_coord,x_coord] = daubechies_97(image,depth,'off');

% ensure the original resolution image is also expanded about its borders
% to ensure it is evenly divisible by 2^depth
image = mat2gray(expand_im(image,depth))*255; 


% find the dimensions of the image for future calculations
[ht,wd,dp] = size(image);

nav_cell = cell(depth+1,2);
div_cell = cell(depth+1,1);
navx_stack = zeros(ht,wd,depth+1);
navy_stack = zeros(ht,wd,depth+1);
div_im = zeros(ht,wd,depth+1);

[sh,sv] = get_sobel_filter(3);

del_x = imfilter(image,sh,'symmetric');
del_y = imfilter(image,sv,'symmetric');

[nav_cell{1,2},nav_cell{1,1}] = navier_stokes(del_x,del_y,mu,lambda,thresh,its,'off');
div_cell{1,1} = divergence(nav_cell{1,2},nav_cell{1,1});
navx_stack(:,:,1) = nav_cell{1,2};
navy_stack(:,:,1) = nav_cell{1,1};
div_im(:,:,1) = divergence(nav_cell{1,2},nav_cell{1,1});



for i=1:depth
    
    % calculate gradient values of image at each resolution using a sobel
    % filter
    del_x = imfilter(daub_im{i,1},sh,'symmetric');
    del_y = imfilter(daub_im{i,1},sv,'symmetric');
    
    [nav_cell{i+1,2},nav_cell{i+1,1}] = navier_stokes(del_x,del_y,mu,lambda,thresh,its,'off'); % constants have been decided upon empirically. subject to change
    div_cell{i+1,1} = divergence(nav_cell{i+1,2},nav_cell{i+1,1});

    
    kern = zeros(2^i+1);
    kern(2^(i-1)+1,2^(i-1)+1) = 1;
    kern = 1./(bwdist(kern)+1);
    kern = kern/(sum(sum(kern)));
    
    navx_stack(:,:,i+1) = conv2(kron(nav_cell{i+1,2},ones(2^i)),kern,'symmetric');
    navy_stack(:,:,i+1) = conv2(kron(nav_cell{i+1,1},ones(2^i)),kern,'symmetric');
    div_im(:,:,i+1) = conv2(kron(divergence(nav_cell{i+1,2},nav_cell{i+1,1}),ones(2^i)),kern,'symmetric');
    
end


end