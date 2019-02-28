function [comp_x,comp_y] = complete_polygons(x,y)
% This function is designed to fill in gaps in polygon data


% find means to center at (approximately) [0,0]
mean_x = round(mean(x));
mean_y = round(mean(y));

% center at (approximately) [0,0]
sub_x = x - mean_x;
sub_y = y - mean_y;

% convert to polar cooardinates for sorting rotationally
[theta,rho] = cart2pol(sub_x,sub_y);

% concatenate all relevant data for sorting
full_vec = sortrows(horzcat(theta,rho,sub_x,sub_y),1);

len = size(full_vec,1);
dist_vec = zeros(len,1);
idx = 1:(len-1);

% the distance between a point and the next point
dist_vec(idx) = ((full_vec(idx+1,3)-full_vec(idx,3)).^2 + ...
                 (full_vec(idx+1,4)-full_vec(idx,4)).^2).^0.5;

dist_vec(len) = ((full_vec(1,3)-full_vec(len,3)).^2 + ...
                 (full_vec(1,4)-full_vec(len,4)).^2).^0.5;
               
% if the distance between two adjacent points is greater than sqrt(2), then
% those points are not connected
holes = find(dist_vec>sqrt(2));

for i=1:length(holes)

    % bresenham.m returns the pixels connecting two points, [x1,y1] and
    % [x2,y2]
    
    if holes(i) < len
        [x,y] = bresenham(full_vec(holes(i),3),full_vec(holes(i),4),full_vec(holes(i)+1,3),full_vec(holes(i)+1,4));
    else
        [x,y] = bresenham(full_vec(len,3),full_vec(len,4),full_vec(1,3),full_vec(1,4));
    end
        
    % add pixels to the x and y arrays
    sub_x = vertcat(sub_x,x);
    sub_y = vertcat(sub_y,y);
end

comp_poly = unique(horzcat(sub_x+mean_x,sub_y+mean_y),'rows');
comp_x = comp_poly(:,1);
comp_y = comp_poly(:,2);

end
