
% read in relevant polygon data
input_stream = fopen('/athe/d/derek/data/polygon_data'); 

% open file
data_array = textscan(input_stream,'%s');
fclose(input_stream);

% place all data into single string for simpler reg-exp searching
data = strjoin(data_array{1}');

% search using regular expression
polygon_data = regexp(data,'\|.(?<userid>\d+).\|.(?<polygonid>\d+).\|.(?<imageid>\d+).\|.(?<coords>[\d,;]+).\|','names')';
polygon_cell = struct2cell(polygon_data)';

% regular expression to extract the image ID's (as saved in
% ./mappings_files/{1-5}.txt
mapping_expression = '\d/(?<im_id1>\d+)\.png.\d/(?<im_id2>\d+)\.png.\d/(?<im_id3>\d+)\.png.->.\d+\.(?<image>DSC_\d+c\.tif)(?<slice>\.\d+c?\.tif)';
mapping_data = struct([]);


% loop created to read the mapping data from the {1-5}.txt mapping files
for i=1:5
    
    % build filename for each of the 5 mapping files
    filename = strcat('/athe/c/maize/image_processing/data/calibratn_images/huichaos_slices/mappings_files/',num2str(i),'.txt');
    input_stream = fopen(filename); % open and read file
    temp = textscan(input_stream,'%s');
    fclose(input_stream);
    mapping_string = strjoin(temp{1}'); % convert file into single string for searching
    
    % using the regular expression 'mapping_expression', search the
    % mapping_string for the image ID's and the image number they are tied
    % to. converts to a struct array, which will later convert to cell
    mapping_data = horzcat(mapping_data,regexp(mapping_string,mapping_expression,'names')); 
    
end
    
% converts to cell for simple indexing
mapping_cell = struct2cell(mapping_data')';


% this loop is a little more complicated. there are 6 users represented in
% the polygon data, numbers 0-5. the polygon data is present in
% polygon_cell, and has the user number in column 1 ('userid'), the polygon
% number in column 2 ('polygonid'), the image id number in column 3
% ('imageid'), and the actual polygon data in column 4 ('coords'). the
% first goal is to extract all data for a single user, which is
% accomplished by a strcmp (string-compare) between the polygon data and
% the user number. 'current_data' are those rows which match the user
% number, and the 'im_nums' are the image id numbers of those images
% segmented by the user. 
for i=1:6
    
    % find the row and column 
    [row,col] = find(strcmp(polygon_cell,num2str(i-1)));
    current_data = polygon_cell(row(col==1),:);
    im_ids = unique([current_data(:,3)]);
        
    
    % for each unique image id number in in_nums, the actual image it
    % references must be found and read. the table of image id numbers and
    % image numbers in './polygon_data' have a standard formatting,
    % allowing for a regular expression search to extract the data.
    % indexing through the 'im_ids' array, each image number that the id
    % references is extracted (if there is no such image then no further
    % action is taken). once the image number is found, it can be used to
    % further search the mapping_cell, which ties the image number to the
    % actual image path. the image can then be read in.
    for j=1:length(im_ids)
        
        % expression to find the image number tied to the data id
        im_num_exp = strcat('\W',im_ids(j),'.\|.(?<im_num>\d+)\.png');
        im_num = regexp(data,im_num_exp,'tokens');
        
        % if there is an image number for that image id.
        if ~isempty(im_num{1})
            
            % find the row of the image number in mapping_cell
            [row,col] = find(strcmp(mapping_cell,im_num{1}{1})); 
            
            % the files have an unknown number preceding them, so the
            % correct path cannot yet be defined. the 'dir' command allows
            % for the path that matches the image path to be found.
            current_filepath = dir(strcat( ...
                '/athe/c/maize/image_processing/data/calibratn_images/huichaos_slices/AllSlices/', ...
                mapping_cell{row,4},'/*.',mapping_cell{row,4},mapping_cell{row,5}));
            
            % read in the image
            fprintf(1, 'Now reading %s\n',current_filepath.name);
            current_im = imread(strcat( ...
                '/athe/c/maize/image_processing/data/calibratn_images/huichaos_slices/AllSlices/', ...
                mapping_cell{row,4},'/',current_filepath.name));
            
            
            [ht,wd,dp] = size(current_im);
            
            % create a binary image for future processing
            mask_im = zeros(ht,wd); 
            
            % find the data of the current image id
            [row,col] = find(strcmp(current_data,im_ids(j)));
            current_im_data = current_data(row(col==3),4);
            
            red = current_im(:,:,1);
            green = current_im(:,:,2);
            blue = current_im(:,:,3);
            
            % loop through all of the polygon data and draw onto the mask
            % and RGB images
            for k=1:length(current_im_data)
                
                [x,y] = strread(current_im_data{k},'%d %d','delimiter',',|;');
                
%                [fill_x,fill_y] = fill_gaps(x+1,y+1,ht,wd);
                
                idx = sub2ind([ht+10,wd+10],y+6,x+6);
                
                temp_mask = zeros(ht+10,wd+10);
                temp_mask(idx) = 1;
                fill_im = bwmorph(imclearborder(logical(watershed(-bwdist(temp_mask)))),'bridge');
                fill_im = fill_im(6:ht+5,6:wd+5);
                
%                imshow(fill_im(min(y)-5:max(y)+5,min(x)-5:max(x)+5));
%                pause(1);
                
                mask_im(fill_im>0) = 1;
%                mask_im = bwmorph(mask_im,'close');
            
                red(bwperim(fill_im)) = 255;
                green(bwperim(fill_im)) = 20;
                blue(bwperim(fill_im)) = 147;
             
            end
        
            % write out images
            write_filepath = strcat('/athe/d/derek/experiment_results/images/leaves/hand_seg/user_',num2str(i-1));
            imwrite(cat(3,red,green,blue),strcat(write_filepath,'/pink/',im_num{1}{1}{1},'_',current_filepath.name));
            imwrite(mask_im,strcat(write_filepath,'/mask/',im_num{1}{1}{1},'_',current_filepath.name,'.png'));
        
        end
    end
end