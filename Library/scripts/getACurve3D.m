function loc = getACurve3D(Feature)
%   loc = getACurve3D(Feature)
%   Author: Xiyu Yi
%   2018 @UCLA
%   Email: xiyu.yi@gmail.com

% the simulated curve will resemble a rigit chain, that maps a semi random
% walking trace of steps.
L = Feature.StriLN; 
r0 = Feature.StriLL;
P1 = Feature.CurvPs(1);
P2 = Feature.CurvPs(2);
P3 = Feature.CurvPs(3);
P4 = Feature.CurvPs(4);

% 
% L is the total number of junction point on the rigid chain. 
% r0 is the distance between adjacent junction points on the chain, interms of unit length (3D).
% P1 Average tilt angle per link(degree) for theta. (more directional preference, give over all long scale curvature)
% P2 Average second tilt angle per link(degree)for theta. (less directional preference, give small local regional curvature)
% P3 Average tilt angle per link(degree)for phi. (more directional preference, give over all long scale curvature)
% P4 Average second tilt angle per link(degree)for phi. (less directional preference, give small local regional curvature)

    % randomly compute a length of the starting piece of chain. 
    rr = rand(1);% Then choose a random direction of the starting piece of the chain.
    b(1, :) = [0, 0, 0];
    % the ending point of the starting chain will thus be destributed along
    % a circle.
    phib = pi/2; % put a random purterbation to the initial angle in z.
    thetab = rr.*2.*pi+pi/2+2*(rand(1)-0.5).*pi/180*20; % put a random purterbation to the initial angle.
    curC = 0;% initial angle list in z. (difference of the angle between two displacement vectors corresponding to consecutive steps)
    cur = 0;% set back to initial value of the orientation of the first chain.
    for i0=2:L;% loop over all the linkers on the curve, one by one.
        cur = cur + (rand(1)-0.49)*2*pi/180*P1;% tilt the angle a little for thete
        curC = curC + (rand(1)-0.49)*2*pi/180*P3;% tilt the angle a little, for phi.
        
        theta = (rand(1)-0.501)*2.*pi/180*P2+cur;% now tilt the angle further by a little(theta).
        phi = (rand(1)-0.5001)*2.*pi/180*P4+curC;% now tilt the angle further by a little(phi).
               
        thetab=theta+thetab;
        phib = phi + phib;
        
        % now calculate step displacement vector based on thetab and phib
        dr = r0.*[sin(phib)*sin(thetab),sin(phib)*cos(thetab),cos(phib)];
        b(i0,:) = b(i0-1,:) + dr;
    end
    % give half-half probability for a mirrow flip about line of x=y 
    if rand(1)>0.5; loc=b; else loc=b*[0,1,0;1,0,0;0,0,1]; end
    
    %place linklength constraints on the curve.
%     for i1 = 2:L
%       d = (loc(i1-1, :) - loc(i1, :)).*(1 - r0/norm(loc(i1-1, :) - loc(i1, :)));
%       loc(i1, :) = loc(i1, :) + d;
%     end
return 
