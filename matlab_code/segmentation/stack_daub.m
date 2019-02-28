function stack_im = stack_daub(im,daub_im)


[dp br] = size(daub_im);

im=expand_im(double(im),dp);

[ht wd] = size(im);

stack_im = zeros(ht,wd,dp+1);
stack_im(:,:,1) = im;

for i=1:dp
    
    stack_im(:,:,i+1) = kron(daub_im{i,1},ones(2^(i)));
end




end