function haar_im = haar_transform(im,depth)

[ht wd dp] = size(im);

im=double(im);

vert_pad = ceil(ht/2^depth)*2^depth;
horz_pad = ceil(wd/2^depth)*2^depth;

padded_im = zeros(vert_pad,horz_pad);
padded_im(1:ht,1:wd) = im; 

hLL = 0.25*[1 1;1 1];
gLH = 0.5*[-1 -1;1 1];
gHL = 0.5*[1 -1;1 -1];
gHH = 0.5*[1 -1;-1 1];

haar_im = cell(depth,4);

prev_LL = padded_im;

for i=1:depth
    
    im_LL = conv2(prev_LL,hLL,'same');
    im_LH = conv2(prev_LL,gLH,'same');
    im_HL = conv2(prev_LL,gHL,'same');
    im_HH = conv2(prev_LL,gHH,'same');
    
    
    haar_im{i,1} = im_LL(1:2:end,1:2:end);
    haar_im{i,2} = im_LH(1:2:end,1:2:end);
    haar_im{i,3} = im_HL(1:2:end,1:2:end);
    haar_im{i,4} = im_HH(1:2:end,1:2:end);
    
    prev_LL = im_LL(1:2:end,1:2:end);
    
end
    
    
    
    
    
    
    
    
end