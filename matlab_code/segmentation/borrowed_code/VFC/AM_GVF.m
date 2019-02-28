function Fext = AM_GVF(f, mu, in, normalize)
% AM_GVF        Compute the gradient vector flow (GVF) force field [5].
%     Fext = AM_GVF(f, mu, iter)
%     Fext = AM_GVF(f, mu, iter, normalize)
%   
%     Inputs
%     f           edge map, d1-by-d2 matrix for 2D, and d1-by-d2-by-d3 matrix for 3D.   
%     mu          GVF weighting parameter, which usually ranges from 0.01 to 0.2.
%     iter        GVF iteration number, which usually ranges from 20 to 100.
%     normalize   0 - (default) the output Fext is not nomalized,
%                 1 - output is normalized, i.e., sum(Fext(y,x,:).^2) = 1 
%                     for 2D, sum(Fext(y,x,z,:).^2) = 1 for 3D.
%               
%     Outputs
%     Fext        the GVF external force field. For 2D, d1-by-d2-by-2 matrix, 
%                 the force at (x,y) is [Fext(y,x,1) Fext(y,x,2)]. For 3D,
%                 d1-by-d2-by-d3-by-3 matrix, the force at (x,y,z) is
%                 [Fext(y,x,z,1) Fext(y,x,z,2) Fext(y,x,z,3)].
% 
%     Note that for memory saving reason, the output data class is single / float (32-bit).
%     
%     Example
%         See EXAMPLE_VFC, EXAMPLE_PIG.
%
%     See also AMT, AM_VFK, AM_VFC, AM_PIG, AM_ISOLINE, AM_DEFORM,
%     AC_INITIAL, AC_DISPLAY, EXAMPLE_VFC, EXAMPLE_PIG.  
% 
%     Reference
%     [1] Bing Li and Scott T. Acton, "Active contour external force using
%     vector field convolution for image segmentation," Image Processing,
%     IEEE Trans. on, vol. 16, pp. 2096-2106, 2007.  
%     [5] Chenyang Xu and Jerry L. Prince, "Snakes, Shapes, and Gradient
%     Vector Flow," Image Processing, IEEE Trans. on, vol. 7, pp. 359-369, 1998. 
% 
% (c) Copyright Bing Li 2005 - 2009.

% Revision Log
%   11-30-2005  original 
%   01-20-2006  c version 
%   01-30-2009  minor bug fix

%% inputs check
if ~ismember(nargin, 3:4)
    error('Invalid inputs to AM_GVF!')
elseif nargin < 4,
    normalize = 0;
end

%% this part is matlab prototype, please refer to .c and .dll files
if 0,
    f = single(f);
    fmin  = min(f(:));
    fmax  = max(f(:));
    f = (f-fmin)/(fmax-fmin);           % Normalize f to the range [0,1]

    if ndims(f)==2,
        [fx,fy] = AM_gradient(f);       % Calculate the gradient of the edge map
        fz = 0;
    else
        [fx,fy,fz] = AM_gradient(f);    % Calculate the gradient of the edge map
    end
    u = fx; v = fy; w = fz;             % Initialize GVF to the gradient
    SqrMagf = fx.*fx + fy.*fy + fz.*fz; % Squared magnitude of the gradient field

    % Iteratively solve for the GVF u,v,w
    for i=1:in,
        u = u + mu*AM_laplacian(u) - SqrMagf.*(u-fx);
        v = v + mu*AM_laplacian(v) - SqrMagf.*(v-fy);
        if ndims(f)==3,
            w = w + mu*AM_laplacian(w) - SqrMagf.*(w-fz);
        end
    end
    if ndims(f)==2,
        Fext = cat(3,u,v);
    else
        Fext = cat(4,u,v,w);
    end
    if normalize,
        Fmag = sqrt(sum(Fext.^2,ndims(f)+1));
        if ndims(f)==2,
            Fext = Fext./(Fmag(:,:,[1 1])+eps);
        else
            Fext = Fext./(Fmag(:,:,:,[1 1 1])+eps);
        end
    end
%% call faster c routine
else
    Fext = AM_GVF_c(single(f), mu, in, normalize);
end