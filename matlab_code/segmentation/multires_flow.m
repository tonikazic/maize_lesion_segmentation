function [sink_im,flow_im] = multires_flow(nav_cell,div_cell)


grad_x = nav_cell{1,1};
grad_y = nav_cell{1,2};

[ht wd dp] = size(grad_x);


% creates a gradient magnitude vector from the horizontal(grad_x) and
% vertical (grad_y) components of the gradient.
grad_m = (grad_x.^2 + grad_x.^2).^0.5;
grad_m_vec = reshape(grad_m,ht*wd,1);
grad_m_vec(isnan(grad_m_vec)) = 0;
grad_m = reshape(grad_m_vec,ht,wd);


%grad_dir = atan2(grad_y,grad_x);
%delt_dir = rangefilt(grad_dir);

%div_im = divergence(grad_x,grad_y);
mask_im = div_im<thresh;

%lap_filt = fspecial('laplacian');
%lap_m = imfilter(grad_m,lap_filt);


% the flow mask tracks the paths along the gradient. these terminate when
% the change in angle is greater than pi/2. these terminations represent
% sinks, and are tracked in sink_mask.
%global sink_mask;

flow_mask = zeros(ht,wd);
sink_mask = zeros(ht,wd);

% k is an index used to keep track of unique sinks, i.e. paths which do not
% meet other paths or sinks which are not connected to other sinks.
k = 1;


% l is the current resolution
l = 1;

for i=1:ht
    
    for j=1:wd
        
        
        % test that the path has not already been tracked and that the
        % gradient is greater than specified threshold
        if flow_mask(i,j) == 0 && mask_im(i,j) == 1
            
        x = j;
        y = i;
        
        flow_temp = zeros(1,2);
        len_flow = 1;

        
        while flow_mask(y,x) == 0
            
            grad_x = nav_cell{l,2};
            grad_y = nav_cell{l,1};
            
            flow_temp(len_flow,1) = y;
            flow_temp(len_flow,2) = x;
                
            dx = round(grad_x(y,x)/grad_m(y,x));
            dy = round(grad_y(y,x)/grad_m(y,x));
            
            if y+dy<1 || y+dy>ht || x+dx<1 || x+dx>wd % test for boundary
                
                break;
            end
            
            grad_i = 1/grad_m(y,x)*[grad_x(y,x); grad_y(y,x)];
            grad_d = 1/grad_m(y+dy,x+dx)*[grad_x(y+dy,x+dx); ...
                                          grad_y(y+dy,x+dx)];
            
            
            d_theta = acos(grad_i'*grad_d);
            
            if d_theta < pi/2 && div_im(y+dy,x+dx) < div_im(y,x)
                
                x = x+dx;
                y = y+dy;
                
                len_flow = len_flow + 1;
                
            else
                    
                neighbor_sink = get_neighbors(sink_mask,y,x);
                
                if neighbor_sink > 0
                    
                    sink_mask(y,x) = neighbor_sink;
                    flow_mask(flow_temp(:,1),flow_temp(:,2)) = neighbor_sink;
                    
                else
                    sink_mask(y,x) = k;
                    flow_mask(flow_temp(:,1),flow_temp(:,2)) = k;
                    k = k+1;
                    
                end
                
                break;
            end  
        end 
        
        flow_mask(flow_temp(:,1),flow_temp(:,2)) = flow_mask(y,x);
        end
    end
end


    function 


flow_im = flow_mask;

sink_im = sink_mask;
        
      
    
end


function neighbor = get_neighbors(sink_mask,y,x)

%    global sink_mask;

    [ht wd] = size(sink_mask);

    if y==1
        y_low = 1;
    else
        y_low = y-1;
    end
    
    if x==1
        x_low = 1;
    else
        x_low = x-1;
    end
    
    if y==ht
        y_high = ht;
    else
        y_high = y+1;
    end
    
    if x==wd
        x_high = wd;
    else
        x_high = x+1;
    end
    
    neigh_pix = sink_mask(y_low:y_high,x_low:x_high);

    [neigh_row neigh_col] = find(neigh_pix);
    
    if isempty(neigh_row);
        neighbor = 0;
        
    else
        neighbor = neigh_pix(neigh_row(1),neigh_col(1));
    end

    
end




