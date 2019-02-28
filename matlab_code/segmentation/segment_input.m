my_folder = '/Users/mtlb/me/derek/images/acceptable/les4/W/hetero'; %folder with images
%out_folder = '/athe/c/maize/image_analysis/masking/les4_pink/conv_sub/0_05/masks'; %folder to write to

if ~isdir(my_folder)

  error_message = sprintf('Error: The following folder does not exist:\n%s', my_folder);
  uiwait(warndlg(error_message));
  return;
end


file_pattern = fullfile(my_folder, '*.tif'); %file pattern to match
tif_files = dir(file_pattern); %all files that match the file pattern

%les2_data = []; %matrix of lesion data from all images to be filled
les_data = [];
group = []; %groups the lesion data by image
for k = 1:length(tif_files)

  base_filename = tif_files(k).name;
  full_filename = fullfile(my_folder, base_filename);
  fprintf(1, 'Now reading %s\n', full_filename);
  image = uint8(imread(full_filename));
  data_temp = master_segment(image);
  mean_temp = mean(data_temp);
  %les4_mean = vertcat(les4_mean,mean_temp);
%  file_num = base_filename(1:(strfind(base_filename,'.')-1));
%  title = strcat(out_folder,'/',file_num,'.jpg');
%  imwrite(mask,title,'jpg');
  les_data = vertcat(les_data,data_temp); %combines data from leaf with master set
  group_temp = repmat(k,size(data_temp,1),1); 
  group = vertcat(group,group_temp); %adds group array of index to master array
%  imwrite(tag,title,'WriteMode','append');
%  imwrite(colorbar,title,'WriteMode','append');
  
end

[good_data good_group] = clean_data(les_data,group);
clear a b as bs image my_folder tif_files base_filename data_temp file_pattern...
      full_filename k od_data max_data min_data;

%PlotAllDimParallel(les2_data,group,a_master,b_master);