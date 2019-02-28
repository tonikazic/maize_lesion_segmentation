im = imread('DSC_0051_0025104.png');
blue_area_red = imhist(im(548:1040,476:1637,1));
blue_area_green = imhist(im(548:1040,476:1637,2));
blue_area_blue = imhist(im(548:1040,476:1637,3));

[ht wd] = size(im(:,:,1));

for i=1:ht
    for j=1:wd
        
        if (im(i,j,3) > im(i,j,1)) && (im(i,j,3) > im(i,j,2))
            
            im(i,j,:) = 0;
            
        end
    end
end

j=1;

%for i=1:ht
%    
%    if sum(im(i,:,3)) > 0
%        
%        temp_mask(j,:,:) = im(i,:,:);
%        j=j+1;
%        
%    end
%end

imshow(im);