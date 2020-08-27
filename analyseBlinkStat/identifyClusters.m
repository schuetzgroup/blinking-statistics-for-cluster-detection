function data = identifyClusters( data,clustAlgorithm,parClustAlg )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% identifyClusters

% author:  Magdalena Schneider
% date:    19.03.2020
% version: 1.0

% identifyClusters performs hierarchical clustering on the input data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n');
disp('Identifying localization clusters...')
% Loop over all files
numFiles = size(data,2);
for f=1:numFiles
    pos = data(f).locs.pos;
    % run cluster detection algorithm
    switch clustAlgorithm
        case 'clusterdata'
            par_clustering.distance = parClustAlg{1};
            par_clustering.linkage = parClustAlg{2};   % options: 'complete', 'average', 'centroid'
            par_clustering.criterion = parClustAlg{3}; % options: 'distance' or 'inconsistent'
            par_clustering.cutoff = str2double(parClustAlg{4}); % if clusters more than cutoff distance apart, they are considered to be separate clusters
            clustTree = linkage(pos,par_clustering.linkage,par_clustering.distance);
            data(f).locs.clustIDs = cluster(clustTree,'Cutoff',par_clustering.cutoff,'Criterion',par_clustering.criterion);
        otherwise
            error('No valid algorithm selected!')
    end
end
disp('Done')
end

