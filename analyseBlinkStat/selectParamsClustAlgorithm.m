function parClustAlg = selectParamsClustAlgorithm( clustAlgorithm )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% selectParamsClustAlgorithm

% author:  Magdalena Schneider
% date:    19.03.2020
% version: 1.0

% selectParamsClustAlgorithm lets the user specify input for hierarchical
% clustering parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch clustAlgorithm
    case 'clusterdata'
        % Input dialogue
        % Default clustering: euclidean, average, distance
        prompt = {'Distance metric:','Linkage criterion:','Criterion for defining clusters:','Cutoff:'};
        dlg_title = 'Parameters for hierarchical clustering';
        num_lines = [1,50];
        defaultans = {'euclidean','average','distance','200'};
        parClustAlg = inputdlg(prompt,dlg_title,num_lines,defaultans); % gives back cell array
    otherwise
        error('No valid algorithm selected!')
end

end

