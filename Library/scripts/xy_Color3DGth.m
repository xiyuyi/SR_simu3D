

function [output, Cbar] = xy_Color3DGth(EmiLocs, Xdim, Ydim, BinN, DensTone, focalZ, Ticks, ColorRange)
%   [output, Cbar] = xy_Color3DGth(EmiLocs, Xdim, Ydim, BinN, DensTone, focalZ, Ticks, ColorRange)
%   Author: Xiyu Yi
%   2018 @UCLA
%   Email: xiyu.yi@gmail.com
%
% This function generate an RGB image matrix to represent the ground truth locations of the emitters as in puts.
% the generated RGB iamge matrix is in 2D, where the depth information of the emitter locations are colorcoded.
%
% colorbar is generated at the same time as Cbar, which is also in the form of an RGB image matrix.
%
% A few notes about the rendering process:
%    The colormap doesn't contain gray scale. And the gray scale only indicates the density.
%    If multiple emitters are closely located in an area from different hight, 
%    the RGB value will be averaged to display in that pixel, exhibit some degree of color mixing in the final RGB display.
%
%    EmiLocs:   -- Nx3 matrix, stores the emitter location index in the 3D volume
% Xdim, Ydim:   -- The range of the first and second dimension of image matrix in the groundtruth
%       BinN:   -- Binning factor.
%   DensTone:   -- 0 or 1, an option to choose whether the output image will have
%               emitter density information encoded as the intensity of each other.
%     focalZ:   -- The focal plane index in Z dimension.
%      Ticks:   -- The position in terms of Z indexes to display ticks on the
%               colorbar.
%     output:   -- A 3D RGB value image with the hight information encoded in color.
%       Cbar:   -- The colorbar of the "output" image, where the focal plane position
%               will be indicated by a black triangle arrow and a dashed line in the
%               color bar.
% ColorRange:   -- The dynamic range of Z information to be displayed. default:
%               full range.


% first take out all the emitters that are outside of the field of view
    EmiLocs(EmiLocs(:,1)>Xdim,:) = [];
    EmiLocs(EmiLocs(:,2)>Ydim,:) = [];
    EmiLocs(EmiLocs(:,1)<1,:) = [];
    EmiLocs(EmiLocs(:,2)<1,:) = [];
    if isnan(focalZ)
    Ticks = Ticks(:);
    else
    Ticks = [Ticks(:); focalZ];
    end
    Ticks(Ticks>max(EmiLocs(:,3))) = [];
    Ticks(Ticks<min(EmiLocs(:,3))) = [];
    
    colormap('hsv');
    map = colormap;
    map = imresize(map(1:40,:), [256,3]);
    m = zeros(Xdim, Ydim);
    d = zeros(Xdim, Ydim);
    N = length(EmiLocs(:,1));
    for i0 = 1:N
        x = EmiLocs(i0, 1);
        y = EmiLocs(i0, 2);
        z = EmiLocs(i0, 3);
        m(x, y) = m(x, y) + z; % this matrix encodes the color information of the emitters.
        d(x, y) = d(x, y) + 1; % this matrix encodes the # of emitters at each location.
    end
    m0 = m;
    m = binPixel(m, BinN); % now bin the matrix
    d = binPixel(d, BinN); % now bin the matrix
    
    m = m./d;
    m(isinf(m)) = 0;
    m(isnan(m)) = 0;
    if isempty(ColorRange)
        lb = min(EmiLocs(:,3));
        ub = max(EmiLocs(:,3));
    else
        lb = min(ColorRange);
        ub = max(ColorRange);
    end
    Tags = find(m>0);
    if lb == ub
        m(Tags) = ceil(m(Tags)./ub.*256); % set everything to the index in the map representing the maximum value
        focalZInd = ceil(focalZ./ub.*256);
        TicksInds = ceil((Ticks)./(ub).*256);
        k = reshape([m, m, m],[Xdim/BinN, Ydim/BinN, 3]);        
    else
        m(Tags) = ceil((m(Tags) - lb )./(ub - lb).*255)+1; % now m will be the index in the map;
        focalZInd = ceil((focalZ - lb)./(ub - lb).*255)+1;
        TicksInds = ceil((Ticks - lb)./(ub - lb).*255)+1;
        k = zeros(Xdim/BinN, Ydim/BinN, 3);
        for i0 = 1 : Xdim/BinN
            for i1 = 1 : Ydim/BinN
                if m(i0,i1) == 0
                    k(i0, i1, :) = zeros(1,1,3);
                else
                    Ind = max(min(m(i0,i1),256),1);
                    k(i0, i1, :) = reshape(map(Ind,:), [1,1,3]);
                end
            end
        end            
    end
    if DensTone
        d = d ./max(d(:)); 
        output = k.*reshape([d,d,d],[Xdim/BinN,Ydim/BinN,3]);
        
    else
        output = k;
    end
    % Now Make the colorbar.
    CbarX = zeros(256,1,3);    
    for i0 = 1:256
        CbarX(i0,1,:) = reshape(map(i0,:), [1,1,3]);
    end
    if DensTone
        CbarY = [29:-1:0]./29; 
    else
        CbarY = ones(1,15);
    end
    CbarR = CbarX(:,1,1)*CbarY;
    CbarG = CbarX(:,1,2)*CbarY;
    CbarB = CbarX(:,1,3)*CbarY;
    Cbar = reshape([CbarR,CbarG,CbarB],[256,length(CbarY),3]);
    
    % Now Mark the focal plane position in the colorbar for the color coding of z-depth
    dashInds = [1:30]; dashInds(4:3:30)=[];
    dashInds(dashInds>length(CbarY)) = [];
    tp = ones(size(CbarY));
    tp(dashInds) = tp(dashInds) - CbarY(dashInds);

    CbarTicks = ones(256, 6, 3).*256;
    CbarTicks(:, 2:3, :) = 0;
    TicksInds(TicksInds < 1) = [];
    TicksInds(TicksInds > 256) = [];
    for i0 = 1:length(TicksInds)
        CbarTicks(TicksInds(i0), [3:end], :)=0;
    end
        % add a dashed line inside the color bar.
    if isnan(focalZInd)
    Cbar = [Cbar, CbarTicks];
    else
        if DensTone
            Cbar(focalZInd,dashInds,:) = 1;    
        else
            dashBar = reshape([tp,tp,tp],[1,length(CbarY),3]);
            Cbar(focalZInd,dashInds,1) = dashBar(dashInds);
            Cbar(focalZInd,dashInds,2) = dashBar(dashInds);
            Cbar(focalZInd,dashInds,3) = dashBar(dashInds);
        end
        CbarArrow = ones(256, 10, 3).*256;
        CbarArrow(focalZInd,    1 : 2, :) = 0;
        CbarArrow(focalZInd + [-1 : 1], 3 : 4, :)  = 0;
        CbarArrow(focalZInd + [-2 : 2], 5 : 6, :)  = 0;
        CbarArrow(focalZInd + [-3 : 3], 7 : 8, :)  = 0;
        CbarArrow(focalZInd + [-4 : 4], 9, :) = 0;
        Cbar = [Cbar, CbarTicks, CbarArrow];
    end
end