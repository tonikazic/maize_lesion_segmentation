function val_heat(data_file,data_format)


files_array = input_string_file(data_file,data_format);
files_array = files_array{1};


[pathstr,name,ext] = fileparts(data_file);


heat_map = zeros(size(imread(files_array{1})));


for i=2:length(files_array)
    
    im = double(logical(imread(files_array{i})));
    
    heat_map = heat_map + im;
    
end


imwrite(uint8(mat2gray(heat_map)*63),jet,strcat('/athe/d/derek/scratch/validation_heatmap/',name,'_heat.png'));

imwrite(mat2gray(heat_map),strcat('/athe/d/derek/scratch/validation_heatmap/',name,'_gray.png'));
imwrite(heat_map>1,strcat('/athe/d/derek/scratch/validation_heatmap/',name,'_consensus.png'));
close all;


end