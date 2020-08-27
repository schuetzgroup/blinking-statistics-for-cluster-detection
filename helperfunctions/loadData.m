function data = loadData( pname,fnames,analysis_startFrame )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% loadData

% author:  Magdalena Schneider
% date:    19.03.2020
% version: 1.0

% loadData loads data given in (multiple) csv-files into a data structure

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Loading files...')
numFiles = length(fnames);
for f = numFiles:-1:1 % run loop backwards to allocate full structure array on first loop
    % Keep track of path and filename
    data(f).pathname = pname;
    data(f).filename = fnames{f};
    % Load data and extract localization coordinates
    [~,~,ext]=fileparts(fnames{f});
    switch ext
        case '.csv'
            csvTable = readtable(fullfile(pname,fnames{f}));
            columnNames = csvTable.Properties.VariableNames;
            % Check if correct column names and get column indices
            [xposColumn,yposColumn,frameColumn,locprecColumn] = getColumnIndices( columnNames );
            
            % Reject first frames (pre-exposure)
            csvTable = csvTable(csvTable{:,frameColumn}>=analysis_startFrame,:);
            
            data(f).locs = table;
            % Extract localization positions
            data(f).locs.pos = [csvTable{:,xposColumn},csvTable{:,yposColumn}];
            % Extract framenumbers
            if ~isnan(frameColumn)
                data(f).locs.frame = csvTable{:,frameColumn};
            end
            % Extract localization precision
            if ~isnan(locprecColumn)
                data(f).locs.locprec = csvTable{:,locprecColumn};
            end
            
            % Get csv header
            fid = fopen(fullfile(pname,fnames{f}));
            data(f).csvheader = fgetl(fid);
            fclose(fid);
            % Extract all csv information (without header)
            data(f).csv = readtable(fullfile(pname,fnames{f}));
    end
end

end

