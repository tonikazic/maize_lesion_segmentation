function final_im = rev_wave(grad_x,grad_y,dt,its)
% this is an attempt to reverse the wave equation to find areas of intest
% in gradient images. it does not work very well.


[ht wd] = size(grad_x);


lap_filt = fspecial('laplacian');

local_maxx = imfilter(grad_x,lap_filt,'circular');
local_maxy = imfilter(grad_y,lap_filt,'circular');

local_max = (local_maxx.^2 + local_maxy.^2).^0.5;

filt = reshape(double(local_max<5),ht,wd);

grad_x = filt.*grad_x;
grad_y = filt.*grad_y;


prev_x = grad_x;
prev_y = grad_y;
current_x = grad_x;
current_y = grad_y;


for i=1:its
    
    lap_x = 2*dt*imfilter(current_x,lap_filt,'circular');
    lap_y = 2*dt*imfilter(current_y,lap_filt,'circular');
    
    next_x = 2*current_x + lap_x - prev_x;
    next_y = 2*current_y + lap_y - prev_y;
    prev_x = current_x;
    prev_y = current_y;
    current_x = next_x;
    current_y = next_y;
    
    current_im = (current_x.^2 + current_y.^2).^0.5;
    %plot(current_im(:,2322))
    imshow(mat2gray(current_im));
    %quiver(flipud(current_x(882:962,3573:3675)),flipud(current_y(882:962,3573:3675)));
    pause(0.01);
    
end


final_im = (current_x.^2 + current_y.^2).^0.5;

end


