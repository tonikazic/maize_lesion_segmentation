function connect_im = connect_sinks(sink_im,flow_im,del_x,del_y)

dir_im = atan2(del_y,del_x) + pi;

[ht wd] = size(flow_im);

num_les = max(max(sink_im));

connect_im = zeros(ht,wd);

for i=1:num_les
    
    if range(dir_im(flow_im==i)) < 3*pi/2
    
    [row col] = find(sink_im==i);
    
    center_y = round(mean(row)); 
    center_x = round(mean(col));
    
    mean_x = mean(del_x(flow_im==i));
    mean_y = mean(del_y(flow_im==i));
    mean_m = (mean_x^2 + mean_y^2).^0.5;
    
    
    
    
    
    slope = mean_y/mean_x;
    
    x_coords = 0:round(mean_x);
    
    if isempty(x_coords) == 1
        x_coords = round(mean_x):0;
        
    end
        
    y_coords = round(slope*x_coords);
    
    
    coords = vertcat(center_y + y_coords,center_x + x_coords)';
    
    coords = coords(all(coords'>1),:);
    coords = coords(coords(:,1)<ht,:);
    coords = coords(coords(:,2)<wd,:);
    
    coords = sub2ind([ht wd],coords(:,1),coords(:,2));
    
    connect_im(coords) = connect_im(coords) + 1;
    
    end
end
    
    








end