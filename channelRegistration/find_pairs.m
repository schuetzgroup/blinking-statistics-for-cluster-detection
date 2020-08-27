function [pairsCh1,pairsCh2] = find_pairs(posCh1,posCh2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% find_pairs

% author:  Magdalena Schneider
% date:    16.03.2020
% version: 1.0

% find_pairs searches for localization pairs between channel 1 and
% channel 2.
%
% Input:    posCh1 ... positions of fiducial markers in channel 1
%           posCh2 ... positions of fiducial markers in channel 2
%
% Output:   pairsCh1 ... paired positions channel 1
%           pairsCh2 ... paired positions channel 2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Preparations

numCh1 = size(posCh1,1);
numCh2 = size(posCh2,1);

searchRadius = 120; % given in nm
maxShift = 4000;    % given in nm

%% Find matching pair

pairsCh1 = [];
pairsCh2 = [];
pairs_matchedPoints = [];

% Loop over list to find pairs
for p2 = 1:numCh2 % loop over all points in channel 2
    % Loop over points in channel 1
    shift = NaN(numCh1,2);
    numPaired = NaN(numCh1,1);
    for p1 = 1:numCh1
        % Calculate shift
        shift(p1,:) = posCh2(p2,:) - posCh1(p1,:);
        if vecnorm(shift(p1,:),2,2)<maxShift
            % Shift locs of channel 2 accordingly
            posCh2_shifted = posCh2 - shift(p1,:);
            
            % Search for close neighbors
            idx = rangesearch(posCh1,posCh2_shifted,searchRadius);
            numNeighbors = cellfun('size',idx,2);
            isPaired = (numNeighbors>0);
            numPaired(p1) = sum(isPaired);
        end
    end
    
    % Find bead pairs that gave max. number of matched pairs
    maxPairs = max(numPaired);
    if maxPairs == 1 || isnan(maxPairs)
        warning('No match found for this point!')
    else
        idx_points_maxPairs = find(numPaired == maxPairs);
        if size(idx_points_maxPairs,1)>1
            [~,idx_shift] = min(vecnorm(shift(idx_points_maxPairs,:),2,2));
            idx_partner = idx_points_maxPairs(idx_shift);
        else
            idx_partner = idx_points_maxPairs;
        end
        
        % Extract pair
        pairsCh1 = [pairsCh1; posCh1(idx_partner,:)];
        pairsCh2 = [pairsCh2; posCh2(p2,:)];
        pairs_matchedPoints = [pairs_matchedPoints; maxPairs];
    end 
end

thresholdMatches = floor(0.75*max(pairs_matchedPoints));
isgoodPair = pairs_matchedPoints>=thresholdMatches;

pairsCh1 = pairsCh1(isgoodPair,:);
pairsCh2 = pairsCh2(isgoodPair,:);

end
