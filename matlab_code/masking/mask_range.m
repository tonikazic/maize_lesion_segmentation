function [mask_red mask_green mask_blue] = mask_range(im)

range_red = rangefilt(im(:,:,1));
range_green = rangefilt(im(:,:,2));
range_blue = rangefilt(im(:,:,3));

hist_red = imhist(range_red);
hist_green = imhist(range_green);
hist_blue = imhist(range_blue);

[C mode_red] = max(hist_red+4);
[C mode_green] = max(hist_green+4);
[C mode_blue] = max(hist_blue+4);

[ht wd] = size(range_red);

mask_red = zeros(ht,wd);
mask_green = zeros(ht,wd);
mask_blue = zeros(ht,wd);

for i=1:ht
    
    for j=1:wd
        
        if range_red(i,j) < mode_red
            
            mask_red(i,j) = 1;
        end
            
        if range_green(i,j) < mode_green
            
            mask_green(i,j) = 1;
        end
            
        if range_blue(i,j) < mode_blue
            
            mask_blue(i,j) = 1;  
        end
    end
end

figure,plot(hist_red);
figure,plot(hist_green);
figure,plot(hist_blue);

end