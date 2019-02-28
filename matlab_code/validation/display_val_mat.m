function display_val_mat(master_validation_cell)



for i=1:length(master_validation_cell)
    
    tit = master_validation_cell{i,1};
    
    [pathstr,name,ext] = fileparts(tit);
    
    validation_cell = master_validation_cell{i,2};
    
    mat = zeros(length(validation_cell));
    
    for j=1:length(validation_cell)
        
       valid_vals = validation_cell{j,2};
       
       for k = 1:length(validation_cell)
           
           mat(j,k) = valid_vals(validation_cell{k,1});
           
       end
    end

    imwrite(uint8(kron(mat*63,ones(50))),spring,strcat('/athe/d/derek/scratch/val_im_test/',name,'.png'));
    max(max(double(kron(mat,ones(50)))))
    
end
       
       
        
        
    
    
    
    
end