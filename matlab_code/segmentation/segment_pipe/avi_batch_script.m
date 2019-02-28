% this is
% /athe/d/derek/code/image_processing/segmentation/segment_pipe/avi_batch_script.m
%
%
% this code is for batch processng of all images for segmentation to data extraction
% and will store images and quatitative data at output directory. Here
% output directory is out_dir = '/athe/c/maize/analysis_images' with
% subdirectory /mask , /pink and /segment for there respective ouputs.  
%
%

% root_dir = '/athe/c/maize/analysis_images/'
% out_dir = 'segext'
% tiff_root = '/athe/c/maize/analysis_images/tiffs/'

input_dir = '/athe/c/maize/analysis_images/tiffs';
% out_dir = 'segext'
out_dir = '/athe/c/maize/analysis_images';

% Variables for file names could  be adjusted with introducing extra
% variable like 
%
% extra_info = strcat('xxxxx','_','yyyyy');


% first check that whether the input directory exist or not
% if don't exist the it will pop up error message
% if exist then it will proceed for further process the files in input
% directory
%
%
if ~isdir(input_dir)
  error_message = sprintf('Error: The following folder does not exist:\n%s', input_dir);
  uiwait(warndlg(error_message));
  return;
end

% It will match the *.tiff file pattern in input directory and extrct current tiff file directory 
% from it, that match the file pattern. Thereafter, we will use this
% directory as array to process further single tiff file at time.
%
% dir lists files and folders in the current folder.
%
%
file_pattern = fullfile(input_dir, '*.tiff');
tiff_files = dir(file_pattern);

for k = 1:length(tiff_files)
  base_filename = tiff_files(k).name;
  full_filename = fullfile(input_dir, base_filename);
  fprintf(1, 'Now reading %s\n', full_filename);
  
  % it will divide the full_file_name into three parts: path, name and
  % extension such that we can customize the output file name according to image. 
  %
   [path,name,extension] = fileparts(full_filename);
   new_dir = mkdir('/athe/c/maize/analysis_images',name);
  
  % call required functions here onward to process further
  %
 %  segment_call('path to data_file','path to parms file',number of parms,'output folder');
 
  
  
  
  
  % now save lesion images and csv files in respective directory
  % 
  % It will changed as we wrote in our previous script
  %
    file_name1 = strcat(info,name,'_',out_dir11222,'_','lesion_name_customized.png'); 
    outputFullFileName1 = fullfile(out_dir,name,file_name1);
    imwrite(image_data_variavble_name_of_above_png,outputFullFileName1); 
    
    clc;
    close all;
    
 % Save all mat files for lesion_data 
 %   
 %
file_name2 = strcat(info,name,'_',out_dir222,'_','lesion_Data_xyz.mat');
outputFullFileName2 = fullfile(out_dir,name,file_name2);
    save(outputFullFileName2,'lesion_data');
    
 
 % clear all memory to save memory for future process
 %
 %
 clear  im1 outputFullFileName1 outputFullFileName1a ...
     file_name32 file_name32a;
end


% to combined all quantitative_data.mat files to single *.mat file
% and save it as *.csv file
% since all *.mat and *.csv files are in leaf number folder in lesons folder
% so this script will look up in each folder and combine them in single
% *.mat file.
%
% vatsa 10.11.2016
%

%  path = '/athe/c/maize/analysis_images/segext/segext_1476207286/lesions/0262';   
% d=dir(strcat(path,'quantitativeLesionData.mat'));  % get the list of files
% x=[];            % start w/ an empty array
% for i=1:length(d)
% x = [x; load(d(i).name)];   % read/concatenate into x
% end
% save('newfile.mat',x)


% full script code is as follows.
%
% https://www.mathworks.com/matlabcentral/answers/125602-concatenating-several-mat-file-into-one
%
clear
input_dir = '/athe/c/maize/analysis_images/segext/segext_1476207286/lesions';

if ~isdir(input_dir)
  error_message = sprintf('Error: The following folder does not exist:\n%s', input_dir);
  uiwait(warndlg(error_message));
  return;
end

%  cd /athe/c/maize/analysis_images/segext/segext_1476207286/;

myFolderDirs = dir(input_dir);
for m = 3 :size(myFolderdirs,1)
    
    % help
    %
    % Because these points are in a structure, I extract them and place them into a single 1D vector, 
    % then reshape it so that it becomes a M x 4 matrix.
    %
    % like
    % bboxes = reshape([bound.BoundingBox], 4, []).';
    % Bear in mind that this is the only way that I know of that can extract 
    % values in arrays for each structuring element efficiently without any for loops.
    % This will facilitate our searching to be quicker. 
    %
    name = myFolderDirs(m);
    file_all = dir(fullfile(input_dir,name,'*.mat'));
    
    
    
end   
file_all = dir(fullfile(input_dir,'quantitativeLesionData.mat'));

matfile  = file_all([file_all.isdir] == 0); 

clear file_all PathName

%d=dir('*.mat');  % get the list of files
x=[];            % start w/ an empty array
for i=1:length(matfile)
x=[x; load(matfile(i).name)];   % read/concatenate into x

end
b=[];
for j=1:length(x)
    b=[b; x(j, 1).variable1];

end

FileName = [matfile(i,1).name(1:end-9),'.mat'];
save(FileName,'matfile','x','b');





    
    