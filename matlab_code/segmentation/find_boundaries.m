function bound_mask = find_boundaries(grad_x,grad_y,thresh)



[ht wd] = size(grad_x);


%srgb2lab = makecform('srgb2lab');
%lab_im = double(applycform(im,srgb2lab));


%[sh sv] = get_sobel_filter(size_sobel);
%sh = -sh;
%sv = -sv;


%grad_x = imfilter(lab_im(:,:,2),sh,'symmetric');
%grad_y = imfilter(lab_im(:,:,3),sv,'symmetric');
grad_mag = (grad_x.^2 + grad_y.^2).^0.5;

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
        
[seed_y seed_x] = find(grad_mag>thresh);

bound_mask = false(ht,wd);

for i=1:length(seed_y)
        
    x = seed_x(i);
    y = seed_y(i);
    
    length_ridge = 1;
    
    ridges = zeros(ht,wd);
    
    if mod(x*y,2) == 0
        
        dir_mat = ccw_dir;
    else
        
        dir_mat = cw_dir;
    end
        
    
    while ridges(y,x) ~= 3 && bound_mask(y,x) ~= 1 ...
       && y > 1 && y < ht  ...
       && x > 1 && x < wd
    
   surround_pix = [grad_mag(y-1,x-1), grad_mag(y-1,x  ), grad_mag(y-1,x+1);...
                   grad_mag(y  ,x-1),         0        , grad_mag(y  ,x+1);...
                   grad_mag(y+1,x-1), grad_mag(y+1,x  ), grad_mag(y+1,x+1)];
               
               
               dir = dir_mat(y,x);
                    
                    
            % each statement is responsible for finding the appropriate kern_*
            % and calling get_next_pix to find the direction of the next pixel            
            if dir >= -pi/8 && dir <= pi/8
                [dx dy] = get_next_pix(surround_pix,kern_rm);
    
        
            elseif dir < -pi/8 && dir >= -3*pi/8
                [dx dy] = get_next_pix(surround_pix,kern_ur);
        
        
            elseif dir < -3*pi/8 && dir >= -5*pi/8
                [dx dy] = get_next_pix(surround_pix,kern_um);
        
        
            elseif dir < -5*pi/8 && dir >= -7*pi/8
                [dx dy] = get_next_pix(surround_pix,kern_ul);
        
        
            elseif dir > pi/8 && dir <= 3*pi/8
                [dx dy] = get_next_pix(surround_pix,kern_dr);
    
        
            elseif dir > 3*pi/8 && dir <= 5*pi/8
                [dx dy] = get_next_pix(surround_pix,kern_dm);
        
        
            elseif dir > 5*pi/8 && dir <= 7*pi/8
                [dx dy] = get_next_pix(surround_pix,kern_dl);
        
        
            else
                [dx dy] = get_next_pix(surround_pix,kern_lm);
        
        
            end
        
            % sets the current pixel to 1 (found)
            ridges(y,x) = 1;
    
            grad_i = 1/grad_mag(y,x)*[grad_x(y,x); grad_y(y,x)];
            grad_d = 1/grad_mag(y+dy,x+dx)*[grad_x(y+dy,x+dx); ...
                                            grad_y(y+dy,x+dx)];
            
            
            d_theta = acos(grad_i'*grad_d);
    
            if d_theta > pi/2 || length_ridge > 1000
        
                break;
            end
    
            % moves the current pixels to the next pixel of interest
            x = x + dx;
            y = y + dy;
            length_ridge = length_ridge + 1;
        
        
        
    end
    
    bound_mask = bound_mask + logical(ridges);
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