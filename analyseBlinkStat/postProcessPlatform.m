function data = postProcessPlatform( data,minDistNeighbor )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% postProcessPlatform

% author:  Magdalena Schneider
% date:    19.03.2020
% version: 1.0

% postProcessPlatform performs density filter on platform data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n');
disp('Post processing of platform data (density filter)...')
numFiles = size(data,2);

% Correct Data
for f = 1:numFiles
    
    locs_tmp = data(f).locs.pos;
    
    % search for neighbors within range
    idx = rangesearch(locs_tmp,locs_tmp,minDistNeighbor);
    % exclude points with close neighbors
    numNeighbors = cellfun('size',idx,2)-1; % (counts itself as close!)
    
    % save corrected locs
    data(f).locs = data(f).locs(numNeighbors==0,:); % keep only points that have only itself as neighbor (0 other neighbors)
    
    if isempty(data(f).locs)
        warning('No platform points left after density filtering!')
    end
end
disp('Done')
end

