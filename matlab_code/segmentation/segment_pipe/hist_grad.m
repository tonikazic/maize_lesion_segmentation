function [grad_x,grad_y] = hist_grad(im)
% This function calculates the gradient based on the distance from
% transversing the histogram of the image. That is, while a normal gradient
% function calulates the difference between image values a and b, this
% function calculates how far along the histogram you must travel in order
% to get from a to b. This therefore increases the distance when a value
% travels across important features in an image as determined by histogram.
%
% Variations could include using the L*a*b* colorspace or including all 3
% RGB histograms. For testing and development, this only includes the R 
% channel histogram.
%


im = uint8(im);



[ht,wd,dp] = size(im);




hist = imhist(im);
hist(1) = 0;
%hist = hist./max(hist);



dist_hist = 1./abs(hist(2:end) - hist(1:end-1));
dist_hist(end+1) = dist_hist(end);
dist_hist = dist_hist./max(dist_hist);


exp_im = im+1;
exp_im(ht+1,:) = exp_im(ht,:);
exp_im(:,wd+1) = exp_im(:,wd);


grad_x = zeros(ht,wd);
grad_y = zeros(ht,wd);



for i=1:ht

    dy = sort(exp_im(i:i+1,:),1);
    
    for j=1:wd
        
       grad_y(i,j) = sum(dist_hist(dy(1,j):dy(2,j)));
       
    end
    
    sign = (exp_im(i+1,:) - exp_im(i,:))./abs(exp_im(i+1,:)-exp_im(i,:));
    sign(sign==0) = 1;
    
    grad_y(i,:) = grad_y(i,:) .* double(sign(1,1:wd));
        
        
end


for k=1:wd

    dy = sort(exp_im(:,k:k+1),2);
    
    for l=1:ht
        
       grad_x(l,k) = sum(dist_hist(dy(l,1):dy(l,2)));
       
    end
    
    sign = (exp_im(:,k+1) - exp_im(:,k))./abs(exp_im(:,k+1)-exp_im(:,k));
    sign(sign==0) = 1;
    
    grad_x(:,k) = grad_x(:,k) .* double(sign(1:ht,1));
        
        
end
    
    
    
end