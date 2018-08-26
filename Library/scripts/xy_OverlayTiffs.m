function J = xy_OverlayTiffs(mvlength, xdim, ydim, fnameList, outputName)
%   J = xy_OverlayTiffs(mvlength, xdim, ydim, fnameList, outputName)
%   Author: Xiyu Yi
%   2018 @UCLA
%   Email: xiyu.yi@gmail.com
%   
%   this function add all the tiff files from fnameList (as a cell list)..
%   produce the summation tif movie. (each frame is the sum of the corresponding frames from the list)
%
delete(outputName);
N = length(fnameList);
for i1 = 1:mvlength
    im = uint16(zeros(xdim, ydim));
    for i0 = 1:N
        f = fnameList{i0};
        disp(['reading frame ',num2str(i1),'/',num2str(mvlength), ' of file ',num2str(i0),'/',num2str(N)])
        im = im + imread(f, 'Index', i1);
    end
    disp(['writing frame ',num2str(i1),'/',num2str(mvlength)])
    imwrite(im, outputName, 'writemode','append')
end
end