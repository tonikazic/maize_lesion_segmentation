function [fill_x,fill_y] = fill_gaps(x,y,ht,wd)
% This function is designed to fill in gaps in polygon data using a ridge
% following algorithm


vertices = unique(horzcat(x,y),'rows');

idx = sub2ind([ht,wd],vertices(:,2),vertices(:,1));

mask = zeros(ht,wd);

mask(idx) = 1;

[endpty,endptx] = ind2sub([ht,wd],find(bwmorph(bwmorph(bwmorph(mask,'clean'),'skel'),'endpoints')));
[brnchy,brnchx] = ind2sub([ht,wd],find(bwmorph(bwmorph(bwmorph(mask,'clean'),'skel'),'branchpoints')));

dist_mat = get_dist_mat(brnchx,endptx,brnchy,endpty);

[C,brnch_mins] = min(dist_mat);

if length(endptx)>2

    endptx(brnch_mins) = [];
    endpty(brnch_mins) = [];
end
k=0;
while ~isempty(endptx)
    
    if k>25
        break;
    end
    
    dist_mat = get_dist_mat(endptx,endptx,endpty,endpty);
    dist_mat(dist_mat==0) = 100;
    [C,end_mins] = min(dist_mat);

    for i=1:length(endptx)
    
        [x,y] = bresenham(endptx(i),endpty(i),endptx(end_mins(i)),endpty(end_mins(i)));
        vertices = vertcat(vertices,horzcat(x,y));
    
    end
    
    vertices = unique(vertices,'rows');

    idx = sub2ind([ht,wd],vertices(:,2),vertices(:,1));

    mask = zeros(ht,wd);
    mask(idx) = 1;

    [endpty,endptx] = ind2sub([ht,wd],find(bwmorph(bwmorph(bwmorph(mask,'clean'),'skel'),'endpoints')));
    [brnchy,brnchx] = ind2sub([ht,wd],find(bwmorph(bwmorph(bwmorph(mask,'clean'),'skel'),'branchpoints')));

    dist_mat = get_dist_mat(brnchx,endptx,brnchy,endpty);

    [C,brnch_mins] = min(dist_mat);

    if length(endptx)>2 

        endptx(brnch_mins) = [];
        endpty(brnch_mins) = [];
    end
    k=k+1;
end

fill_x = vertices(:,1);
fill_y = vertices(:,2);

end


function dist_mat = get_dist_mat(x1,x2,y1,y2)

[xx,xy] = meshgrid(x1,x2);
[yx,yy] = meshgrid(y1,y2);

dist_mat = ((xx-xy).^2 + (yx-yy).^2).^0.5;

end