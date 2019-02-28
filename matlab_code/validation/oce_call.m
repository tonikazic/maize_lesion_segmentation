function validation_cell = oce_call(data_file,data_format,flag)


files_array = input_string_file(data_file,data_format);
files_array = files_array{1};



validation_cell = cell(length(files_array),2);



for i=1:length(files_array)
    
    
    validation_map = containers.Map;
    
    
    validation_cell{i,1} = files_array{i};
    
    
    for j=1:length(files_array)
        
        
        validation_map(files_array{j}) = min(oce_calculator(imread(files_array{i}),imread(files_array{j}),flag), ...
                                             oce_calculator(imread(files_array{j}),imread(files_array{i}),flag));
        

%        validation_map(files_array{j}) = oce_calculator(imread(files_array{i}),imread(files_array{j}),'jaccard');
    end
    
    validation_cell{i,2} = validation_map;
end

end