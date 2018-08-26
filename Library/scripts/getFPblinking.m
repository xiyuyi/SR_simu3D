function [info, comS]=getFPblinking(tauOn, taulof, taumof, tausof, sigsof, taubst, tTotal)
% [info, comS]=getFPblinking(tauOn, taulof, taumof, tausof, sigsof, taubst, tTotal)
%   Author: Xiyu Yi
%   2018 @UCLA
%   Email: xiyu.yi@gmail.com
%
%   this function genrate the blinking period of an emitter with the input blinking parameters.

%% first generate long on-time series and make sure it sum up to reach tTotal;
  flag = 'keepGoing';
     N = floor(tTotal/taulof);%this is the expected # of long-off time at given tTotal.
while(strcmp(flag,'keepGoing'))
 xloff = rand(N,1);
TSloff = -taulof*log(1-xloff);
% then make sure the coverage time of long off time series covers the entire series; and only exceed with last time duration.
if sum(TSloff) > tTotal   
    flag='finished';   
    TStotal = reshape(TSloff(:),1,N);   
    TTtotal = cumsum(TStotal);   
          k = find(TTtotal > tTotal);   
          L = floor(min(k));   
     TSloff = TSloff(1:L);  
else
    flag='keepGoing';
end

N = N + 1;
end
%% now generate bursts time durations
bstN = length(TSloff) - 1;%total number of bursts on this trajectory.
bstT = -taubst*log(1-rand(bstN,1)); %get a bursts durations that follows exponential distribution.
info.bstN = bstN;
info.bstInfo = cell(3, bstN); %this information will store the identity of the emitter traces.
% [startTime(s), endTime(s), type(fastblinking slowblinking)]
%% now generate bursts trajectories for each burst:
bstTotal = 0;
for i0 = 1:bstN
    tbstTotal = bstT(i0); %duration of this burst
    x = rand(1);
    switch(x>0.35) % decide type of the burst
        case(1);%% the burst consist of short off time, and ontime.
        info.bstInfo(3, i0) = {'FastBlinking'};
            N = floor(tbstTotal/(tausof+tauOn)*1.5);%1.5 times the expected # of on/off phases within the burst.
            N = max(N, 1);
            flag = 1;
            while flag
                bstTSon = -tauOn*log(1-rand(N+1,1));%exponential distribution for on times, each burst show start and end with a on state

                %generate gaussian distribution for short off times. make sure the values are positive.
                flagi = 1; s = 1;
                while flagi
                    bstTSof = randn(floor(N*s),1).*sigsof + tausof;
                    bstTSof(bstTSof < 0) = [];
                    if length(bstTSof) > N
                        bstTSof = bstTSof(1 : N);
                        flagi = 0;
                    else
                        s = s + 1;
                    end
                end
                bstTStotal = sum(bstTSon) + sum(bstTSof);
                 if tbstTotal < bstTStotal; %if the total length of states exceeds the burst duration
                    flag = 0;
                        TStotal = reshape([bstTSon(:)', bstTSof(:)'], 1, 2*N + 1);   
                         TTtotal = cumsum(TStotal);   
                            k = find(TTtotal > tbstTotal);   
                            L = floor(min(k)/2);   
                         bstTSon = bstTSon(1 : L + 1);
                         bstTSof = bstTSof(1 : L);  
                 else
                     N = floor(N*1.5);
                 end
            end
            
        case(0);%% the burst will have medium off time and on time.
        info.bstInfo(3, i0) = {'SlowBlinking'};
            N = floor(tbstTotal/(taumof+tauOn)*1.5);%1.5 times the expected # of on/off phases within the burst.
            N = max(N, 1);
            flag = 1;
            while flag
                bstTSon = -tauOn*log(1-rand(N+1, 1)); % exponential distribution for on times, each burst show start and end with a on state
                bstTSof = -taumof*log(1-rand(N, 1));  % exponential distribution for medium off times.
             bstTStotal = sum(bstTSon) + sum(bstTSof);
                 if tbstTotal < bstTStotal; %if the total length of states exceeds the burst duration
                    flag = 0;
                        TStotal = reshape([bstTSon(:)', bstTSof(:)'], 1, 2*N + 1);   
                         TTtotal = cumsum(TStotal);   
                            k = find(TTtotal > tbstTotal);   
                            L = floor(min(k)/2);   
                         bstTSon = bstTSon(1 : L + 1);
                         bstTSof = bstTSon(1 : L);   
                 else
                     N = floor(N*1.5);
                 end
            end            
    end
    %Now get complex series of cumulate time seires, tau series and phase
    %for this burst.
    tauS = reshape([bstTSon(:)';[bstTSof(:)', nan]], 1, 2*L + 2); tauS(end) = [];
    phaS = reshape([ones(1, L + 1); zeros(1, L + 1)], 1, 2*L + 2); phaS(end) = []; 
    bst = [tauS; phaS];
    eval(['icomS_bst',num2str(i0),' = bst;'])
    bstTotal = bstTotal + sum(tauS);
    info.bstInfo(1, i0) = {sum(TSloff(1:i0)) + bstTotal - sum(tauS)};%Start Time of the burst
    info.bstInfo(2, i0) = {sum(TSloff(1:i0)) + bstTotal};%End Time of the burst

end

%% now construct comS for the entire trajectory.
icomS = [TSloff(1); 0];
for i1 = 1 : bstN
    icomS_next = [TSloff(i1 + 1); 0];
    eval(['icomS_bst=icomS_bst',num2str(i1),';'])
    icomS = [icomS, icomS_bst, icomS_next];
end
timS = cumsum(icomS(1, :));
comS = [timS; icomS];

return