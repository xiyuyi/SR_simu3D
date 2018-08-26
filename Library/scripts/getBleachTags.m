function BleachTags = getBleachTags(Feature, MovieSpec, FPspec)
% BleachTags = getBleachTags(Feature, MovieSpec, FPspec)
% Author: Xiyu Yi
% 2018 @UCLA
% Email: xiyu.yi@gmail.com
%
%
% getBleachTags returns a Nx2 matrix BleachTags
% where the first column stores the emitter indexes. 
% The 2nd column is the frame index of the time point 
% when the corresponding emitter is bleached.

         LabN = Feature.LabelN;
       Nframe = MovieSpec.Nframe;
       Bcurve = FPspec.BleaC;

%% modify On-off series to enable bleaching.
        AcPop = floor(Bcurve.*LabN);                        % total number of active emitters as a function of time.
        BlPop = LabN - AcPop;                               % total number of bleached emitters
            X = [BlPop; [1:Nframe]];                        % total number of bleached emitters, second row to be emitter index
       Xtrans = [0, X(1, 2:end) - X(1, 1:end - 1)];         % changing indexes of total number of bleached emitters 
                                                            % (so this will be the # of emitters to be bleached at this time point)
    TransInds = find(Xtrans(1, :) > 0);                     % index where total number of bleached emitters changes.
       TransI = [1, BlPop(TransInds(1 : end - 1))] + 1;     % same size as TransInds, at transition frame index given by TransInds, 
                                                            % gives the starting index of emitters to bleach. 
       TransE = BlPop(TransInds);                           % same size as TransInds, at transition frame index given by TransInds, 
                                                            % gives the ending index of emitters to bleach. 
         Inds = sortrows([[1 : LabN]', rand(LabN, 1)], 2);  % give emitters random indexes, so the emitters are programmably bleached in random order.
         Inds = Inds(:, 1);    
   BleachTags = [[1:LabN]', ones(LabN,1).*Nframe];          % the bleaching time (second column) of each emitters indexed in first column.

   %% Now given the bleaching indexes, assing the time index for each emitter to bleach.
        for i0 = 1:length(TransInds)                        % go over all transition frames.
            frameInd = TransInds(i0);                       % get the frame index of that transition frame.
            for i1 = TransI(i0) : TransE(i0)                % go over the emitters that suppose to be bleached within this transition frame
                %% Give the bleach tag to the emitter.
                BleachTags(Inds(i1),2) = frameInd;
            end
        end
end