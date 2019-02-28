function master_input(data_file,parm_file,output_dir)

% The call for this function is:
%
% master_input('path_to_data_file','path_to_parm_file','output_directory');
%
% example call (to be used for testing purposes):
%
% master_input('/athe/c/maize/image_processing/code/pipelines/matlabtest/data_file','/athe/c/maize/image_processing/code/pipelines/matlabtest/parm_file','/athe/c/maize/image_processing/code/pipelines/matlabtest/output/');




    data = fopen(data_file);
    image_dirs = textscan(data,'%s');
    fclose(data);
    
    parm_open = fopen(parm_file);
    parameters = textscan(parm_open,'%s %f');
    parms = build_struct(parameters);
    fclose(parm_open);
    
    
    
    
    for k=1:size(image_dirs{1},1)
        
        im = imread(image_dirs{1}{k});
        
        [path name ext] = fileparts(image_dirs{1}{k});
        
        [nav_x nav_y] = navier_stokes(im(:,:,1:2),...
              parms.mu,parms.lambda,parms.nav_thresh,parms.iterations);
          
        [sink_im flow_im] = grad_flow(nav_x,nav_y,parms.flow_thresh);
            
        pink_im = pink_bounds(im,logical(sink_im));
        
        
        pink_filename = strcat(output_dir,name,'_pink.png');
        
        imwrite(pink_im,pink_filename);
        
        
    end
end
       






function built_struct = build_struct(array)


for i=1:size(array{2},1)
    
   built_struct.(array{1}{i}) = array{2}(i);
   
end
    
    
    
end

