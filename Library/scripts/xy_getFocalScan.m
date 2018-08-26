function xy_getFocalScan(OutputName, OutputFormat, psfpath, EmiLoc, fov)
%   xy_getZoomInOut(Name, psfpath, EmiLoc, fov)
%   Author: Xiyu Yi
%   2018 @UCLA
%   Email: xiyu.yi@gmail.com
%   
%   This function produce a movie that shows the scan of focal plane of the
%   simulated system.   The output can either be tiff, or avi file.
%

    load(psfpath);                              % load the psf matrix. suppose to 
                                                % be a 3D matrix with z stack info. 
                                                % constructed from psfgenerator.
                                                % (Notice that psf matrix size
                                                % should be odd number along
                                                % each dimension, to ensure the
                                                % center peak.
   [xdim, ydim, zdim] = size(psf);
    xw = (xdim - 1)/2;                          % half x-width of psf matrix. 
    yw = (ydim - 1)/2;                          % half y-width of psf matrix.
    zw = (zdim - 1)/2;                          % half z-width of pasf matrix. 
   psf = psf./sum(sum(psf(:,:,zw+1)));          % normalize the psf to be constant hight.
   loc = EmiLoc;                        % emitter locations

   Stack3D = zeros(fov(1), fov(2), fov(3));

   % figure out the starting and ending index of the emitter stamp on the image. 
    % when we pick up the corresponding layer of psf matrix and add to the empty 
    % frame as a stamp.
    xstaS = max(loc(:,1) - xw, 1);              % starting edge on im, x dimension.
    xendS = min(loc(:,1) + xw, fov(1));         % ending edge on im, x dimension
    
    ystaS = max(loc(:,2) - yw, 1);              % starting edge on im, y dimension.
    yendS = min(loc(:,2) + yw, fov(2));         % ending edge on im, y dimension
    
    zstaS = max(loc(:,3) - zw, 1);              % starting edge on im, z dimension.
    zendS = min(loc(:,3) + zw, fov(3));         % ending edge on im, z dimension

    xsta1S = xw - (loc(:,1) - xstaS(:)) + 1;    % starting edge on PSF matrix, x dimension
    xend1S = xw + (xendS(:) - loc(:,1) )+ 1;    % ending edge on PSF matrix, x dimension
    
    ysta1S = yw - (loc(:,2) - ystaS(:)) + 1;    % starting edge on PSF matrix, y dimension
    yend1S = yw + (yendS(:) - loc(:,2) )+ 1;    % ending edge on PSF matrix, y dimension.
    
    zsta1S = zw - (loc(:,3) - zstaS(:)) + 1;    % starting edge on PSF matrix, z dimension
    zend1S = zw + (zendS(:) - loc(:,3) )+ 1;    % ending edge on PSF matrix, z dimension.
    N = length(EmiLoc(:,1));

 %% creating stack.
        for i0 = 1 : N
        disp(['construct emitter # : ',num2str(N-i0),'']);
                tp = psf(xsta1S(i0) : xend1S(i0), ...
                         ysta1S(i0) : yend1S(i0), ...
                         zsta1S(i0) : zend1S(i0));
                     
                 Stack3D(xstaS(i0):xendS(i0),ystaS(i0):yendS(i0),zstaS(i0):zendS(i0)) = ...
                 Stack3D(xstaS(i0):xendS(i0),ystaS(i0):yendS(i0),zstaS(i0):zendS(i0)) + tp.*50000; 
 
        end
        save Stack3D.mat Stack3D
%% constructing the movie output.
    if strcmp(OutputFormat, 'tif')
        for i0 = 1:fov(3)
            disp(['construct tif file, layer # : ',num2str(i0),'']);
            imbb = uint16(Stack3D(:,:,i0));  % this is simulated camera sensor capture before EM gain
            imwrite(imbb, [OutputName,'.tif'], 'WriteMode','Append');
        end
    end
    if strcmp(OutputFormat, 'avi')
        vid = VideoWriter(OutputName);
        open(vid)
        for i0 = 1:fov(3)
            disp(['construct AVI file, layer # : ',num2str(i0),'']);
            figure(1);imshow(Stack3D(:,:,i0),[]); 
            drawnow
            c=getframe;
            writeVideo(vid,c);
        end
        close(vid)
    end
end