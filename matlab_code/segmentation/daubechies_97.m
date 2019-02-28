function [daub_im,U_pad,L_pad] = daubechies_97(image,depth,display)
% 'daubechies_97' decomposes 'image' according to the CDF 9/7 wavelet. This
% produces 'daub_im', which is a depth-by-4 cell array. The {n,1} elements
% are the scaling images at each depth, the {n,2} elements are the LH elements
% (relating to the vertical differences), the {n,3} elements are the HL
% elements (relating to the horizontal differences), and the {n,4} are the
% HH elements(relating to the diagonal differences).
%
% This framework is used in JPEG 2000 compression, as described in:
% JPEG 2000 http://faculty.gvsu.edu/aboufade/web/wavelets/student_work/EF/how-works.html



% ensures the image is the 'double' format, necessary for convolution
image = double(image); 

[prev_LL,U_pad,L_pad] = expand_im(image,depth);

% build lowpass decomposition filter
kern_l = zeros(9); 
kern_l(5,5:9) = [0.602949018236 ...
                 0.266864118443 ...
                -0.078223266529 ...
                -0.016864118443 ...
                 0.026748757411];
kern_l(5,1:4) = kern_l(5,9:-1:6);

% build highpass decomposition filter
kern_h = zeros(9);
kern_h(5,5:9) = [1.11508705 ...
                -0.591271763114 ...
                -0.057543526229 ...
                 0.091271763114 ...
                 0];
kern_h(5,1:4) = kern_h(5,9:-1:6);

% preallocates the daub_im cell array
daub_im = cell(depth,4);

for i=1:depth
    
    if strcmp(display,'on');
        imshow(mat2gray(prev_LL));
        pause(0.5);
    end
    
    im_L = imfilter(prev_LL,kern_l,'symmetric'); % lowpass filter horizontally
    im_L = im_L(:,1:2:end); % downsample horizontally
    
    im_H = imfilter(prev_LL,kern_h,'symmetric'); % highpass filter horizontally 
    im_H = im_H(:,2:2:end); % downsample horizontally 
    
    im_LL = imfilter(im_L,kern_l','symmetric'); % lowpass filter vertically
    im_LL = im_LL(1:2:end,:); % downsample vertically
    
    im_LH = imfilter(im_L,kern_h','symmetric'); % highpass filter vertically
    im_LH = im_LH(2:2:end,:); % downsample vertically
    
    im_HL = imfilter(im_H,kern_l','symmetric'); % lowpass filter vertically
    im_HL = im_HL(1:2:end,:); % downsample vertically
    
    im_HH = imfilter(im_H,kern_h','symmetric'); % highpass filter vertically
    im_HH = im_HH(2:2:end,:); % downsample vertically
    
    
    daub_im{i,1} = im_LL; % scaling image at depth i
    daub_im{i,2} = im_LH; % vertical differences at depth i
    daub_im{i,3} = im_HL; % horizontal differences at depth i
    daub_im{i,4} = im_HH; % diagonal differences at depth i
    
    prev_LL = im_LL; % uses the previous scaling image for the next decompositon
    
end
    
if strcmp(display,'on');
    imshow(mat2gray(prev_LL));
    pause(0.5);
end

end




