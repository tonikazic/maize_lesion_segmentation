im = imread('DSC_0051_0025104.png');


[ht wd] = size(im(:,:,1));
running_mean = 0;
running_var = 0;
%differential = zeros(ht,wd);
x = 1;
for i=1:wd
    running_mean = 0;
    for j=1:ht
        
        running_mean_temp = (sum(im(1:j,i,1))/(j));
        running_var = ((im(j,i,1))-round(running_mean))^2;
        running_mean = running_mean_temp;
    end
end