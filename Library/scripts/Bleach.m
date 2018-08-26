function comS = Bleach(comS, t)
%   comS = Bleach(comS, t)
%   Author: Xiyu Yi
%   2018 @UCLA
%   Email: xiyu.yi@gmail.com
%
% modify the time constants and time-points of each emitter, specified by comS, so the molecule is set
% to 'bleached' state at time point t.

a1 = find(comS(1, :)>=t);
t0 = a1(1); % find out the index of the phase where this transition happens.

   if comS(3, t0) == 0;%if current phase is off.
     %merge all the rest time into this off phase
     tauRest = sum(comS(2, a1));
     comS(2, t0) = tauRest;
     comS(1, t0) = comS(1, end);
     if length(a1) > 1
     comS(:, t0+1 : end)=[];
     end
   else %if current phase is on.
     tauRest = sum(comS(2, a1(2:end)));
     comS(2, t0 + 1) = tauRest;
     comS(1, t0 + 1) = comS(1, end);
     if length(a1) > 2
     comS(:, t0 + 2 : end) = [];
     end
   end 

end