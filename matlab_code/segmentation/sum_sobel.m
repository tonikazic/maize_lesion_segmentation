function [x_sum y_sum m_sum] = sum_sobel(im)


IM = double(im);


[sh3 sv3] = get_sobel_filter(3);
sh3 = -sh3;
[sh5 sv5] = get_sobel_filter(5);
sh5 = -sh5;
[sh7 sv7] = get_sobel_filter(7);
sh7 = -sh7;
[sh9 sv9] = get_sobel_filter(9);
sh9 = -sh9;

rx3 = imfilter(IM(:,:,1),sh3);
ry3 = imfilter(IM(:,:,1),sv3);
rm3 = (rx3.^2 + ry3.^2).^0.5;

rx5 = imfilter(IM(:,:,1),sh5);
ry5 = imfilter(IM(:,:,1),sv5);
rm5 = (rx5.^2 + ry5.^2).^0.5;

rx7 = imfilter(IM(:,:,1),sh7);
ry7 = imfilter(IM(:,:,1),sv7);
rm7 = (rx7.^2 + ry7.^2).^0.5;

rx9 = imfilter(IM(:,:,1),sh9);
ry9 = imfilter(IM(:,:,1),sv9);
rm9 = (rx9.^2 + ry9.^2).^0.5;

x_sum = rx3 + rx5 + rx7 + rx9;
y_sum = ry3 + ry5 + ry7 + ry9;
m_sum = rm3 + rm5 + rm7 + rm9;



end