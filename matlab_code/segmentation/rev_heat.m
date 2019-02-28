function init_im = rev_heat(image,dt,time)
% this is an attempt to create a reverse heat equation to find areas of
% interest in grayscale images. it does not work very well.

[ht wd] = size(image);


lap_filt = fspecial('laplacian');

prev_im = image;


for i=1:dt:(time)
    
    u_xx = image(:,[2:wd wd]) - 2*image + image(:,[1 1:wd-1]);
    u_yy = image([2:ht ht],:) - 2*image + image([1 1:ht-1],:);
    
    lap_im = dt*(u_xx + u_yy);
    
    prev_im = prev_im - lap_im;
    
    %plot(prev_im(:,2322))
    imshow(mat2gray(prev_im));
    %quiver(flipud(U(882:962,3573:3675)),flipud(-V(882:962,3573:3675)));
    pause(0.01);
    
end


init_im = prev_im;

end


