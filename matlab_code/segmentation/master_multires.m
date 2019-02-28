function master_multires(out_folder)

my_folder = strcat('/athe/d/derek/scratch/S_les2_les4_12n/');

if ~isdir(my_folder)

  error_message = sprintf('Error: The following folder does not exist:\n%s', my_folder);
  uiwait(warndlg(error_message));
  return;
end


file_pattern = fullfile(my_folder, '*.tif'); %file pattern to match
tif_files = dir(file_pattern); %all files that match the file pattern


for k = 1:length(tif_files)

  base_filename = tif_files(k).name;
  
  filepath = strcat(my_folder,base_filename);
  fprintf(1, 'Now reading %s\n', filepath);
  
  [path name ext] = fileparts(filepath);
  
  im = imread(filepath);
  
  image(:,:,1) = expand_im(im(:,:,1),4);
  image(:,:,2) = expand_im(im(:,:,2),4);
  image(:,:,3) = expand_im(im(:,:,3),4);
  
  [~,~,~,~,div_im] = multires_sink(im(:,:,1),4);
  
  [ht wd] = size(div_im(:,:,1));
  
  [min_im,idx] = min(div_im,[],3);
  
  seg_im = snake_seg(image(:,:,1),min_im<-50,25);
  
  pink_im = pink_bounds(uint8(image),bwperim(seg_im));
  imwrite(pink_im,strcat(out_folder,name,'.tif'));
  
  clear image;
  
end
end