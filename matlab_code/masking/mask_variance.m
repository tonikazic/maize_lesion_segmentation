function [leaf_perim bar_perim color_perim mask image] = mask_variance(image)

im = image;

[ht wd] = size(im(:,:,1));

%  Determine the orientation of the image by calculating the average red
%  values across rows for the first 750 columns. Higher red values should 
%  tend toward lower rows values (counting from the top). If this isn't the 
%  case, the image must be flipped
im_red = im(:,1:750,1);

for i=1:ht
    
    mass(i) = sum(im_red(i,:));
    mass_bias(i) = mass(i)*i;
end

vert_test = sum(mass_bias)/sum(mass);

if vert_test > ht/2
    
    im = imrotate(im,180);
end

mask = ones(ht,wd);

%  Used to create separate samples of red, green, and blue
sample_red = im((ht-100):ht,:,1);
sample_green = im((ht-100):ht,:,2);
sample_blue = im((ht-100):ht,:,3);

%  Used to determine the means of the sample matrices above
mean_red = mean2(sample_red);
mean_green = mean2(sample_green);
mean_blue = mean2(sample_blue);

%  Used to determine the variance of the sample matrices above
var_red = var(var(double(sample_red)));
var_green = var(var(double(sample_green)));
var_blue = var(var(double(sample_blue)));

%  Tests every pixel of the image against variance of the sample of the
%  blue background. If it is within the range, it sets the value of mask to
%  0 (black)
for i=1:ht
    
    for j=1:wd
        
        if (abs(im(i,j,1) - mean_red) < var_red && ...
           abs(im(i,j,2) - mean_green) < var_green && ...
           abs(im(i,j,3) - mean_blue) < var_blue)
           
            
            mask(i,j) = 0;
        end   
    end
end


mask = uint8(imfill(mask));

%  Finds the first row that is all white (=1). This will be a row
%  completely withing the bounds of the leaf. From there, the counter will
%  track back until it finds the first black (=0) pixel. This will be the
%  top left corner of the leaf.
for i=2:ht
    
    if all(mask(i,:) == 1)
        
        for j=1:i
            
            if mask(i-j,1) == 0
                
                leaf_edge_y = i-j+1;
                break
            end
        end
    end
end

leaf_perim = bwtraceboundary(mask,[leaf_edge_y,1],'NW');

bar_perim = 1;

color_perim = 1;

image(:,:,1) = im(:,:,1).*mask;
image(:,:,2) = im(:,:,2).*mask;
image(:,:,3) = im(:,:,3).*mask;

end
