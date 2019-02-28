function fill_mask = fill_in_polygons(file_paths)


input_stream = fopen(file);
files_array = textscan(input_stream,format);
fclose(input_stream);
files_array = input_string_file(data_file);
files_array = files_array{1};

for i=1:length(files_array)
    
    
    im = imread(files_array(i));
    


end