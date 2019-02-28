function master_nav_contours

my_folder = strcat('/Users/mtlb/me/derek/cal_images/masked/');

if ~isdir(my_folder)

  error_message = sprintf('Error: The following folder does not exist:\n%s', my_folder);
  uiwait(warndlg(error_message));
  return;
end

srgb2lab = makecform('srgb2lab');

file_pattern = fullfile(my_folder, '*.tif'); %file pattern to match
tif_files = dir(file_pattern); %all files that match the file pattern


parfor k = 1:length(tif_files)

  base_filename = tif_files(k).name;
  
  
  full_filename = fullfile(my_folder,base_filename);
  fprintf(1, 'Now reading %s\n', full_filename);
  
  [path name ext] = fileparts(full_filename);

  im = imread(full_filename);
  lab_IM = double(applycform(im,srgb2lab));
  lab_comb = (0.5*lab_IM(:,:,1).^2 + lab_IM(:,:,2).^2 + lab_IM(:,:,3).^2).^0.5;
  
  [nav_x nav_y] = navier_stokes(lab_comb,0.02,0.02,1000,25);
  
  [sink_im flow_im] = grad_flow(nav_x,nav_y,20);
  
  seg_mask = snake_seg(lab_comb,logical(flow_im),500);
  
  
  
  pink_im = pink_bounds(im,bwperim(seg_mask));
  
  save_filename = strcat('/Users/mtlb/me/derek/Photography/segment_sobel/segment_sobel/segmentation/', ...
                         name,'_seg.tif');
                     
  imwrite(pink_im,save_filename);

end
end