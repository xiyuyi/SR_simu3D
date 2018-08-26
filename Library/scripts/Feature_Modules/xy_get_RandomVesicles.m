function Feature = xy_get_RandomVesicles(vesicles, Feature)
%   Feature = xy_get_RandomAggregates(aggregates, Feature)
%   Author: Xiyu Yi
%   2018 @UCLA
%   Email: xiyu.yi@gmail.com
%
% This function is a feature module that generates a labeled feature.
% It intrinsically described a simulated sample with fluorescence label
% locations.
%
% Here the virtual sample is in the form of spherical vesicles, with user defined
% properties of of generated group of vesicles as specified by the input parameters 
% as explained below: 
%         vesicles.AgN: -- The total number of aggregates to be generated
%       vesicles.Min_D: -- Minimum diameter of the aggregates (nano meters)
%       vesicles.Max_D: -- Maximum diameter of the aggregates (nano meters)
%    vesicles.singleOA: -- The average occupation area of a single emitter 
%                          lodated at the surface of the vesicles. (nanometer^2). 
%                          For example when singleOA = 100, it means 1 emitter per 100 nm^2;
%                          which is equivalent to a square shape area with edge length
%                          = 10 nm; or a circle with diameter of approximately 4 nm.
%     Feature: -- the incomplete structural array that stores basic
%                 information fo this feature.
AgN = vesicles.AgN;
Min_D = vesicles.Min_D;
Max_D = vesicles.Max_D;
singleOV = vesicles.singleOA;

%Feature.UniLen:  Unit Length Before Binning, (nanometers), It's not the strign Link Length (Feature.StriLL).
%Feature.dimFOV:  Dimension of simulated 3D volume in unit grid.
Feature.EmiLoc = [];% prepare field for emitter locations.

% first, generate the coordiantes of the centers of each vesicle (CoAs) located within
% the region of dimFOV, as well as the diameter of each vesicle
CoAs = round(rand(AgN, 3).*(ones(AgN,1)*Feature.dimFOV)); % coordiantes of the center of vesicless, in units of UniLen.
Dias = round((rand(AgN, 1).*(Max_D-Min_D) + Min_D)/Feature.UniLen);% diameters of the vesicless, in units of UniLen;

% now go over each vesicle and generate fluorophore location coordinate
% within that vesicle.
for N = 1:AgN
    D = Dias(N); % diameter of the Nth vesicle in units of UniLen.
    C = CoAs(N,:); % coordinate of the center of this Nth vesicle in unit of UniLen.
    
    % calculate the total number of emitters located at the surface of this vesicle.
    emiN = max(round((1/6)*pi*D^3 / singleOV),1); % at least put 1 emitter there.
    
    % generate cooresponding number of random coordiantes within this spherical vesicle.
    % random elevation agles, azimuth angle, radius and coordiantes as
    % follows:
    elevation = asin(2*rand(emiN,1)-1);
    azimuth = 2*pi*rand(emiN,1);
    Rads = 0.5*D;
    [x0,y0,z0] = sph2cart(azimuth,elevation,Rads);
    % shift coordiantes with respect to the vesicle center
    x = round(x0 + C(1));
    y = round(y0 + C(2));
    z = round(z0 + C(3));
    locs = [x(:), y(:), z(:)];
    
    % expand the EmiLocs.
    Feature.EmiLoc = [Feature.EmiLoc; locs];
end
return