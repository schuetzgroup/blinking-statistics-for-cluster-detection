function saveBlinkDist( path_save,labelType,blink_dist )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% saveBlinkDist

% author:  Magdalena Schneider
% date:    19.03.2020
% version: 1.0

% saveBlinkDist saves the blinking statistics in the specified path

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Go to path
cd(path_save);

% Save blinking statistics
blinkdist_name = [labelType,'_blinkDist.mat'];
save(blinkdist_name,'blink_dist')

end

