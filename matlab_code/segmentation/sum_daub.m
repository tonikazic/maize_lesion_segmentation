[dp wd] = size(daub_im);

[ht wd] = size(daub_im{1,1});

del_ims = cell(3,1);

for i=1:4
    
    sum_im = zeros(ht*2,wd*2);
    
    for j=1:4
    
       sum_im = sum_im + 1/2^j*kron(daub_im{j,i},ones(2^j));
    
    
    
    end
    
    del_ims{i} = sum_im;
    
end
