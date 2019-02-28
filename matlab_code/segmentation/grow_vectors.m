function [growth_im evo_x evo_y] = grow_vectors(image,del_x,del_y,thresh)

[ht wd] = size(del_x);


% produces gravity image. 'kern' is a smoothing kernel based on
% gravitational forces (here, F = (m1 + m2)/r^2, where r is the radius and
% m1 and m2 are the values of image at each point.) 
% 
kern = zeros(5);
kern(3,3) = 1;
kern = (1./bwdist(kern)).^0.5;
kern(3,3) = 1;
kern = double(kern);

grav_im = mat2gray(imfilter(image,kern,'same'));
grav_vec = reshape(grav_im,ht,wd);


del_m = (del_x.^2 + del_y.^2).^0.5;
evo_m = del_m;

thresh_idx = find(del_m<thresh);

del_x(thresh_idx) = 0;
del_y(thresh_idx) = 0;

dir_x = del_x./del_m;
dir_y = del_y./del_m;

evo_x = dir_x;
evo_y = dir_y;

[X Y] = meshgrid(1:wd,1:ht);

locations = zeros(ht,wd,2);

heat_map = zeros(ht,wd);

loca_prev = cat(3,X,Y);

orig_vec = reshape(loca_prev,ht*wd,2);

for i=1:100
    
    locations(:,:,1) = X + floor(i*dir_x);
    locations(:,:,2) = Y + floor(i*dir_y);

    
    prev_vec = reshape(loca_prev,ht*wd,2); % previous positions
    loca_vec = reshape(locations,ht*wd,2); % new positions    
    
    % only considers changes in new locations
    clean_vec = orig_vec;
    clean_vec = clean_vec(any((loca_vec-prev_vec)'),:);
    loca_vec = loca_vec(any((loca_vec-prev_vec)'),:);


    clean_vec = clean_vec(all(loca_vec'>1),:); % removes points beyond the boundary
    loca_vec = loca_vec(all(loca_vec'>1),:);
    
    
    clean_vec = clean_vec(loca_vec(:,1)<wd,:); % removes points beyond the boundary
    loca_vec = loca_vec(loca_vec(:,1)<wd,:);
    
    
    clean_vec = clean_vec(loca_vec(:,2)<ht,:); % removes points beyond the boundary
    loca_vec = loca_vec(loca_vec(:,2)<ht,:);
   
 
    idx = sub2ind([ht wd],loca_vec(:,2),loca_vec(:,1));
    clean_idx = sub2ind([ht wd],clean_vec(:,2),clean_vec(:,1));

    idx_inc = idx(grav_vec(idx)>grav_vec(clean_idx)); % only considers points that are increasing
    clean_inc = clean_idx(grav_vec(idx)>grav_vec(clean_idx));
    
    for j=1:length(idx_inc)
        evo_m(idx_inc(j)) = (evo_m(idx_inc(j)) + del_m(clean_inc(j)));
    end
    
%    del_m(clean_inc) = evo_m(idx_inc) + del_m(clean_inc);

    
    [num_inc positions] = hist(idx_inc,unique(idx_inc));
    
    heat_map(positions) = heat_map(positions) + num_inc';
    
    imshow(mat2gray(evo_m)),colormap(jet);
%    quiver(flipud(dir_x(293:345,1870:1937)),-flipud(dir_y(293:345,1870:1937)));
    pause(0.001);
    

    
    loca_prev = locations;
    
    
end

growth_im = heat_map;

end