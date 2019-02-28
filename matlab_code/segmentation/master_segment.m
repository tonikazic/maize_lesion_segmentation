function master_segment(path_str)

my_folder = strcat('/Users/mtlb/me/derek/scratch/S_les2_les4_12n/',path_str);

if ~isdir(my_folder)

  error_message = sprintf('Error: The following folder does not exist:\n%s', my_folder);
  uiwait(warndlg(error_message));
  return;
end


file_pattern = fullfile(my_folder, '*.tif'); %file pattern to match
tif_files = dir(file_pattern); %all files that match the file pattern


for k = 1:length(tif_files)

  base_filename = tif_files(k).name;
  
  str = base_filename(6:8); % when greping, only need the last 3 digits
  mutn = path_str(5:8);
  
  %  greps for the line containing the image number of interest
  search_folder = strcat('/Users/mtlb/me/derek/images/',path_str(1:3),'/',mutn,'_raw/',mutn,'_images.txt');

  [fl p] = grep('-s',str,search_folder);
  lines = p.match;
  
  exp = strcat('12N\d+:00\d+:..12n/bet/.*',str,'.*');
  rowplant_whole = regexp(lines{1},exp,'match');
  rowplant_temp = rowplant_whole{1};
  rowplant = rowplant_temp(11:15);
  
  full_filename = fullfile(my_folder,base_filename);
  fprintf(1, 'Now reading %s\n', full_filename);
  
  im=imread(full_filename);
  
  [path,im_num,ext] = fileparts(full_filename);
  
  im_final = im_conv(im); % deconvolves image
  
  BW = im2bw(im_final,0.1); % converts image to black and white by given threshold
  
  [B,L,N] = bwboundaries(BW,8,'holes'); 
  
  les_data = Geometrical_Output_BL(BW,im); % calculates lesion data
  
%  boundaries = PinkBoundary(B,im); % generates pink boundary image for viewing
%  figure,imshow(boundaries);

  cl_data = clean_data(les_data); % removes gross outliers

  save_filename = strcat('/Users/mtlb/me/derek/im_data/',path_str,'/', ...
                  path_str(1:3),'_',rowplant,'_',im_num(5:8),'.mat');

  save(save_filename,'cl_data');


end
end