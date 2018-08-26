function output = binPixel(P, N)
% output = binPixel(P, N)
%   Author: Xiyu Yi
%   2018 @UCLA
%   Email: xiyu.yi@gmail.com
%
% this script takes a N x N binning of matrix P. 
%
% Note: P is a 2D matrix
%       The dimension of P should be of integer times of N.
%
% Example:
% A = ones(50,50);
% binPixel(A, 10)
%
% ans =
% 
%    100   100   100   100   100
%    100   100   100   100   100
%    100   100   100   100   100
%    100   100   100   100   100
%    100   100   100   100   100
%
% Email:  xiyu.yi@gmail.com
if N == 1
    output = P;
else
[x, y] = size(P);
a1 = reshape(P, x*N, y/N);

a2 = reshape(a1, x, N, y/N);
a3 = sum(a2, 2);
a4 = reshape(a3, x, y/N);

[x, y] = size(a4');
a1 = reshape(a4', x*N, y/N);
a2 = reshape(a1, x, N, y/N);
a3 = sum(a2, 2);
a4 = reshape(a3, x, y/N);

output = a4';
end
return