function crossed = im_cross(mat1,mat2)

[ht wd] = size(mat1(:,:,1));

crossed = zeros(ht,wd,3);

for i=1:ht
    
    for j=1:wd
         
        crossed(i,j,:) = cross(mat1(i,j,:),mat2(i,j,:));
    end
end
end
        