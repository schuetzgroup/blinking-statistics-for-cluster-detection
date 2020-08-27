function data = registerChannel( data,corrMat )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% registerChannel

% author:  Magdalena Schneider
% date:    19.03.2020
% version: 1.0

% registerChannel transforms data using the transformation given by corrMat
%
% Input:  data    ... localization data, given as struct with the field
%                     data.locs.pos containing xy-coordinates
%         corrMat ... transformation, given as affine2d transformation
%                     object
% Output: data    ... registered localization data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n');
disp('Channel registration...')
numFiles = length(data);

% Correct Data
for f = 1:numFiles
    
    % Transformation
    [u,v] = transformPointsForward(corrMat.tform,data(f).locs.pos(:,1),data(f).locs.pos(:,2));
    
    % Save corrected locs
    data(f).locs.pos(:,1) = u;
    data(f).locs.pos(:,2) = v;
end

disp('Done')

end

