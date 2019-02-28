% this is /athe/d/derek/code/image_processing/segmentation/segment_pipe/batch_segment_call.m
%
% this is a batch version of segment_call.m, which also handles directory
% management, creation of tiffs, and output of segmented lesions to the
% appropriate directories.  
%
% It calls check_n_convert_image_trees.perl, which compares directory trees
% to check if the tiffs have been created.  In turn, that script calls the 
% compiled version of dcraw.c to create the tiffs if needed.
%
% Need to make this executable from the shell.
%
% Vatsa and Kazic, 10.9.2016





% old notes:  we are modifying the arguments of segment_call
%
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
% this we will create after a file test, using out_dir as the root of the output directory,
% so one can pass in "/athe/d/linh/image_processing/results/output_apply_maskSUFFIX" from the command line
%
% Kazic and Ngo, 22.1.2016




% we want to modify file handling as follows:
%
%    get a timestamp that will be in the string for all produced data
%    pass in a directory containing the image files
%    construct the list of files in that input directory
%    write that list out to a timestamped data file
%    create timestamped subdirectories for output data
%    call the segmentation code on each of those files, writing out masks and pinks to appropriate subdirs
%    record everything in a segmentation log org file
%
%
% after segmentation, before closing the output files:
%
%    filter out midrib and junk???? unclear, defer for now until we
%         understand their characteristics
%    write timestamped, identified lesions out to appropriate data
%         structures
%
%
% do dimension construction and analysis on the saved lesions in a separate
% script, since this is likely to change a lot.
%
% Vatsa and Kazic, 10.9.2016








%%%% 
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



% call is batch_segment_call('16r/gimmel/26.7','parameters',10)

function batch_segment_call(input_dir,parameters_file,n)




% read in the parameters_file and if it's missing a parameter, set that
% parameter to its default value

    parms = input_hash_file(parameters_file,'%f',n);

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





% timestamping, directory management, and conversion of NEFs to tiffs
%
%
% get the system time as a 10 digit integer for use in directory 
% and file labelling, and in the log file.
%
% on the mac, one approach is a call to the shell:
%
%  date +%s
% 
% which returns a 10 digit integer.  For this, see
% http://apple.stackexchange.com/questions/135742/time-in-milliseconds-since-epoch-in-the-terminal
% 
%
% ok, call the shell and then discard the first argument of the array;
% the second is the desired timestamp.


    [s,t] = system('date +%s');




% first create the needed output directories under 
% 
% hard-wire the names of the analysis directory and the out_dir.  The
% analysis directory won''t change, but the out_dir might from script to 
% script.
%
% datafiles will go under the out_dir, but needn''t be in separate
% subdirectories; also a copy of the parameters_file, so we know what 
% we did!


    root_dir = '/athe/c/maize/analysis_images/';
    out_dir = 'segext/segext';
    tiff_root = '/athe/c/maize/analysis_images/tiffs/';


% test this using the matlab command line

    seg_dir = strcat(root_dir,out_dir,'_',t,'/');
    pink_dir = strcat(seg_dir,'pink');
    mask_dir = strcat(seg_dir,'mask');
    tape_mask_dir = strcat(seg_dir,'tape_mask');
    lesions_dir = strcat(seg_dir,'lesions');

    mkdir(pink_dir);
    mkdir(mask_dir);
    mkdir(tape_mask_dir);
    mkdir(lesions_dir);

    [parmpath,parmname,parmextension] = fileparts(parameters_file);
    copyfile(parameters_file,strcat(seg_dir,parmname,parmextension));





% Now call ./check_n_convert_image_trees.perl.
%
% Given an input directory of images in the /athe/c/maize/images tree,
% check to see if all the NEFS in that directory have first been converted 
% into tiffs under the /athe/c/maize/analysis_images/tiffs tree.  The
% suffices of the two trees will be the same, e.g., ../16r/CAMERA/DATE/.
%
% If the tiffs exist, then proceed to segmentation and lesion output.
% If not, then create the tiffs.  The perl script checks to be sure
% we have the tiffs, and returns 0 (==success) if the tiffs exist or if
% it has successfully created them.
%
% Image conversion uses Dave Coffin's dcraw,
% https://www.cybercom.net/~dcoffin/dcraw/
%
% We''ve downloaded the new version, compiled it, and placed it here.  The perl
% script calls the compiled version by forking a shell process, and waits
% for control to return back to the perl script before proceeding.





     cmd = ['./check_n_convert_image_trees.perl ',input_dir,' ',tiff_root,' ',t];


% if status = 0 then perl script succeeded; 
% if > 0, then it failed someplace, so print helpful error messages
% and get out of dodge


     perl_status = system(cmd);


     if perl_status > 0 
          fprintf(1, 'check_n_convert_image_trees.perl exited with error code: %s\n', perl_status);
          if perl_status == 1 
               fprintf(1, 'error message is cannot open NEF files\n');
          elseif perl_status == 2
               fprintf(1, 'error message is cannot close input directory filehandle\n');
          elseif perl_status == 3
               fprintf(1, 'error message is  cannot close output directory filehandle\n');
          else
               fprintf(1, 'weird exit condition, check the perl script!\n');  
          end
          exit(0)
     end







% construct the array of input tiff files that we'll process


     input_tiff_dir = strcat(tiff_root,input_dir);
     file_pattern = fullfile(input_tiff_dir, '*.tiff');
     tiff_files = dir(file_pattern);
     
     for k = 1:length(tiff_files)
          base_filename = tiff_files(k).name;
          full_filename = fullfile(input_tiff_dir, base_filename);
          fprintf(1, 'Now reading %s\n', full_filename);
       

% it will divide the full_file_name into three parts: path, name and
% extension such that we can customize the output file name according to image. 
%
          [path,name,extension] = fileparts(full_filename);

     

       
% read in the image referenced by full_filename

          leaf = imread(full_filename);


  
% mask the leaf, tag, and colorbar from the image.

       %   [leaf,tag_color] = mask_rough(leaf);
           [leaf tag colorbar] = mask_flood(leaf,0.2);
           tape_mask_subdir = strcat(tape_mask_dir,'/mask_flood');
           mkdir(tape_mask_subdir);
           imwrite(leaf,strcat(tape_mask_subdir,'/',name,'_mask.tif'));
           imwrite(tag,strcat(tape_mask_subdir,'/',name,'_tag.tif'));
           imwrite(colorbar,strcat(tape_mask_subdir,'/',name,'_colorbar.tif'));

% find the height, width, and depth of the leaf image.

%           [ht,wd,dp] = size(leaf);
%   
%           [~,~,~,~,div_im,y_coord,x_coord] = multires_sink(leaf(:,:,1), ...
%               parms.wav_dpth,parms.nav_mu,parms.nav_lambda,parms.nav_thresh,parms.nav_its);
% 
%           min_im = min(div_im,[],3);
%           min_im = min_im(y_coord+1:y_coord+ht,x_coord+1:x_coord+wd);
%     
% %         [sink_im,flow_im] = multires_grad_flow(nav_cell,parms.div_thresh);
%   
%           seg_im = snake_seg(leaf(:,:,1),min_im<parms.div_thresh,parms.cont_its,parms.cont_alpha,parms.l_size,parms.u_size);
%         
%           pink_im = pink_bounds(leaf,bwperim(seg_im));
%           imwrite(seg_im,strcat(mask_dir,'/',name,'_mask.png'));
%           imwrite(pink_im,strcat(pink_dir,'/',name,'_pink.tif')); 
          
          


% now, given the image and the mask, pick out each lesion and write its output data
% appropriately to leaf_dir/
%
% vatsa 10.6.2016

%           name = 'DSC_0091';
%            for n = 1:length(name)
%            [chars] = cell2mat(textscan(name,'%c'));
%            end
%            leaf_number = strcat(chars(5),chars(6),chars(7),chars(8));
%            
%           % leaf_number = textscan(name,'%*4s %s');
%           % leaf_number1 = leaf_number{1};
%            leaf_dir = strcat(lesions_dir,'/',leaf_number);
%             mkdir(leaf_dir);
% 
%   %       [lesion_data, STATS_les, midRib] = quantitative_data(seg_im, leaf, leaf_dir);
% 
%   
          clear leaf;
          clear tag;
          clear colorbar;
          clear image;
          end



% open org log file, print header with parameters, and append parameters for each
% image to a table


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





        
