my_folder = '/Users/mtlb/me/derek/Photography/images';
out_folder = '/Users/mtlb/me/derek/Photography/Output';

if ~isdir(my_folder)
    
  error_message = sprintf('Error: The following folder does not exist:\n%s', my_folder);
  uiwait(warndlg(error_message));
  return;
end


file_pattern = fullfile(my_folder, '*.png');
png_files = dir(file_pattern);


for k = 1:length(png_files)
    
  base_filename = png_files(k).name;
  full_filename = fullfile(my_folder, base_filename);
  fprintf(1, 'Now reading %s\n', full_filename);
  image = uint8(imread(full_filename));
  leaf = mask_kmeans(image);
  file_num = base_filename(1:(strfind(base_filename,'.')-1));
  title = strcat(out_folder,'/',file_num,'.tif');
  imwrite(leaf,title,'tif');
%  imwrite(tag,title,'WriteMode','append');
%  imwrite(colorbar,title,'WriteMode','append');
end