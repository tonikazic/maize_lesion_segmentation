im=imread('DSC_0051_0025104.png');



[ht wd] = size(im(:,:,1));

S = zeros(ht,wd);
S(2000:2300,1600:2300) = 1;


%im=im(:,:,1);
%[g NR SI TI] = regiongrow(im,S);