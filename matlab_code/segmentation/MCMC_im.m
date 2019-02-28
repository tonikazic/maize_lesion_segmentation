function [hit_im n_vec] = MCMC_im(daub_im,its,thresh)


[dp br] = size(daub_im);


n_vec = zeros(dp,1);


hit_im = zeros(size(daub_im{1,1}));

n = dp;
x = randi(size(daub_im{dp,1},2),1);
y = randi(size(daub_im{dp,1},1),1);

for i=1:its
    
    if n == 1
        
        hit_im(y,x) = hit_im(y,x) + 1;
        [n x y] = move_up(n,x,y);
        
    elseif n == dp
        
        x = randi(size(daub_im{dp,1},2),1);
        y = randi(size(daub_im{dp,1},1),1);
        [n x y] = move_down(n,x,y);
        
    else
        
        r = rand(1); % generate random number
        
        if r <= thresh
            
            [n x y] = move_down(n,x,y);
            
        else
            
            [n x y] = move_up(n,x,y);
            
        end
    end
    
    n_vec(n) = n_vec(n) + 1;
%    imshow(mat2gray(hit_im)),colormap('jet');
%    pause(0.001);
end




    function [n x y] = move_up(n,x,y)
        
        x = ceil(x/2);
        y = ceil(y/2);
        n = n+1;
    end

    function [n x y] = move_down(n,x,y)
        
        temp = daub_im{n-1,1};
        vec = reshape(temp((y*2-1):y*2,(x*2-1):x*2),4,1);
        prob_vec = cumsum(vec/sum(vec));
        
        r = rand(1);
        
        if r <= prob_vec(1)
            x = x*2-1;
            y = y*2-1;
            
        elseif r <= prob_vec(2)
            x = x*2-1;
            y = y*2;
            
        elseif r<= prob_vec(3)
            x = x*2;
            y = y*2-1;
            
        else
            x = x*2;
            y = y*2;
            
        end
        
        n = n-1;
        
    end



end