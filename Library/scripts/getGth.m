function im = getGth(loc,dimFOV)
%   im = getGth(loc,dimFOV)
%   Author: Xiyu Yi
%   2018 @UCLA
%   Email: xiyu.yi@gmail.com
% 
%   this is only a quick display of the ground truth emitter locations just in case if you
%   want to check it.
%   sometime some emitter outside of the field of view, can still
%   contribute photons to the FOV if they are located right outside the
%   edge of the FOV. It would be interested to check it.
%
    im = zeros(dimFOV(1),dimFOV(2));
    for i0 = 1:length(loc(:,1))
       im(loc(i0,1),loc(i0,2))=1; 
    end
    figure;imshow(im,[]);
end