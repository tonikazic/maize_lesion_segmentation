function [I,g]= image3DPlot(leaf)
% 3 dimensional plot of any RGB Image
%
% full_filename = '/athe/d/avi/mask_DSC_0090.tiff'; 
%
 I(:,:,:)=imread(leaf);
 figure(1), imshow(I),title('Original Maze leaf');
 text(size(I,2),size(I,1)+15,...
     'Image for 3-D plot @KazicLab', ...
     'FontSize',10,'HorizontalAlignment','right');
 
 % [x,y,z]=meshgrid(1:size(I,1),1:size(I,2),1:size(I,3));
 
 foo_sz = size(I,1) * size(I,2);
 
 k = 1;
 for j = 1:size(I,2) 
     for i = 1:size(I,1)
         foo(1,k) = I(i,j,1);
         foo(2,k) = I(i,j,2);
         foo(3,k) = I(i,j,3);
         k = k+1;
      end
 end
 k=k-1;
 
 c = rgb2hsv(reshape(foo(:,:),k,3));
 g = figure(2),scatter3(foo(1,:),foo(2,:),foo(3,:),5,c(:,1),'filled');
 
 % following is three dimensional scatter plot in which user define the
 % size and color of data points.
 %
 % vatsa 10.7.2016
 
 
 
 
end


 
 




