function [locG, EmiLoc] = xy_getFeature_Random_curves(Random_curves)
%   [locG, EmiLoc] = xy_getFeature_Random_curves(Random_curves)
%   Author: Xiyu Yi
%   2018 @UCLA
%   Email: xiyu.yi@gmail.com
%   
%   this function randomly generate a collection of curves specified in the
%   Random_curves parameter. and generate the labeled feature as well.
%
%   The returned locG represents the ground truth of the feature before
%   labeling process.

%   The returned EmiLoc represents the 3D location coordiantes of all the
%   emitters that are delivered to the feature of interest as fluorescence labeles.
%
% calculate Ground truth strings(filaments, random curves)
loc = zeros(Random_curves.StriN*Random_curves.StriLN, 3); % total number of locations that can be labeled. (available labeling sites)
for i0 = 1 : Random_curves.StriN  
    disp(['generating ', num2str(i0), '/', num2str(Random_curves.StriN), ' strings(filaments)'])
    locs = getACurve3D(Random_curves) + ones(Random_curves.StriLN, 1)*Random_curves.locIni(i0, :);
    loc((i0-1)*Random_curves.StriLN + 1 : i0*Random_curves.StriLN, : ) = floor(locs) + 1;
end

% randomly select labeling site, and labeled emitter locations(inlcuding labeling uncertainty).
locG = loc;
locwInds = sortrows([loc,rand(Random_curves.StriN*Random_curves.StriLN, 1)], 4);% put random indexes for all the available labeling site.
loc = locwInds(1:Random_curves.LabelN, :);% so these are targeted labeling sites.
loc(:, 1:3) = loc(:, 1:3) + Random_curves.LabelU/Random_curves.UniLen.*randn(Random_curves.LabelN, 3); % so this is the actual emitter locations, including labeling uncertainty.
EmiLoc = floor(loc) + 1;


