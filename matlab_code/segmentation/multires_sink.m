function [nav_cell,navx_stack,navy_stack,div_cell,div_im] = multires_sink(image,depth)


% decompose image into different resolution images using the wavelet basis
% described by Ingrid Daubechies
[daub_im,y_coord,x_coord] = daubechies_97(image,depth,'off');

% ensure the original resolution image is also expanded about its borders
% to ensure it is evenly divisible by 2^depth
image = expand_im(image,depth); 


% find the dimensions of the image for future calculations
[ht,wd,dp] = size(image);

nav_cell = cell(depth+1,2);
div_cell = cell(depth+1,1);
navx_stack = zeros(ht,wd,depth+1);
navy_stack = zeros(ht,wd,depth+1);
div_im = zeros(ht,wd,depth+1);

%[X,Y] = meshgrid(1:wd,1:ht);
%X_vec = reshape(X,ht*wd,1);
%Y_vec = reshape(Y,ht*wd,1);

[sh,sv] = get_sobel_filter(3);

del_x = imfilter(image,sh,'symmetric');
del_y = imfilter(image,sv,'symmetric');
[nav_cell{1,2},nav_cell{1,1}] = navier_stokes(del_x,del_y,0.02,0.02,1000,10,'off');
div_cell{1,1} = divergence(nav_cell{1,2},nav_cell{1,1});
navx_stack(:,:,1) = nav_cell{1,2};
navy_stack(:,:,1) = nav_cell{1,1};
div_im(:,:,1) = divergence(nav_cell{1,2},nav_cell{1,1});
%[sink_im flow_im] = grad_flow(nav_x,nav_y,-50);
%seg_im{1} = segment_sinks(flow_im,image);



for i=1:depth
    
    % calculate gradient values of image at each resolution using a sobel
    % filter
    del_x = imfilter(daub_im{i,1},sh,'symmetric');
    del_y = imfilter(daub_im{i,1},sv,'symmetric');
    
    [nav_cell{i+1,2},nav_cell{i+1,1}] = navier_stokes(del_x,del_y,0.02,0.02,1000,25,'off'); % constants have been decided upon empirically. subject to change
    div_cell{i+1,1} = divergence(nav_cell{i+1,2},nav_cell{i+1,1});
    navx_stack(:,:,i+1) = kron(nav_cell{i+1,2},ones(2^i));
    navy_stack(:,:,i+1) = kron(nav_cell{i+1,1},ones(2^i));
    div_im(:,:,i+1) = kron(divergence(nav_cell{i+1,2},nav_cell{i+1,1}),ones(2^i));
    
end

%[min_im,idx] = min(div_im,[],3);
%idx_vec = reshape(idx,ht*wd,1);

%lin_idx = sub2ind(size(div_im),Y_vec,X_vec,idx_vec);



%nav_x = reshape(navx_stack(lin_idx),ht,wd);
%nav_y = reshape(navy_stack(lin_idx),ht,wd);

%nav_x = sum(navx_stack,3);
%nav_y = sum(navy_stack,3);

%div_im = divergence(nav_x,nav_y);

%imshow(mat2gray(div_im),colormap('jet'));

%[sink_im flow_im] = grad_flow(nav_x,nav_y,min_im,-50);
%seg_im = segment_sinks(flow_im,image);

end