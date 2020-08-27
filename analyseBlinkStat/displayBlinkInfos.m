function displayBlinkInfos( blink_dist,numSkippedClusts,numFiles,numLabels )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% displayBlinkInfos

% author:  Magdalena Schneider
% date:    19.03.2020
% version: 1.0

% displayBlinkInfos displays blinking statistics information

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n');
fprintf('\n');
fprintf('Overview of blinking analysis results\n')
fprintf('\n');
fprintf('Minimum number of localizations from one label: %i\n',min(blink_dist.num))
fprintf('Maximum number of localizations from one label: %i\n',max(blink_dist.num))

fprintf('\n');
fprintf('First startframe: %i\n',min(blink_dist.start))
fprintf('Last startframe: %i\n',max(blink_dist.start))

fprintf('\n');
fprintf('Shortes on-time: %i\n',min(blink_dist.ton))
fprintf('Longest on-time: %i\n',max(blink_dist.ton))

fprintf('\n');
fprintf('Shortes off-time: %i\n',min(blink_dist.toff))
fprintf('Longest off-time: %i\n',max(blink_dist.toff))

fprintf('\n');
fprintf('Total number of analyzed clusters: %i\n',sum(numLabels(:)));

end

