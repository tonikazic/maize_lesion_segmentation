function [sink_im,flow_im] = multires_grad_flow(nav_cell,thresh)




depth = size(nav_cell,1);


sink_im = zeros(size(nav_cell{depth,1}));
flow_im = zeros(size(nav_cell{depth,1}));

for i=depth:-1:1
    

    [sink_im,flow_im] = grad_flow(nav_cell{i,2},nav_cell{i,1},sink_im,flow_im,thresh);
    
    
    if i>1
        sink_im = kron(sink_im,ones(2));
        flow_im = kron(flow_im,ones(2));
    end
    imshow(mat2gray(divergence(nav_cell{i,2},nav_cell{i,1}))),colormap('jet');
    %imshow(divergence(nav_cell{i,2},nav_cell{i,1})<-50)
    %imshow((nav_cell{i,1}.^2 + nav_cell{i,2}.^2).^0.5>100);
    pause(1);
end
end