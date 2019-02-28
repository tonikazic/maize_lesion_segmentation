function [growth_im evo_x evo_y] = collide_vectors(image,del_x,del_y,thresh)

[ht wd] = size(del_x);


% produces gravity image. 'kern' is a smoothing kernel based on
% gravitational forces (here, F = (m1 + m2)/r^2, where r is the radius and
% m1 and m2 are the values of image at each point.) 
% 
%kern = zeros(5);
%kern(3,3) = 1;
%kern = (1./bwdist(kern)).^0.5;
%kern(3,3) = 1;
%kern = double(kern);

%grav_im = mat2gray(imfilter(image,kern,'symmetric'))*100;
%grav_vec = reshape(grav_im,ht,wd);


% magnitude of vectors
del_m = (del_x.^2 + del_y.^2).^0.5;
evo_m = zeros(ht,wd);

% only consider gradient vectors with magnitude above threshold
del_x(del_m<thresh) = 0;
del_y(del_m<thresh) = 0;


% normalizes to be unit vectors
dir_x = del_x./del_m; % direction vectors of origins
dir_y = del_y./del_m;

% direction vectors of destinations
evo_x = dir_x; 
evo_y = dir_y;

% origin points that the growing vectors will project from
[X Y] = meshgrid(1:wd,1:ht);

% tracks where vectors will arrive
locations = zeros(ht,wd,2);

% used to count how many unique vectors arrive at each point
heat_map = zeros(ht,wd);

% tracks the previous state, so that only new arrivals are considered
loca_prev = cat(3,X,Y);
orig_vec = reshape(loca_prev,ht*wd,2);

for i=1:100

    % find where vectors arrive
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
   
    % convert <x,y> indices to linear indicies
    idx_inc = sub2ind([ht wd],loca_vec(:,2),loca_vec(:,1));
    clean_inc = sub2ind([ht wd],clean_vec(:,2),clean_vec(:,1));
    
    
    % calculates the angle difference between the original vector and the
    % vector in the arrival position
    clean_dir = [dir_x(clean_inc)'; dir_y(clean_inc)'];
    idx_dir =   [evo_x(idx_inc)'; evo_y(idx_inc)'];
    
    d_theta = (pi-acos(dot(clean_dir,idx_dir,1)))./pi;
    
%    evo_x(d_theta>pi/3 & any(idx_dir)) = 0;
%    evo_y(d_theta>pi/3 & any(idx_dir)) = 0;
    
%    temp_x(clean_idx) = (i*del_x(clean_idx) + dir_x(idx));
%    temp_y(clean_idx) = (i*del_y(clean_idx) + dir_y(idx));
    
%    idx_inc = idx(grav_vec(idx)>grav_vec(clean_idx)); % only considers points that are increasing
%    clean_inc = clean_idx(grav_vec(idx)>grav_vec(clean_idx));


    for j=1:length(idx_inc)
        evo_x(idx_inc(j)) = (evo_x(idx_inc(j))*evo_m(idx_inc(j)) + dir_x(clean_inc(j))*del_m(clean_inc(j))*d_theta(j))/(evo_m(idx_inc(j)) + del_m(clean_inc(j)));
    end
    
    dir_x(clean_inc) = (evo_x(idx_inc).*evo_m(idx_inc) + dir_x(clean_inc).*del_m(clean_inc))./(evo_m(idx_inc) + del_m(clean_inc));
    

    for j=1:length(idx_inc)
        evo_y(idx_inc(j)) = (evo_y(idx_inc(j))*evo_m(idx_inc(j)) + dir_y(clean_inc(j))*del_m(clean_inc(j))*d_theta(j))./(evo_m(idx_inc(j)) + del_m(clean_inc(j)));
    end
    
    dir_y(clean_inc) = (evo_y(idx_inc).*evo_m(idx_inc) + dir_y(clean_inc).*del_m(clean_inc))./(evo_m(idx_inc) + del_m(clean_inc));
    
    dir_n = (dir_x.^2 + dir_y.^2).^0.5;
    pos_idx = dir_n~=0;
    dir_x(pos_idx) = dir_x(pos_idx)./dir_n(pos_idx);
    dir_y(pos_idx) = dir_y(pos_idx)./dir_n(pos_idx);
    
    evo_n = (evo_x.^2 + evo_y.^2).^0.5;
    pos_idx = evo_n~=0;
    evo_x(pos_idx) = evo_x(pos_idx)./evo_n(pos_idx);
    evo_y(pos_idx) = evo_y(pos_idx)./evo_n(pos_idx);
    
    temp_m = del_m;
    
    for j=1:length(idx_inc)
        evo_m(idx_inc(j)) = (evo_m(idx_inc(j)) + temp_m(clean_inc(j))*d_theta(j));
    end
    
%    del_m(clean_inc) = evo_m(idx_inc) + temp_m(clean_inc);
    
    [num_inc positions] = hist(idx_inc,unique(idx_inc));
    
    heat_map(positions) = heat_map(positions) + num_inc';
    
    imshow(mat2gray(mat2gray(evo_m))),colormap(jet);
%    quiver(flipud(evo_x(293:345,1870:1937)),-flipud(evo_y(293:345,1870:1937)));
    pause(0.001);
    

    
    loca_prev = locations;
    
    
end

growth_im = evo_m;

end