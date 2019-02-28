function im_final = im_conv(I)
% creates a convolution of the image I


[ht wd] = size(I(:,:,1));

leaf_mask = logical(I(:,:,1));

STATS_red   = regionprops(leaf_mask,I(:,:,1),'PixelValues');
STATS_green = regionprops(leaf_mask,I(:,:,2),'PixelValues');
STATS_blue  = regionprops(leaf_mask,I(:,:,3),'PixelValues');

mean_red   = uint8(mean(STATS_red(1).PixelValues));
mean_green = uint8(mean(STATS_green(1).PixelValues));
mean_blue  = uint8(mean(STATS_blue(1).PixelValues));

I_temp = I;

for i=1:ht
    
    for j=1:wd
        
        if I(i,j,1)==0 && I(i,j,2)==0 && I(i,j,3)==0
            
            I_temp(i,j,1) = mean_red;
            I_temp(i,j,2) = mean_green;
            I_temp(i,j,3) = mean_blue;
        end
    end
end

im=double(I_temp);
im_mean(:,:,1) = conv2(im(:,:,1),ones(50,50)/2500,'same');
im_mean(:,:,2) = conv2(im(:,:,2),ones(50,50)/2500,'same');
im_mean(:,:,3) = conv2(im(:,:,3),ones(50,50)/2500,'same');
im_final = double(I) - im_mean;
im_final = uint8(im_final);
%figure, imshow(im_final);
end