function segment_call(data_file,parameters_file,n,out_dir)
% segment_call controls the segmentation procedure, and takes as its
% inputs:
% 
%   data_file: a plain text file consisting of image paths on separate lines
%
%   parameters_file: a plain text file consisting of parameter names on one
%   line and parameter values on a separate line, each separated by commas.
%
%   n: the number of parameters in parameters_file, needed for proper
%   reading
%
%   out_dir: the output directory, which must have subdirectories 'mask'
%   and 'pink'.
%
%
%%%% so you can pass in "/athe/d/linh/image_processing/results/output_apply_maskSUFFIX" from the command line
%
% function call:
% 
%   segment_call('path to data_file','path to parms file',number of parms,'output folder');
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%     necessary parameters are:
%%%     
%%%     wav_depth (wavelet depth): the number of iterations for the wavelet 
%%%     decomposition. default is 4.
%%% 
%%%     nav_mu (navier_stokes mu): a weight parameter controlling the 
%%%     'viscosity' of the elastic model. default is 0.015 and changing is 
%%%     not recommended.
%%%
%%%     nav_lambda (navier_stokes lambda): a second weight parameter
%%%     controlling the elastic model; again the default is 0.015 and
%%%     changing is not recommended.
%%%
%%%     nav_thresh (navier_stokes threshold): sets a threshold for the
%%%     vectors to fix in the elastic model. default is not to fix any of
%%%     the vectors, so the default is 1000, much higher than any possible
%%%     value.
%%%
%%%     nav_its (navier_stokes iterations): number of times to repeat the
%%%     elastic deformation procedure. default is 45.
%%%
%%%     div_thresh (divergence threshold): only consider sinks below a
%%%     certain divergence threshold, otherwise the image is likely to be
%%%     oversegmented. default is -45.
%%%
%%%     cont_its (contour iterations): number of times to repeat the active
%%%     contour relaxation. this value is multiplied by the base 10
%%%     logarithm of the lesion area, allowing for more iterations on
%%%     lesions that have a larger area. default value is 25.
%%%
%%%     cont_alpha (contour alpha): a parameter controlling the rigidity of
%%%     the active contour boundary. a higher value means less curvature
%%%     allowed and a lower value means more curvature allowed. default is
%%%     0.8.
%%%
%%%     l_size (lower size): the minimum number of pixels that a lesion is
%%%     allowed to have. default is 5 pixels.
%%%
%%%     u_size (upper size): the maximum number of pixels that a lesion is
%%%     allowed to have. default is 50,000 pixels.


    % read in the files to segment and the relevant parameters
    files_array = input_string_file(data_file,'%s');
    files_array = files_array{1};
    parms = input_hash_file(parameters_file,'%f',n);
    
    
    % check if fields have been declared in the parameters file, otherwise
    % set to default values
    if ~isfield(parms,'wav_dpth')
        parms.wav_dpth = 4;
    end
    
    if ~isfield(parms,'nav_mu')
        parms.nav_mu = 0.015;
    end
    
    if ~isfield(parms,'nav_lambda')
        parms.nav_lambda = 0.015;
    end
    
    if ~isfield(parms,'nav_thresh')
        parms.nav_thresh = 1000;
    end
    
    if ~isfield(parms,'nav_its')
        parms.nav_its = 45;
    end
    
    if ~isfield(parms,'div_thresh')
        parms.div_thresh = -45;
    end
    
    if ~isfield(parms,'cont_its')
        parms.cont_its = 25;
    end
    
    if ~isfield(parms,'cont_alpha')
        parms.cont_alpha = 0.8;
    end
    
    if ~isfield(parms,'l_size')
        parms.l_size = 5;
    end
    
    if ~isfield(parms,'u_size')
        parms.u_size = 50000;
    end

    
    for i=1:length(files_array)
       
        % for each file in the files_array, display that the file is being
        % analyzed and split the path into useful parts.
        filepath = files_array{i};
        fprintf(1, 'Now reading %s\n', filepath);
        [path,name,ext] = fileparts(filepath);
       
        % read in the image referenced by filepath
        leaf = imread(filepath);
  
        % mask the leaf, tag, and colorbar from the image.
       [leaf,tag_color] = mask_rough(leaf);
  
        % find the height, width, and depth of the leaf image.
        [ht,wd,dp] = size(leaf);
  
        [~,~,~,~,div_im,y_coord,x_coord] = multires_sink(leaf(:,:,1), ...
        parms.wav_dpth,parms.nav_mu,parms.nav_lambda,parms.nav_thresh,parms.nav_its);

        min_im = min(div_im,[],3);
        min_im = min_im(y_coord+1:y_coord+ht,x_coord+1:x_coord+wd);
    
        %[sink_im,flow_im] = multires_grad_flow(nav_cell,parms.div_thresh);
  
        seg_im = snake_seg(leaf(:,:,1),min_im<parms.div_thresh,parms.cont_its,parms.cont_alpha,parms.l_size,parms.u_size);
        
        pink_im = pink_bounds(leaf,bwperim(seg_im));
        imwrite(seg_im,strcat(out_dir,'mask/',name,'_mask.png'));
        imwrite(pink_im,strcat(out_dir,'pink/',name,'_pink.tif'));
  
        clear image;
     
       
   end

end



%%%%%% subroutines %%%%%%%%

% read in a string file, where each row is a separate string

function cell_array = input_string_file(file,format)

   input_stream = fopen(file);
   cell_array = textscan(input_stream,format);
   fclose(input_stream);

end


% read in a hash file, where the first row is reference names and the
% second row is their values. this produces a struct array.

function parameter_struct = input_hash_file(file,frmt,n)

    input_stream = fopen(file);
    parameter_fields = textscan(input_stream,'%s',n,'delimiter',',');
    parameter_values = textscan(input_stream,frmt,n,'delimiter',',','CollectOutput',1);
    parameter_struct = cell2struct(num2cell(parameter_values{1}),cellstr(parameter_fields{1}),1);
    fclose(input_stream);

end





        
