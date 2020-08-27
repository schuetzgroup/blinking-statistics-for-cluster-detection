function [xposColumn,yposColumn,frameColumn,locprecColumn] = getColumnIndices( columnNames )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getColumnIndices

% author:  Magdalena Schneider
% date:    19.03.2020
% version: 1.0

% getColumnIndices checks if columns with certain headers exist and returns
% respective column indices

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:length(columnNames)
    if strcmp(columnNames{i},'x_nm') || strcmp(columnNames{i},'x [nm]') || strcmp(columnNames{i},'pos_x') || strcmp(columnNames{i},'x_nm_')
        xposColumn = i;
    end
    if strcmp(columnNames{i},'y_nm') || strcmp(columnNames{i},'y [nm]') || strcmp(columnNames{i},'pos_y') || strcmp(columnNames{i},'y_nm_')
        yposColumn = i;
    end
    if strcmp(columnNames{i},'frame')
        frameColumn = i;
    end
    if strcmp(columnNames{i},'uncertainty')
        locprecColumn = i;
    end
end

if ~exist('xposColumn','var')
    error('Input data does not contain x-position of localizations!')
end
if ~exist('yposColumn','var')
    error('Input data does not contain y-position of localizations!')
end
if ~exist('frameColumn','var')
    warning('Input data does not contain framenumbers!')
    frameColumn = NaN;
end
if ~exist('locprecColumn','var')
    warning('Input data does not contain localization precision!')
    locprecColumn = NaN;
end

end

