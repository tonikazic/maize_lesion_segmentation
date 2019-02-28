function ridges = ridge_walk(seeds,grad_x,grad_y)

% ridge_walk is a function designed to follow the path of highest gradient
% around an object in an image. It takes as parameters 'seeds,' the location
% of points to initiate the algorithm, 'grad_x,' the x (horizontal) component
% of the gradient, and 'grad_y,' the vertical component of the gradient.
%
% The algorithm operates by first computing the cross product of the
% vectors described by the grad_x and grad_y components with a 'z'
% vector, which can be imagined as point out of or into the screen. This
% produces vectors which are normal to the gradient; when these vectors
% describe a closed path, an object of interest can be segmented, otherwise
% the program halts.
%
% The algorithm initiates at each of the seeds iteratively. Upon
% initiation, the algorithm searches in the direction that the normal
% vector, described above, is pointing. To do this, the kernels below
% (identified as kern_*) are applied to the pixels surrounding the current
% pixel, which at the time of initiation is the seed. Directions are
% assigned to categories laying within sections of size pi/4, allowing for
% 8 possible directions. The gradient with the greatest magnitude laying in
% this direction is taken as the next pixel of the algorithm, and the
% algorithm repeats
%
% The matrix 'ridges' is returned. This is a logical matrix which has the
% ridges



[ht wd] = size(grad_x);


% calculate the magnitude of the gradient
grad_mag = (grad_x.^2 + grad_y.^2).^0.5; 


% calculates the direction of the gradient
grad_dir = atan2(grad_y,grad_x); 


% creates a matrix of the horizontal and vertical gradient in the plane of 
% the image
cross_xy = zeros(ht,wd,3); 
cross_xy(:,:,1) = grad_x;
cross_xy(:,:,2) = grad_y;


% the vector in the z plane (normal to the plane of the image) to cross
cross_z = zeros(ht,wd,3);
cross_z(:,:,3) = 1;


% crossing the x/y components of the gradient with the z-vector  creates a
% vector normal to both, i.e. tangent to the edge of the lesion. the sign
% of z will change the direction of the tangent vector
cw_norm  = cross(cross_z,cross_xy,3);
ccw_norm = cross(-cross_z,cross_xy,3);


% finds the direction theta|(-pi/2,pi/2) of the tangent vector
cw_dir  = atan2(cw_norm(:,:,2),cw_norm(:,:,1));
ccw_dir = atan2(ccw_norm(:,:,2),ccw_norm(:,:,1));


% depending on the direction, a different set of pixels are of interest.
% the kern_* matrices extract these pixels corresponding to the direction
kern_um = [ 1 1 1  ;
            0 0 0  ;
            0 0 0 ];
        
kern_ul = [ 1 1 0  ;
            1 0 0  ;
            0 0 0 ];
       
kern_lm = [ 1 0 0  ;
            1 0 0  ;
            1 0 0 ];
        
kern_dl = [ 0 0 0  ;
            1 0 0  ;
            1 1 0 ];        
          
kern_dm = [ 0 0 0  ;
            0 0 0  ;
            1 1 1 ];
        
kern_dr = [ 0 0 0  ;
            0 0 1  ;
            0 1 1 ];
          
kern_rm = [ 0 0 1  ;
            0 0 1  ;
            0 0 1 ];
        
kern_ur = [ 0 1 1  ;
            0 0 1  ;
            0 0 0 ];
         
  
        
ridges = false(ht,wd,2*size(seeds,1));

% seeds is doubled so that a ridge can be calculated in both directions
% (clockwise and counterclockwise) from each seed
for i=1:(2*size(seeds,1)) 
    
    
    current_x = seeds(ceil(i/2),1);
    current_y = seeds(ceil(i/2),2);
    
    while ridges(current_y,current_x,i) ~= 1 ...
       && current_y > 1 && current_y < ht  ...
       && current_x > 1 && current_x < wd
   
        
        % finds the values of the pixels surrounding the current pixel
        surround_pix = [grad_mag(current_y-1,current_x-1),...
                        grad_mag(current_y-1,current_x  ),...
                        grad_mag(current_y-1,current_x+1);...
                        grad_mag(current_y  ,current_x-1),...
                                                        0,...
                        grad_mag(current_y  ,current_x+1);...
                        grad_mag(current_y+1,current_x-1),...
                        grad_mag(current_y+1,current_x  ),...
                        grad_mag(current_y+1,current_x+1)];
    
                    
        % on odd values of i, the clockwise direction is used, on even
        % values of i the counterclockwise direction is used
        if mod(i,2) == 0
            dir = ccw_dir(current_y,current_x);
            
        else
            dir = cw_dir(current_y,current_x);
            
        end
    
    
    
        % each statement is responsible for finding the appropriate kern_*
        % and calling get_next_pix to find the direction of the next pixel
        if dir >= -pi/8 && dir <= pi/8
            [delt_x delt_y] = get_next_pix(surround_pix,kern_rm);
    
        
        elseif dir > -pi/8 && dir <= -3*pi/8
            [delt_x delt_y] = get_next_pix(surround_pix,kern_ur);
        
        
        elseif dir > -3*pi/8 && dir <= -5*pi/8
            [delt_x delt_y] = get_next_pix(surround_pix,kern_um);
        
        
        elseif dir > -5*pi/8 && dir <= -7*pi/8
            [delt_x delt_y] = get_next_pix(surround_pix,kern_ul);
        
        
        elseif dir < pi/8 && dir >= 3*pi/8
            [delt_x delt_y] = get_next_pix(surround_pix,kern_dr);
    
        
        elseif dir < 3*pi/8 && dir >= 5*pi/8
            [delt_x delt_y] = get_next_pix(surround_pix,kern_dm);
        
        
        elseif dir < 5*pi/8 && dir >= 7*pi/8
            [delt_x delt_y] = get_next_pix(surround_pix,kern_dl);
        
        
        else
            [delt_x delt_y] = get_next_pix(surround_pix,kern_lm);
        
        
        end
    
    
    % sets the current pixel to 1 (found)
    ridges(current_y,current_x,i) = 1;
    
    % moves the current pixels to the next pixel of interest
    current_x = current_x + delt_x;
    current_y = current_y + delt_y;
    
    
    end


    
    
    
end
end


function [delt_x delt_y] = get_next_pix(surround_pix,kern)
% this function takes surround_pix, a 3x3 matrix of the pixels surrounding
% the current pixel of interest, and the kernel, which is decided upon by
% the direction of the normal to the gradient (clockwise or
% counterclockwise). the highest gradient value in the direction if
% interest is calculated and delt_x (appropriate change in x) and delt_y 
% (appropriate change in y) are calculated


        pix_int = surround_pix.*kern;
        
        [max_y vex_y] = max(pix_int);
        [max_x idx_x] = max(max_y);
        delt_y = (vex_y(idx_x))-2;
        delt_x = idx_x-2;

end


