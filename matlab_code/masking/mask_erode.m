function mask = mask_erode(im)

[ht wd] = size(im(:,:,1));

imsub = im(:,:,1)-im(:,:,3);

j=1;

solids = zeros(100,1);

for i=0.01:0.01:1
    
    BW = im2bw(imsub,i);
    STATS_temp = regionprops(BW,'Solidity');
    solids(j) = max(STATS_temp.Solidity);
    j=j+1;
end

[C I] = max(solids);

mask = im2bw(imsub,I*0.01);
end