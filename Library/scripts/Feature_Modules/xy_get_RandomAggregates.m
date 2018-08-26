function Feature = xy_get_RandomAggregates(aggregates, Feature)
%   Feature = xy_get_RandomAggregates(aggregates, Feature)
%   Author: Xiyu Yi
%   2018 @UCLA
%   Email: xiyu.yi@gmail.com
%
% This function is a feature module that generates a labeled feature.
% it intrinsically described a simulated sample with fluorescence label
% locations.
%
% Here the virtual sample is in the form of spherical aggregates, with user defined
% properties of of generated group of aggregates as specified by the input parameters 
% as explained below: 
%         aggregates.AgN: -- The total number of aggregates to be generated
%       aggregates.Min_D: -- Minimum diameter of the aggregates (nano meters)
%       aggregates.Max_D: -- Maximum diameter of the aggregates (nano meters)
%    aggregates.singleOV: -- The average occupation volume of a single emitter located inside
%                            the aggregate. (nanometer^3). 
%                            For example when singleOV = 1000, it means 1 emitter per nm^3;
%                            which is equivalent to a volume of cube with edge length
%                            = 10 nm; or a sphere with diameter of approximately 6.2 nm.
%     Feature: -- the incomplete structural array that stores basic
%                 information fo this feature.
AgN = aggregates.AgN;
Min_D = aggregates.Min_D;
Max_D = aggregates.Max_D;
singleOV = aggregates.singleOV;

%Feature.UniLen:  Unit Length Before Binning, (nanometers), It's not the strign Link Length (Feature.StriLL).
%Feature.dimFOV:  Dimension of simulated 3D volume in unit grid.
Feature.EmiLoc = [];% prepare field for emitter locations.

% first, generate the coordiantes of the centers of each aggregate (CoAs) located within
% the region of dimFOV, as well as the diameter of each aggregate
CoAs = round(rand(AgN, 3).*(ones(AgN,1)*Feature.dimFOV)); % coordiantes of the center of aggregates, in units of UniLen.
Dias = round((rand(AgN, 1).*(Max_D-Min_D) + Min_D)/Feature.UniLen);% diameters of the aggregates, in units of UniLen;

% now go over each aggregate and generate fluorophore location coordinate
% within that aggregate.
for N = 1:AgN
    D = Dias(N); % diameter of the Nth aggregate in units of UniLen.
    C = CoAs(N,:); % coordinate of the center of this Nth aggregate in unit of UniLen.
    
    % calculate the total number of emitters located within this aggregate.
    emiN = max(round((1/6)*pi*D^3 / singleOV),1); % at least put 1 emitter there.
    
    % generate cooresponding number of random coordiantes within this spherical aggregate.
    % random elevation agles, azimuth angle, radius and coordiantes as
    % follows:
    elevation = asin(2*rand(emiN,1)-1);
    azimuth = 2*pi*rand(emiN,1);
    Rads = 0.5*D*(rand(emiN,1).^(1/3));
    [x0,y0,z0] = sph2cart(azimuth,elevation,Rads);
    % shift coordiantes with respect to the aggregate center
    x = round(x0 + C(1));
    y = round(y0 + C(2));
    z = round(z0 + C(3));
    locs = [x(:), y(:), z(:)];
    
    % expand the EmiLocs.
    Feature.EmiLoc = [Feature.EmiLoc; locs];
end
return