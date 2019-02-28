% This script creates a rough segment of the input image 'filename' using
% the navier_stokes algorithm, which diffuses gradients, followed by the
% grad_flow algorithm, which finds areas of concentrated gradient. It then
% then finds points of interest and highlights them with pink. 






filename = '/Users/mtlb/me/derek/cal_images/masked/DSC_1289.tif';
[path name ext] = fileparts(filename);


% create cform for lab conversion
srgb2lab = makecform('srgb2lab'); 
im=imread(filename);
lab_im = applycform(im,srgb2lab);



[nav_x nav_y] = navier_stokes(lab_im,0.02,0.02,1000,25);
nav_m = (nav_x.^2 + nav_y.^2).^0.5;
[sink_im flow_im] = grad_flow(nav_x,nav_y,10);



bdist = bwdist(logical(sink_im));
water = ~watershed(bdist);



pink_roi = pink_bounds(im,sink_clean);
pink_bounds = pink_bounds(im,water);


roi_filename = strcat('/Users/mtlb/me/derek/roi_test/lab_comb/pink/',name,'.png');
bounds_filename = strcat('/Users/mtlb/me/derek/roi_test/lab_comb/rough_seg/',name,'.png');


imwrite(pink_roi,roi_filename);
imwrite(pink_bounds,bounds_filename);

clear all;
