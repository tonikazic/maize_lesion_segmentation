function [fx fy fm fxy fyx fmm] = double_sobel(im,num1,num2)




IM = double(im);


[sh1 sv1] = get_sobel_filter(num1);
[sh2 sv2] = get_sobel_filter(num2);

%sh1 = -sh1;
sh2 = -sh2;

%sv1 = -sv1;
sv2 = -sv2;



fx = imfilter(IM,sh1);
fy = imfilter(IM,sv1);
fm = (fx.^2 + fy.^2).^0.5;


fxy = imfilter(fx,sv2);
fyx = imfilter(fy,sh2);
fmm = (fxy.^2 + fyx.^2).^0.5;


end