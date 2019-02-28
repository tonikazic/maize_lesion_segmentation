%function master_multires(in_folder,out_folder)

in_folder = '/athe/d/derek/scratch/wade_test/';
out_folder = '/athe/d/derek/experiment_results/images/leaves/wade_test/';

if ~isdir(in_folder)

  error_message = sprintf('Error: The following folder does not exist:\n%s', in_folder);
  uiwait(warndlg(error_message));
  return;
end


file_pattern = fullfile(in_folder, '*.tif'); % file pattern to match
tif_files = dir(file_pattern); % all files that match the file pattern


for k = 1:length(tif_files)

  base_filename = tif_files(k).name;
  
  filepath = strcat(in_folder,base_filename);
  fprintf(1, 'Now reading %s\n', filepath);
  
  [path,name,ext] = fileparts(filepath);
  
  leaf = imread(filepath);
  
  %[leaf,tag_color] = mask_rough(im);
  
  [ht,wd,dp] = size(leaf);
  
  [~,~,~,~,div_im,y_coord,x_coord] = multires_sink(leaf(:,:,1),4);
  
  [min_im,idx] = min(div_im,[],3);
  min_im = min_im((y_coord+1):(y_coord+ht),(x_coord+1):(x_coord+wd));
  
  seg_im = snake_seg(leaf(:,:,1),min_im<-50,25);
  
  pink_im = pink_bounds(leaf,bwperim(seg_im));
  imwrite(pink_im,strcat(out_folder,name,'.tif'));
  
  clear image;
  
end
%end