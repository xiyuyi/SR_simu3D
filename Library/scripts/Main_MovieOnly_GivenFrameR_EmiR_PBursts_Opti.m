%   Author: Xiyu Yi
%   2018 @UCLA
%   Email: xiyu.yi@gmail.com
%
%   this script generate the TIFF movie according to pre-computed
%   simulation specifics.
clear all
close all
load Labeled.mat
load FrameRange.mat FrameIni FrameEnd
load EmiRangeInds.mat EmiRangeIni EmiRangeEnd
rng shuffle
%% Now ConstructMovie 
%      without SNR, noise, background...
%      only blinking with intensity ratios)
load([SysInfo.psfPath,'/',SysInfo.psfName])                       % load the psf matrix. suppose to 
                                                % be a 3D matrix with z stack info. 
                                                % constructed from psfgenerator.
                                                % (Notice that psf matrix size
                                                % should be odd number along
                                                % each dimension, to ensure the
                                                % center peak.
   fov = Feature.dimFOV; [xdim, ydim, zdim] = size(psf);
    xw = (xdim - 1)/2;                          % half x-width of psf matrix. 
    yw = (ydim - 1)/2;                          % half y-width of psf matrix.
    zw = (zdim - 1)/2;                          % half z-width of pasf matrix. 
   psf = psf./sum(sum(psf(:,:,zw+1)));          % normalize the psf to be constant hight.
  LabN = Feature.LabelN;                        % total number of lables (emitters)
   loc = Feature.EmiLoc;                        % emitter locations
 % flatten psf
cdfM = zeros(xdim*ydim,zdim);
for i0 = 1:zdim;
    pdf = psf(:,:,i0)./sum(sum(psf(:,:,i0))); % psf here has to be normalized (total probability == 1)
    cdfM(:,i0) = cumsum(pdf(:));
end
im = uint16(zeros(fov(1), fov(2)));
ind = 1:xdim*ydim';
fovx = fov(1);
fovy = fov(2);
for zChosen = Feature.FocalZ
    % figure out the starting and ending index of the emitter stamp on the image. 
    % when we pick up the corresponding layer of psf matrix and add to the empty 
    % frame as a stamp.
    xstaS = max(loc(:,1) - xw, 1);              % starting edge on im, x dimension.
    xendS = min(loc(:,1) + xw, fov(1));         % ending edge on im, x dimension
    
    ystaS = max(loc(:,2) - yw, 1);              % starting edge on im, y dimension.
    yendS = min(loc(:,2) + yw, fov(2));         % ending edge on im, y dimension
    
    xsta1S = xw - (loc(:,1) - xstaS(:)) + 1;    % starting edge on PSF matrix, x dimension
    xend1S = xw + (xendS(:) - loc(:,1) )+ 1;    % ending edge on PSF matrix, x dimension
    
    ysta1S = yw - (loc(:,2) - ystaS(:)) + 1;    % starting edge on PSF matrix, y dimension
    yend1S = yw + (yendS(:) - loc(:,2) )+ 1;    % ending edge on PSF matrix, y dimension.
    
    zInds = zw + zChosen - loc(:,3) + 1;        % z index on PSF matrix to extract 
                                                % for each emitter location.
    dataFileName = ['BlinkingSetZ',num2str(zChosen),'_bleached_frame',num2str(FrameIni),'to',num2str(FrameEnd),'_Emi',num2str(EmiRangeIni),'to',num2str(EmiRangeEnd),'.tif'];
                                                % construct the name of the
                                                % output tif datafile.
    delete(dataFileName)
    disp(['loading all trajectories'])
    for i0 = EmiRangeIni : EmiRangeEnd
        load([SysInfo.blinkingSetPath,'/BlinkingSet_Bleach/IntSeries',num2str(i0),'.mat'],['IntSeries',num2str(i0)]);
    end
    J = zeros(fov(1),fov(2), FrameEnd - FrameIni + 1,'uint16');
    for i0 = EmiRangeIni : EmiRangeEnd
        z = zInds(i0);
        if z <= 2*zw + 1 && z > 0
        disp(['construct signal of Emitter ',num2str(i0),'/',num2str(EmiRangeEnd),', for ',dataFileName,'  ']);
        eval(['IntSeries = IntSeries',num2str(i0),';'])
        for i1 = FrameIni:FrameEnd 
                I = ceil(IntSeries(i1));
                if I>0
                r = rand(I, 1);
                ii = interp1(cdfM(:,zInds(i0)),ind,r);
                ii = ceil(ii);
                indx = floor((ii-0.5)./xdim)+1 + loc(i0,1) - xw -1;
                indy = rem(ii-1,xdim)+1 + loc(i0,2) - yw -1;
                inds = [indx, indy];
                inds(inds(:,1)<1,:)=[];
                inds(inds(:,2)<1,:)=[];
                
                inds(inds(:,1)>fovx,:)=[];
                inds(inds(:,2)>fovy,:)=[];
                
                inds(isnan(inds(:,1)),:)=[];
                inds(isnan(inds(:,2)),:)=[];
                
                if ~isempty(inds)
                L = length(inds(:,1));
                for i2 = 1:L
                    ix = inds(i2,1); iy = inds(i2,2);
                    J(ix, iy, i1) = J(ix, iy, i1)  + 1;
                end
                end
                end
        end
                
        end  
    end
    for i0 = FrameIni:FrameEnd
        im = J(:,:,i0);
    imbb = uint16(binPixel(im, SysInfo.binN));  % this is simulated camera sensor capture before EM gain
    imwrite(imbb, dataFileName, 'WriteMode','Append');
    disp(['write TIFF stack, frame ',num2str(i0),'/',num2str(FrameEnd)])
    end
end