% This is a demonstration of the datafile that need to be generated before
% the computation to blinking trajectories, diffusing trajectories and
% generate the simulated movies.

%% Prepare 
clear all;
rng shuffle

%% specify paths and datafile and feature names.
PSFchoice = 'Cusp_psf_800_150x_1d4_14um_3Dpsf';    
    % tell the program which PSF stack to use.
    % the PSF file is pre-computed, in anyway you want, because
    % it is an independent module.
    % I this case I used PSFgenerator package to generate this PSF. 
    % In Doulbe-helix case. I just calculate the DH-PSF separately 
    % and store it in the corresponding format.

psfPath = '.';
packagePath = '.';
outputPath = '.';

featureName = 'Demo1_Random_Curves'; 
    % the program will create a file folder with this 
    % name, to store the datafile and scripts for you 
    % to generate the simulation.

% load a precomputed bleaching curve.
    load([packagePath,'/Library/datafiles/bleaching_trajectories/Syn_Bcurve2k.mat']); 
    % It is flexible to use different bleaching curves. 
    % one can calculate a bleaching curve, or use experiment calibration
    % observation. 
    cp=pwd;
    cd([packagePath,'/Library'])
    addpath(genpath(pwd));
    cd(cp)

%% specify Feature properties. [demonstration of random curves]
% Here we demonstrate an example to simulate random curves. 
Feature.UniLen = 9.333;                             % Unit Length Before Binning, (nm), It's not the strign Link Length (Feature.StriLL).
Feature.dimFOV = [1250, 1250, 101];                 % dimension of simulated 3D volume in unit grid.

% Here we intend to use a feature module that generate random curves.  
    Random_curves.type = 'random curves';
    Random_curves.UniLen = Feature.UniLen;                      % use the same unit length.
    Random_curves.StriN  = 3;                                  % total number of strings. [simulated as chains]
    Random_curves.StriLN = 2000;                                % total number of link nodes within each string.
    Random_curves.StriLL = 0.4;                                 % length of a single link in each string in unit grid.
    Random_curves.locIni = [ones(Random_curves.StriN, 1)...     % initial locations of the starting end of the curves.
                            * Feature.dimFOV(1 : 2)/2 ...
                            + (rand(Random_curves.StriN, 2)...
                            - 0.5).*300, ...
                            (Feature.dimFOV(3) + 1)/2 ...
                            + (rand(Random_curves.StriN, 1)).*10];    

    Random_curves.LabelD = 30;                                  % Labeling density (# per 1000 nm)
    Random_curves.LabelU = 7;                                   % LabelingUncertainty (nm) (standard deviation of the 
                                                                % gaussian distribution at perpendicular direction of the curves)
    Random_curves.EmiLoc = [];                                  % actual emitter location; to be assigned.
    Random_curves.siteD  = 1/Random_curves.StriLL/Feature.UniLen ...
                            *1000;                              % # availabe labeling site density per 1000 nm.
    Random_curves.LabelP = Random_curves.LabelD/Random_curves.siteD;      
                                                                % percentage of labeling site to be labeled.

    Random_curves.CurvPs = [0.0005, 2, 0.001, 0.08];           % parameters that defines the curvatures of each 
                                                                % string. non-physical parameters.
    Random_curves.LabelN = floor(...
                     Random_curves.LabelP*...
                     Random_curves.StriN*...
                     Random_curves.StriLN);                   % number of labeling site to be labeled in this feature.                                            

[Feature.locG, Feature.EmiLoc] = xy_getFeature_Random_curves(Random_curves);                                                           
Feature.featureName = featureName;

% other Feature parameters
Feature.FocalZ = 51;                                % chosen focal plane index
Feature.LabelN = Random_curves.LabelN;              % total number of labels
Feature.specifics = Random_curves;                  % pass on the parameters for record keeping purposes

%% specify movie properties
MovieSpec.tExpo  = 0.05;                            % integration time per frame.
MovieSpec.Nframe = 500;                             % total number of frames. 
MovieSpec.tTotal = MovieSpec.tExpo*MovieSpec.Nframe;% total number of movie time.
MovieSpec.Slevel = 5000;                            % signal level, # of counts per s per emitter at pure 'On' state (brightnessFactor=1;
MovieSpec.Blevel = 0.02;                            % Background level with respect to the signal leve.
BcurveConstruct = zeros(1, MovieSpec.Nframe);
BcurveConstruct(1:min(MovieSpec.Nframe, length(Bcurve))) = Bcurve(1:min(MovieSpec.Nframe, length(Bcurve)));

%% specify FP blinking statistics
FPspec.IndivAS = 'yes';
FPspec.tauOn   = 0.038.*ones(1,Feature.LabelN);     % On-time average, exponential distribution.
FPspec.tausOff = eps.*ones(1,Feature.LabelN);       % short-Off time avergage, gaussian distribution.
FPspec.sigsOff = eps.*ones(1,Feature.LabelN);       % sigma of short-Off time gaussian distribution.
FPspec.taulOff = 0.08.*ones(1,Feature.LabelN);         % long-Off time average, exponential distribution.
FPspec.taumOff = eps.*ones(1,Feature.LabelN);     % medium-Off time average, exponential distribution.
FPspec.taubst  = eps.*ones(1,Feature.LabelN);       % average burst duration, exponential distribution.
FPspec.BritD   = rand(Feature.LabelN, 1).*0.2 +0.8; % brightness distribution.
FPspec.BleaC   = BcurveConstruct;                   % bleaching curve


SysInfo.rngSeed = rng;
SysInfo.psfName = PSFchoice;
SysInfo.psfPath = psfPath;
SysInfo.blinkingSetPath = '.';
SysInfo.binN = 10;
BleachTags = getBleachTags(Feature, MovieSpec, FPspec);
    eval(['mkdir ',outputPath,'/',Feature.featureName])
    eval(['save ',outputPath,'/',Feature.featureName,'/Labeled.mat Feature FPspec MovieSpec SysInfo BleachTags'])
cd([outputPath])

%% specify computation ranges of emiter indexes and frame indexes. (this part can be individually modified for each job set.)
FrameIni = 1;
FrameEnd = MovieSpec.Nframe;
EmiRangeIni = 1;
EmiRangeEnd = Feature.LabelN;
    eval(['save ',outputPath,'/',Feature.featureName,'/FrameRange.mat FrameIni FrameEnd'])
    eval(['save ',outputPath,'/',Feature.featureName,'/EmiRangeInds.mat EmiRangeIni EmiRangeEnd'])
    copyfile([packagePath,'/Library/scripts/Main_getBlinkingOnly_EmitterRange_needBleachTags.m'],[outputPath,'/',Feature.featureName,'/Main_getBlinkingOnly_EmitterRange_needBleachTags.m'])
    copyfile([packagePath,'/Library/scripts/Main_MovieOnly_GivenFrameR_EmiR_PBursts_Opti.m'],[outputPath,'/',Feature.featureName,'/Main_MovieOnly_GivenFrameR_EmiR_PBursts_Opti.m'])
    copyfile([packagePath,'/Library/datafiles/PSFs/',PSFchoice,'.mat'],[outputPath,'/',Feature.featureName,'/', PSFchoice,'.mat']);
    cd([outputPath,'/',Feature.featureName])
clc

disp(['Now please first generate blinking trajectoreis for each'])
disp(['emitter by running the following script under this directory:'])
disp(['    Main_getBlinkingOnly_EmitterRange_needBleachTags.m'])
disp([''])
disp(['After the blinking trajectories are generated, run'])
disp(['the following script to get the simulated movie '])
disp(['signal(noise free) upon capture:'])
disp(['    Main_MovieOnly_GivenFrameR_EmiR_PBursts_Opti.m'])
disp([''])
disp(['Noise can be simulated by adding empty frames to '])
disp(['the data set, or other ways at will.'])
