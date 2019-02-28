function lab_comb = make_comb_im(rgb_im,a,b,c)

% script to convert sRGB image 'rgb_im' to a linear transformation of the
% channels of a L*a*b* image. a, b, and c are the coefficients for the 
% respective channels

lab_im = rgb2lab(rgb_im);
lab_IM = double(lab_im);
lab_comb = (a*lab_IM(:,:,1).^2 + b*lab_IM(:,:,2) + c*lab_IM(:,:,3)).^0.5;

end