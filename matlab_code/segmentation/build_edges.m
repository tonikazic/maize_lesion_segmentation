function edge_im = build_edges(daub_im,display)

% find the depth and width of the daub_im
[dp wd] = size(daub_im);


% build lowpass synthesis filter
kern_l = zeros(9);
kern_l(5,5:9) = [1.11508705 ...
                 0.591271763114 ...
                -0.057543526229 ...
                -0.091271763114 ...
                 0];
kern_l(5,1:4) = kern_l(5,9:-1:6);

% build highpass synthesis filter
kern_h = zeros(9);
kern_h(5,5:9) = [0.602949018236 ...
                -0.266864118443 ...
                -0.078223266529 ...
                 0.016864118443 ...
                 0.026748757411];
kern_h(5,1:4) = kern_h(5,9:-1:6);

% set 'prev_im' to be the zeros
prev_im = daub_im{dp,1};
edge_im = cell(dp,2);

for i=dp:-1:1
    
    if strcmp(display,'on')
        imshow(mat2gray(prev_im));
        pause(0.5);
    end

    
    im_LL = kron(prev_im,[1;0]); % upsample vertically
    im_LL = imfilter(im_LL,kern_l','symmetric'); % lowpass filter vertically

    im_LH = kron(daub_im{i,2},[0;1]); % upsample vertically
    im_LH = imfilter(im_LH,kern_h','symmetric'); % highpass filter vertically
    
    im_L = im_LL + im_LH; % combine the scaling and vertical detail images
    im_L = kron(im_L,[1 0]); % upsample horizontally
    im_L = imfilter(im_L,kern_l,'symmetric'); % lowpass filter horizontally
    
    im_HL = kron(daub_im{i,3},[1;0]); % upsample vertically
    im_HL = imfilter(im_HL,kern_l','symmetric'); % lowpass filter vertically

    im_HH = kron(daub_im{i,4},[0;1]); % upsample vertically
    im_HH = imfilter(im_HH,kern_h','symmetric'); % highpass filter vertically
    
    im_H = im_HL + im_HH; % combine the horizontal and diagonal detail images
    im_H = kron(im_H,[0 1]); % upsample horizontally
    im_H = imfilter(im_H,kern_h,'symmetric'); % highpass filter horizontally
    
    
    prev_im = im_L + im_H; % reset prev_im to be the next scaling image
    edge_im{i} = im_H;
    
end









end