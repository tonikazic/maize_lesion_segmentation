function lab_im = rgb2lab(rgb_im)

% creates uint8 L*a*b* image 'lab_i'm from sRGB image rgb_im

srgb2lab = makecform('srgb2lab');
lab_im = applycform(rgb_im,srgb2lab);

end