%   Author: Xiyu Yi
%   2018 @UCLA
%   Email: xiyu.yi@gmail.com
%
%   this script calculate all the blinking trajectoreis of every emitter.

clear all; close all
load Labeled.mat
rng shuffle
load EmiRangeInds.mat
%% should change this code from SOFI-3D to make it more efficient
      EmiLocs = Feature.EmiLoc;
         LabN = Feature.LabelN;
       
        tExpo = MovieSpec.tExpo;
       Nframe = MovieSpec.Nframe;
       tTotal = MovieSpec.tTotal;
       Slevel = MovieSpec.Slevel;
       Blevel = MovieSpec.Blevel;
       
        tauOn = FPspec.tauOn;
      gausOff = FPspec.tausOff;
      sigsOff = FPspec.sigsOff;
      taulOff = FPspec.taulOff;
      taumOff = FPspec.taumOff;
       taubst = FPspec.taubst;
       Bcurve = FPspec.BleaC;
        BritD = FPspec.BritD;
            
mkdir BlinkingSet_Bleach

%% calculate initial on-off series       
for i0 = EmiRangeIni : EmiRangeEnd
    disp(['calculate ',num2str(i0),'/',num2str(LabN),' on-off series and Intensity Trjectories']);
    if strcmp(FPspec.IndivAS,'yes')
        [info, comS]=getFPblinking(FPspec.tauOn(i0), FPspec.taulOff(i0), FPspec.taumOff(i0), FPspec.tausOff(i0), FPspec.sigsOff(i0), FPspec.taubst(i0), tTotal);
    else
        [info, comS]=getFPblinking(FPspec.tauOn, FPspec.taulOff, FPspec.taumOff, FPspec.tausOff, FPspec.sigsOff, FPspec.taubst, tTotal);
    end
        comS = Bleach(comS,tExpo*(BleachTags(i0,2)-1));     % bleach this emitter but dut it's blinking trajectories.
        eval(['info',num2str(i0),'=info;'])
        eval(['comS',num2str(i0),'=comS;'])
        [IntSeries,para] = getIntProfileFP(comS, tExpo, Nframe, Slevel*BritD(i0));
        eval(['IntSeries',num2str(i0),'=IntSeries;'])
        eval(['para',num2str(i0),'=para;'])
        save(['./BlinkingSet_Bleach/IntSeries',num2str(i0),'.mat'],['IntSeries',num2str(i0)],['para',num2str(i0)],['info',num2str(i0)],['comS',num2str(i0)]);
        eval(['clear IntSeries',num2str(i0),' para',num2str(i0),' info',num2str(i0),' comS',num2str(i0)])
end

%% Now Ready to ConstructMovie (without SNR, noise, background, only blinking with intensity ratios)
