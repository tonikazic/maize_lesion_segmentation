function master_validation_cell = master_oce_call(data_file,data_format,flag)


files_array = input_string_file(data_file,data_format);
files_array = files_array{1};



master_validation_cell = cell(length(files_array),2);



for i=1:length(files_array)
    
    master_validation_cell{i,1} = files_array{i};
    
    master_validation_cell{i,2} = oce_call(files_array{i},data_format,flag);
end

end