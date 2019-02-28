% current implementation: the ground truth is composed of those images that
% the person being assessed did NOT identify
%



% the paths to files containing the image paths, i.e. all paths to
% segmentations of image 1, image 3151, etc.
im_paths = '/athe/d/derek/code/image_processing/validation/im_paths';

data_file = fopen('/athe/b/artistry/papers/current/image_processing/data.csv');

% read in the paths
files_array = input_string_file(im_paths,'%s');
files_array = files_array{1};

% for each image, create a cell that the results can be stored in
results_cell = cell(length(files_array),2);

% a matrix for storing results from each person. the precision and recall
% are stored. this is for the purpose of plotting the precision vs. the
% recall.
positives_mat = cell(7,1);

% for each image, calculate facts for each user.
for i=1:length(files_array)
    
    % an empty structure array for storing all facts for each segmentation
    results = struct('filename',[],'user',[],'STATS_seg',[],'STATS_gt',[],'true_positives',[],'false_positives',[],'false_negatives',[],'precision',[],'recall',[],'F1',[],'OCE',[]);

    % parse the path so that the name can be discovered. this will be
    % stored under 'filename' in the results structure array
    [pathstr,name,ext] = fileparts(files_array{i});
    results_cell{i,1} = name;
    
    % for each image that has been segmented, create an array of all
    % relevant segmentation paths, i.e. the segmentations by the algorithm,
    % user 2, user 5, etc.
    im_array = input_string_file(files_array{i},'%s');
    im_array = im_array{1};
    
    % all segmentations are stacked in the same array so they can be
    % used and combined by simple matrix indexing. cell and structure 
    % arrays are cumbersome by comparison
    current_im = zeros(size(imread(im_array{1})));
    current_im = repmat(current_im,[1 1 length(im_array)]);
    
    % a simple matrix for tracking which user each segmentation is by. this
    % will be used in creating the ground truth image, so that all images
    % by the user being analyzed aren't considered
    users_mat = zeros(length(im_array),1);
    
    
    % current_im matrix is filled with all images. the results of the
    % segmentation algorithm are always first
    for j=1:length(im_array)
        
        current_im(:,:,j) = bwlabel(logical(imread(im_array{j})),4);
    end

    
    % the user that segmented the images is placed into the user_mat. the
    % segmentation algorithm is considered to be user 6.
    for j=1:length(im_array)
                
        user_num = regexp(im_array{j},'.*user_(\d).*','tokens');
        
        if isempty(user_num)
            
            results(j).user = 6;
            users_mat(j) = 6;
        else
            
            results(j).user = str2double(user_num{1});
            users_mat(j) = str2double(user_num{1});
        end

        
    end
    
    
    % each image is analyzed in sequence. for the segmentation algorithm,
    % the ground truth is a combination of all human segmented images. for
    % each user, the ground truth is drawn from the segmentations of all
    % other users, not including the segmentation algorithm. this is
    % subject to change
    for j=1:length(im_array)
        
        % the current image being analyzed
        seg_im = bwlabel(logical(current_im(:,:,j)));    
        
        % if the current segmented image is by the algorithm, then the
        % ground truth is all human-segmented pixels. Otherwise, the ground
        % truth is all pixels segmented by other users (not the
        % segmentation algorithm)
%        if j == 1
            
%            gt_im = bwlabel(sum(double(logical(current_im(:,:,2:end))),3)>0);
%        else
            
            gt_im = bwlabel((sum(double(logical(current_im)),3)-sum(double(logical(current_im(:,:,find(users_mat==users_mat(j))))),3))>0);
%        end
        
        % using the calc_concordance_measures, finds the true positives,
        % the false positives, the false negatives, the precision, the
        % recall, and the F1 measure
        [results(j).STATS_seg,results(j).STATS_gt,results(j).true_positives, ...
         results(j).false_positives,results(j).false_negatives,results(j).precision, ...
         results(j).recall,results(j).F1] = calc_concordance_measures(seg_im,gt_im);
     
        % finds the filename
        results(j).filename = im_array{j};
        
        % finds the OCE value
        results(j).OCE = min(oce_calculator(seg_im,gt_im,'jaccard'),oce_calculator(gt_im,seg_im,'jaccard'));
        
        % fill the positives_mat with the precision and recall. this is not
        % a good name
        positives_mat{results(j).user+1} = [positives_mat{results(j).user+1};str2double(strrep(name,'_','.')),results(j).user,results(j).true_positives,results(j).false_positives,results(j).false_negatives,results(j).precision,results(j).recall,results(j).OCE];
        
    end
    
    results_cell{i,2} = results;
end


