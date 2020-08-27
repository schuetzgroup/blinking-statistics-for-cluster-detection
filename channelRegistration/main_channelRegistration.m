function tform = main_channelRegistration( filepathCh1,filepathCh2 )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% main_channelRegistration

% author:  Magdalena Schneider
% date:    22.01.2020
% version: 1.1

% main_channelRegistration calculates an affine transformation for the
% registration of two imaging channels based on localizations of fiducial
% markers detectabnle in both channels.
% The transformation registers channel 2 ('moving channel')to channel 1
% ('fixed channel').
%
% Input:  filepathCh1 ... folder path to channel 1 data, given as string
%         filepathCh2 ... folder path to channel 2 data, given as string
%
%         Data needs to be provided as csv-files with
%
% Output: tform ... affine transformation, given as affine2d object

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Preparation for saving results

% For saving
save_results = false; %true; % decides if results should be saved as file

if save_results
    % specify folder where to save results
    [path_save]=uigetdir('','Select folder for saving results');
end

%% Add current folder to path

% Get current folder
folder = fileparts(which(mfilename)); 
% Add folder and subfolders to path
addpath(genpath(folder));


%% Select Data

% Compatible filetypes
ftype='*.csv';

% Select input files
switch nargin
    case 0
        % Select files, Channel 1
        [filesCh1,pathCh1]=uigetfile(ftype,'Select localization data for channel 1','multiselect','on');
        % Select files, Channel 2
        [filesCh2, pathCh2] = uigetfile(ftype,'Select localization data for channel 2','multiselect','on');
    case 2
        % Get files, Channel 1
        pathCh1 = filepathCh1;
        fileinfoCh1 = dir(fullfile(pathCh1, '*.csv'));
        filesCh1 = {fileinfoCh1.name};
        % Get files, Channel 2
        pathCh2 = filepathCh2;
        fileinfoCh2 = dir(fullfile(pathCh2, '*.csv'));
        filesCh2 = {fileinfoCh2.name};
    otherwise
        error('Incorrect number of input arguments!')
end

% Preprocess input data
% Channel 1
filesCh1 = preprocessInput( filesCh1 );
numFilesCh1 = length(filesCh1);
% Channel 2
filesCh2 = preprocessInput( filesCh2 );
numFilesCh2 = length(filesCh2);
if numFilesCh1 ~= numFilesCh2
    error('Number of input files for channel 1 and channel 2 does not match!')
end

% Load selected files into data-struct
startframe = 1;
fprintf('\n');
disp('Channel 1')
dataCh1 = loadData( pathCh1,filesCh1,startframe );
fprintf('\n');
disp('Channel 2')
dataCh2 = loadData( pathCh2,filesCh2,startframe );

% Plot input data
figure
hold on
for f = 1:numFilesCh1
    plot(dataCh1(f).locs.pos(:,1),dataCh1(f).locs.pos(:,2),'b.')
    plot(dataCh2(f).locs.pos(:,1),dataCh2(f).locs.pos(:,2),'r.')
end
axis equal
title('Raw input')


%% Find pairs
disp('Finding pairs...')

pairsCh1 = [];
pairsCh2 = [];
for f = 1:numFilesCh1
    locsCh1 = dataCh1(f).locs;
    locsCh2 = dataCh2(f).locs;
    
    % Check if frame numbers exist
    if ismember('frame', locsCh1.Properties.VariableNames) && ismember('frame', locsCh2.Properties.VariableNames)
        % Analyze for each frame individually
        maxFrameNum = max(max(locsCh1.frame),max(locsCh2.frame));
        for k = 1:maxFrameNum
            % Find pairs
            locsCh1_frame_tmp = locsCh1(locsCh1.frame == k,:);
            locsCh2_frame_tmp = locsCh2(locsCh2.frame == k,:);
            
            if ~isempty(locsCh1_frame_tmp) && ~isempty(locsCh2_frame_tmp)
                [matchCh1,matchCh2] = find_pairs( locsCh1_frame_tmp.pos,locsCh2_frame_tmp.pos );
                
                pairsCh1 = [pairsCh1; matchCh1];
                pairsCh2 = [pairsCh2; matchCh2];
            end
        end
    else
        % Analyze without frame numbers, assuming same frame for all localizations
        % Find pairs
        if ~isempty(locsCh1) && ~isempty(locsCh2)
            [matchCh1,matchCh2] = find_pairs( locsCh1.pos,locsCh2.pos );
            
            pairsCh1 = [pairsCh1; matchCh1];
            pairsCh2 = [pairsCh2; matchCh2];
        end
    end
end

if ~isempty(pairsCh1) && ~isempty(pairsCh2)
    % Plot paired data
    figure
    hold on
    plot(pairsCh1(:,1),pairsCh1(:,2),'b.')
    plot(pairsCh2(:,1),pairsCh2(:,2),'r.')
    title('Uncorrected Pairs')
    
    % Calculate transformation
    transformType = 'affine';
    tform = fitgeotrans(pairsCh2,pairsCh1,transformType); % ch2 = moving, ch1 = fixed
    
    disp(tform)
    
    pairsCh2_corr = NaN(size(pairsCh2));
    [pairsCh2_corr(:,1),pairsCh2_corr(:,2)] = transformPointsForward(tform,pairsCh2(:,1),pairsCh2(:,2));
    
    figure
    hold on
    plot(pairsCh1(:,1),pairsCh1(:,2),'b.')
    plot(pairsCh2_corr(:,1),pairsCh2_corr(:,2),'ro')
    title('Corrected')
    
    %% Residual errors
    
    resErr = vecnorm(pairsCh1-pairsCh2_corr,2,2);
    figure
    histogram(resErr)
    xlabel('nm')
    title('Residual error')
    
    disp(mean(resErr))
    
    figure
    hold on
    scatter(pairsCh1(:,1),pairsCh1(:,2),[],resErr,'filled')
    scatter(pairsCh2_corr(:,1),pairsCh2_corr(:,2),[],resErr,'filled')
    title('Corrected')
    h = colorbar;
    ylabel(h, 'Resiudal error','FontSize',12)
    
    
    %% Save Transformation Object
    if save_results
        save('affineCorr.mat','tform')
    end
else
    warning('No pairs could be found!')
end