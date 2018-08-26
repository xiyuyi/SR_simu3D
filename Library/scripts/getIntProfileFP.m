function [IntSeries,para]=getIntProfileFP(comS, tExpo, Nframe, Slevel)
%   [IntSeries,para]=getIntProfileFP(comS, tExpo, Nframe, Slevel)
%   Author: Xiyu Yi
%   2018 @UCLA
%   Email: xiyu.yi@gmail.com
%
% this code construct the time intensity trajectory of an emitter based on
% the system parameters and emitter parameters.
%


% randomly choose the initlia phase to be either on or off; and construct time series.
% Slevel is defined interms of # of photons per s when the emitter is at pure 'on' state.
% comS = [timS; tauS; phaS]; combined series
% phase: on phase, or off phase.

PhotonBudget = Slevel*tExpo;

% define the complete insert time points of binning
timI = [tExpo : tExpo : tExpo*Nframe];  % time points of binning, 
                                        % to be inserted into the original 
                                        % time seires in comS
tauI = zeros(1, Nframe);
phaI =  ones(1, Nframe).*2; % initialize the phase index to be all = 2; 
                            % this means the phase is not set yet.
comI = [timI; tauI; phaI];  % initialize the insertion series.

% perform insertion to perform the total complete vector.
comI = sortrows([comS'; comI'])';       % first, insert the timepoint into 
                                        % the pre time series.

% modify the inserted phase and taui after insertion.
timT = comI(1, :); 
tauT = comI(2, :); 
phaT = comI(3, :);

% step1. modify phase series
% calculate the index that suppose to be on or off state.
preOn = find(phaT==1); %on state index,  before insertion.
preOf = find(phaT==0); %off state index, before insertion.
preFr = find(phaT==2); %the index of frame cut position.

% the index series above should have the same size.
L = length(preOf);
      phaT(1:preOf(1)) = 0; %initial phase is off, simulate the starting point.
      for i0=1:L-1
            phaT(preOf(i0)+1 : preOn(i0))  = 1;
            phaT(preOn(i0)+1 : preOf(i0+1))= 0;
      end
      phaT(preOf(L)+1  : end)   = 0;    

%step2. modify taui series.
tauT(2:end) = timT(2:end)-timT(1:end-1);
    tauT(1) = timT(1); 
comT = [timT; tauT; phaT];

% construct intensity ratios
IntSeries=[1, Nframe];

% starting frame:
tiOn = sum(comT(2,1:preFr(1)).*comT(3,1:preFr(1)));
tiAl = tExpo;

IntSeries(1) =  tiOn/tiAl;
% second to last frames
 for i0 = 2 : Nframe;   
  tiOn = sum(comT(2,preFr(i0-1)+1:preFr(i0)).*comT(3,preFr(i0-1)+1:preFr(i0)));
  tiAl = tExpo;
  IntSeries(i0) =  tiOn/tiAl;
 end

IntSeries = IntSeries.*PhotonBudget;
para.comT = comT;
para.comI = comI;
para.preFr = preFr;
para.preOn = preOn;
para.preOf = preOf;
end