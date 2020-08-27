function fnames = preprocessInput( inputFiles )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% preprocessInput

% author:  Magdalena Schneider
% date:    19.03.2020
% version: 1.0

% preprocessInput checks input and loads it into a cell array in case of
% multiple input files

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check if one or more files were selected
% Create cell with filename in case only 1 file is selected
if ~iscell(inputFiles)
    if inputFiles~=0
        fnames = {};
        fnames{1} = inputFiles;
    else % If user clicks cancel or close button, uigetfile returns NaN
        return % quit function and return NaN
    end
else
    fnames = inputFiles;
end

end