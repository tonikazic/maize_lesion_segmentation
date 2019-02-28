% read in the image referenced by full_filename
% input image directory 
full_filename = '/athe/c/maize/analysis_images/tiffs/16r/gimmel/avi_test/DSC_0090.tiff';
          leaf = imread(full_filename);

  
% mask the leaf, tag, and colorbar from the image.

%         [leaf,tag_color] = mask_rough(leaf);
          leaf = mask_lab(leaf);

% find the height, width, and depth of the leaf image.

          [ht,wd,dp] = size(leaf);
  
%          [~,~,~,~,div_im,y_coord,x_coord] = multires_sink(leaf(:,:,1), ...
%              parms.wav_dpth,parms.nav_mu,parms.nav_lambda,parms.nav_thresh,parms.nav_its);

%          min_im = min(div_im,[],3);
%          min_im = min_im(y_coord+1:y_coord+ht,x_coord+1:x_coord+wd);
    
%         [sink_im,flow_im] = multires_grad_flow(nav_cell,parms.div_thresh);
  
%          seg_im = snake_seg(leaf(:,:,1),min_im<parms.div_thresh,parms.cont_its,parms.cont_alpha,parms.l_size,parms.u_size);
        
%       to extract leaf number from name variable  
%
% vatsa 10.9.2016

%          for n = 1:length(name)
%           [chars] = cell2mat(textscan(name,'%c'));
%          end
%          leaf_number = strcat(chars(5),chars(6),chars(7),chars(8));


% replace above code by following code, to make more efficient.
%
%
% I was making folder of leaf name, only with number part. I should
% replace the code with this. because here I am not gonna use for loop.
%
%    name2 = 'DSC_0094';
%    aa = reshape(name2,8,[]).';
%    leaf_number = aa(5:8);
%    strcat(leaf_number,'_avi')
%
% vatsa 10.12.2016

% we want to rid off the midrib from masked leaf, variable here is leaf, so this code is finding outer boundary 
% of masked leaf then find the mid points of outer boundary. It assuemed that the mid points would lies on 
% mid rib thereafter we will spline fit the lines and will find straight line along mid rib.
%
% vatsa 10.12.2016


bw = im2bw(leaf);
figure, imshow(bw);
dim = size(bw);
col = round(dim(2)/2);
row = min(find(bw(:,col)));
% boundary = bwtraceboundary(bw,[row,col],'N');

hold on;
% plot(boundary(:,2), boundary(:,1),'g','LineWidth',2);

bw_filled = imfill(bw,'holes');
boundaries = bwboundaries(bw_filled);

for k = 1:length(boundaries)
    b = boundaries{k};
    plot(b(:,2),b(:,1),'g','LineWidth',2);
end


% let's find mid point along the leaf. then discard the carpet tape.
%




          
       
