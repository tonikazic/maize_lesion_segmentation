function [buff_im U_pad L_pad] = expand_im(image,depth)
% due to the nature of the wavelet transform, the transformed image must
% have dimensions (n*2^depth,m*2^depth), where n and m are arbitrary integers.


% determines the height, width, and depth of the image;
[ht wd dp] = size(image);

% the image must be a multiple of 2^depth, so the image is padded.
% 'prev_LL' will be used in the loop.
size_tiles = 2^depth;

vert_pad = ceil(ht/size_tiles+1)*size_tiles;
horz_pad = ceil(wd/size_tiles+1)*size_tiles;

buff_im = zeros(vert_pad,horz_pad);

U_pad = floor((vert_pad - ht)/2); % pad above the image
D_pad = ceil((vert_pad - ht)/2); % pad below the image
L_pad = floor((horz_pad - wd)/2); % pad to left of the image
R_pad = ceil((horz_pad - wd)/2); % pad to right of the image


% each pad is a reflection of the image across the corresponding edge
buff_im((U_pad+1):(U_pad+ht),(L_pad+1):(L_pad+wd)) = image;
buff_im(1:U_pad,(L_pad+1):(L_pad+wd)) = flipud(image(1:U_pad,:));
buff_im((ht+U_pad+1):(vert_pad),(L_pad+1):(L_pad+wd)) = flipud(image((ht-D_pad)+1:ht,:));
buff_im(:,1:L_pad) = fliplr(buff_im(:,(L_pad+1):2*L_pad));
buff_im(:,(wd+L_pad+1):(horz_pad)) = fliplr(buff_im(:,(wd+L_pad-R_pad+1):(wd+L_pad)));


end