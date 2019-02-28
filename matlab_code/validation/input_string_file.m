function cell_array = input_string_file(file,format)

input_stream = fopen(file);
cell_array = textscan(input_stream,format);
fclose(input_stream);

end