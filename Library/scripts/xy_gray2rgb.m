function output = xy_gray2rgb(im, map)
%   output = xy_gray2rgb(im, map)
%   Author: Xiyu Yi
%   2018 @UCLA
%   Email: xiyu.yi@gmail.com
%   
%   this function convert a gray scale matrice into rgb figure according to
%   the inout colormap matrix 'map'.
%
im(isnan(im))= eps;
im = double(im);
im = (im - min(im(:)))./(max(im(:))-min(im(:))).*length(map(:,1));
im = round(im);
output = ind2rgb(im, map);