function [blink_dist,blink_data] = main_analyseBlinkStat( pathBlinkData,pathPlatformData,tform )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% main_analyseBlinkStat

% author:  Magdalena Schneider
% date:    13.03.2020
% version: 1.2

% main_analyseBlinkStat determines the blinking statistics of a fluorescent
% label based on data input from SMLM recordings. As a precondition, the
% labeling concentration used in the experiment needs to be sufficiently
% low, so that individual fluorescent dyes can be spatially distinguished.
% The script allows for colocalizing blinks with control data from a
% platform.

% Input:    filesBlink    ... folder path to csv-files for blinking data,
%                             provided as string
%           filesPlatform ... folder path to csv-files for platform data,
%                             provided as string
%           tform         ... affine2d object storing the calculated affine
%                             transformation for channel registration
%
%           The blinking and platform data must be provided as csv-files,
%           with the first row being a header. The csv-files must contain
%           columns for the x- and y-coordinates given in nm. Corresponding
%           headers may be termed x_nm/x [nm]/pos_x or y_nm/y [nm]/pos_y,
%           respectively. Multiple files may be present for both blinking
%           and platform data. All csv-files in the specified corresponding
%           folders will be used for the analysis.
%
% Output:   blink_dist ... Matlab structure for the blinking statistics
%                          of the fluorescent label, containing the
%                          following fields:
%               -) num       ... total number of detections of an 
%                                individual fluorescent label
%               -) start     ... framenumber of first appearance of 
%                                individualfluorescent labels
%               -) ton       ... on-times (number of consecutive frames 
%                                that the fluorescent label is in its 
%                                bright state)
%               -) toff      ... off-times (number of consecutive frames 
%                                that the fluorescent label is in its dark
%                                state)
%               -) numBursts ... number of bursts of individual labels
%               -) numGaps   ... number of gaps between detection bursts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Set parameters and preparation for saving results

%--------------------------------------------------------------------------
% Analysis parameters

% Threshold for outliers
maxBlinks = 4000;

% Radius for density filter
radiusDensityFilter = 500;

% Radius for colocalization
searchRadiusColoc = 500;

% Set startframe ('prebleach': neglect all frames before startframe)
analysis_startFrame = 1;

%--------------------------------------------------------------------------
% Analysis options

% Decide if only localizations colocalized with platforms should be analyze
performColoc = true;

% Select region of interest for analysis (based on first input data set)
selectROI = true;
if selectROI
    roiShape = 'rectangle'; % options: rectangle, polygon
end

%--------------------------------------------------------------------------
% Plotting options

% For displaying and figures
parPlot.plotFigures = true; % decides if figures are plotted
parPlot.plotAll = false;    % decides if all or only exemplary figures are
                            % plotted

%--------------------------------------------------------------------------
% Saving options

% For saving blink results
parSave.save_blinkdist = true; % decides if results should be saved

% For saving figures
parSave.save_figures = true;   % decides if figures are saved

% Select path to save results
if parSave.save_blinkdist || parSave.save_figures
    % Specify folder for saving results
    [parSave.path_save]=uigetdir('','Select folder for saving results');
    
    % Input dialogue
    prompt = {'Label type:'};
    dlg_title = 'Specify analyzed label type';
    num_lines = [1,50];
    defaultans = {''};
    par_labelType = inputdlg(prompt,dlg_title,num_lines,defaultans);
    parSave.labelType = par_labelType{1}; % extract input
end


%% Add current folder to path

% Get current folder
folder = fileparts(which(mfilename)); 
% Add folder and subfolders to path
addpath(genpath(folder));


%% Select and import input data

% Compatible filetypes
ftype='*.csv';

% Select algorithm and paramters to identify localization clusters
clustAlgorithm = 'clusterdata';
parClustAlg = selectParamsClustAlgorithm( clustAlgorithm );

% Select input data
switch nargin
    case 0
        % Select files for blinking data
        disp('Please select input for blinking data!')
        [filesBlink,pathBlink]=uigetfile(ftype,'Select Blinking Data','multiselect','on');
        
        if performColoc
            % Select files for platform data
            disp('Please select input for platform data!')
            [filesPlatform, pathPlatform] = uigetfile(ftype,'Select Platform Data','multiselect','on');
            
            % Select .mat file for correction of chromatic aberration
            disp('Please select file for aberration correction!')
            [file_corr, path_corr] = uigetfile('*.mat','Select aberration correction (platform to blink data)');
            corrmat = load(fullfile(path_corr,file_corr));
        end
        
    case 1
        % Get blink data
        pathBlink = pathBlinkData;
        fileinfoBlinks = dir(fullfile(pathBlink, '*.csv'));
        filesBlink = {fileinfoBlinks.name};
        
        if performColoc
            warning('No input for platform data - analysing blinking data without colocalization analysis!')
            performColoc = false;
        end
        
    case 2
        % Set option for colocalization analysis to true
        performColoc = true;
        % Get blink data
        pathBlink = pathBlinkData;
        fileinfoBlinks = dir(fullfile(pathBlink, '*.csv'));
        filesBlink = {fileinfoBlinks.name};
        % Get Platform data
        pathPlatform = pathPlatformData;
        if ~isempty(pathPlatform)
            fileinfoPlatform = dir(fullfile(pathPlatform, '*.csv'));
            filesPlatform = {fileinfoPlatform.name};

            % Select .mat file for correction of chromatic aberration
            disp('Please select file for aberration correction!')
            [file_corr, path_corr] = uigetfile('*.mat','Select aberration correction (platform to blink data)');
            corrmat = load(fullfile(path_corr,file_corr));
        else
            performColoc = false;
            warning('Empty path for platform data! Co-localization analysis is omitted.')
        end
        
    case 3
        % Set option for colocalization analysis to true
        performColoc = true;
        % Get blink data
        pathBlink = pathBlinkData;
        fileinfoBlinks = dir(fullfile(pathBlink, '*.csv'));
        filesBlink = {fileinfoBlinks.name};
        % Get Platform data
        pathPlatform = pathPlatformData;
        if ~isempty(pathPlatform)
            fileinfoPlatform = dir(fullfile(pathPlatform, '*.csv'));
            filesPlatform = {fileinfoPlatform.name};
            
            % Get .mat file for correction of chromatic aberration
            corrmat = tform;
        else
            performColoc = false;
            warning('Empty path for platform data! Co-localization analysis is omitted.')
        end
end

% Preprocess input data
filesBlink = preprocessInput( filesBlink );
numFilesBlink = length(filesBlink);

if performColoc
    filesPlatform = preprocessInput( filesPlatform );
    numFilesPlatform = length(filesPlatform);
    if numFilesBlink ~= numFilesPlatform
        error('Number of input files for blinking data and platform data does not match!')
    end
end

% Load selected files into data-struct
fprintf('\n');
disp('Blinking data')
dataBlink = loadData( pathBlink,filesBlink,analysis_startFrame );

if performColoc
    fprintf('\n');
    disp('Platform data')
    dataPlatform = loadData( pathPlatform,filesPlatform,analysis_startFrame );
end

% Set plots
if parPlot.plotAll
    parPlot.endFile = numFilesBlink;
else
    parPlot.endFile = 1;
end


%% Platform data - registration and colocalization

if performColoc
    %% Registration of color channels
    % Correction of aberration and shift
    dataPlatform = registerChannel( dataPlatform,corrmat );
    
    % Plot registered data
    if parPlot.plotFigures
        [parPlot.xl_platform,parPlot.yl_platform] = plotInputData_platform(dataPlatform(1:parPlot.endFile));
    end
    
    %% Density filtering of platform data    
    dataPlatform = postProcessPlatform( dataPlatform,radiusDensityFilter );
    
    %% Plot input data
    if parPlot.plotFigures
        % Plot input platform data
        % Platform data only
        plotInputData_platform(dataPlatform(1:parPlot.endFile),parPlot);
        % Platform and blinking data
        plotInputData_overlap(dataBlink(1:parPlot.endFile),dataPlatform(1:parPlot.endFile));
    end
end


%% Prepare ROI
% Select desired ROI if this option is chosen in the parameters
if selectROI
    if performColoc
        [dataBlink, dataPlatform] = selectRegion( roiShape,dataBlink,dataPlatform );
    else
        [dataBlink] = selectRegion( roiShape,dataBlink,[] );
    end
end


%% Find localization clusters
% find clusters and allocate cluster IDs

dataBlink = identifyClusters( dataBlink,clustAlgorithm,parClustAlg );


%% Colocalization
if performColoc
    [dataBlink, dataPlatform, coloc_platform, coloc_blinks, coloc_platform_total, coloc_blinks_total, parPlot.xl_roi, parPlot.yl_roi]...
        = analyseColocalization( dataBlink,dataPlatform,searchRadiusColoc,parPlot,parSave );
end


%% Generate statistics

fprintf('\n');
disp('Generating blinking statistics...')

% Get blinking statistics for blinks that belong to platforms
[dataBlink,blink_dist,timetraces,timetraces_normalized,numLabels,numSkippedClusts] = getBlinkStat( dataBlink,maxBlinks );


%% Plot of clusters and skipped clusters
if parPlot.plotFigures
    for f=1:parPlot.endFile
        if ~isempty(dataBlink(f).locs)
            fig_clusts = figure('Name',dataBlink(f).filename);
            scatter(dataBlink(f).locs.pos(:,1),dataBlink(f).locs.pos(:,2),12,dataBlink(f).locs.clustIDs,'filled')
            hold on
            axis equal
            title('Localization clusters')
            xlabel('x /nm')
            ylabel('y /nm')
            if ~isempty(dataBlink(f).skippedClusts)
                skipLocs = dataBlink(f).locs.pos(any(dataBlink(f).locs.clustIDs==dataBlink(f).skippedClusts,2),1:2);
                g = plot(skipLocs(:,1),skipLocs(:,2),'r.','MarkerSize',12);
                legend(g,'Skipped clusters')
            end
            h = colorbar;
            ylabel(h,'Cluster ID')
            set(gca,'FontSize',12)
            if performColoc
                xlim(parPlot.xl_roi(f,:))
                ylim(parPlot.yl_roi(f,:))
            end
            
            % Save figures
            if parSave.save_figures
                % go to path
                cd(parSave.path_save);
                
                % save histograms for blinking statistics
                fname.fig_clusts = [parSave.labelType,'_clustering','_file',num2str(f),'.png'];
                %saveas(fig_clusts, fullfile(path_save, fname.fig_clusts), 'fig'); % as Matlab figure
                saveas(fig_clusts, fullfile(parSave.path_save, fname.fig_clusts), 'png'); % as png
            end
        end
    end
end


%% Create Plots
% Blinking statistics from all files combined
if parPlot.plotFigures && ~isempty(timetraces)
    numFrames = max(timetraces(:,1));
    [fig_hists, fig_kymo] = plotBlinkDist( blink_dist,timetraces,timetraces_normalized,numFrames );
else
    warning('Empty timetraces')
end


%% Display Infos

displayBlinkInfos( blink_dist,numSkippedClusts,numFilesBlink,numLabels );

%% Diplays warnings
if performColoc && isempty(pathPlatform)
    fprintf('\n');
    fprintf('Given path for platform data was empty! Blinking data was analyzed without prior co-localization analysis with any platform data. \n')
end

%% Display Colocalization info
if performColoc
    fprintf('\n\n');
    fprintf('Colocalization results\n')
    fprintf('\n');
    fprintf('Total percentage of colocalized blink signals: %f\n',coloc_blinks_total)
    fprintf('Total percentage of colocalized platform signals: %f\n',coloc_platform_total)
    
    if parPlot.plotFigures
        fig_boxplotColoc = figure;
        boxplot([coloc_platform,coloc_blinks],'Labels',{'Colocalized Platforms','Colocalized Blinks'})
        ylabel('Colocalization Fraction')
        title('Colocalization Analysis')
        set(gca,'FontSize',12)
        if parSave.save_figures
            fname.fig_boxplotColoc = [parSave.labelType,'_boxplotColocs.png'];
            saveas(fig_boxplotColoc, fullfile(parSave.path_save, fname.fig_boxplotColoc), 'png'); % as png
        end
    end
end


%% Get blink data
% Store all blinking data used for final analysis of blink statistics in a structure

numFiles = size(dataBlink,2);

blink_data = struct('filename',cell(numFiles,1), 'blinks',cell(numFiles,1)); % allocate
for f = 1:numFiles
    blink_data(f).filename = dataBlink(f).filename;
    blink_data(f).blinks = dataBlink(f).clusts_csv;
end


%% Save results

if parSave.save_blinkdist
    
    fprintf('\n');
    disp('Saving results...')
    
    % Save .mat file of blinking statistics
    saveBlinkDist( parSave.path_save,parSave.labelType,blink_dist )
    
    % Save .mat file of blinking data
    cd(parSave.path_save);
    blinkdata_name = [parSave.labelType,'_blinkData.mat'];
    save(blinkdata_name,'blink_data')
    
    % Save localization data used for analysis
    csvheader_tmp = dataBlink(1).csvheader;
    % Get blink data
    allData = [];
    for f = 1:numFiles
        if isequal(csvheader_tmp,dataBlink(f).csvheader)
            blinks_tmp = vertcat(dataBlink(f).clusts_csv{:});
            if ~isempty(blinks_tmp)
                allData = [allData;[repmat(f,size(blinks_tmp,1),1),blinks_tmp{:,:}]];
            end
        else
            warning('csv headers of files differ!')
        end
    end
    % Write to csv file
    csvheader = ['"file",',dataBlink(1).csvheader,',"clustID"'];
    filename = fullfile(parSave.path_save,[parSave.labelType,'_blinkData.csv']);
    % write header to file
    fid = fopen(filename,'w');
    fprintf(fid,'%s\r\n',csvheader);
    fclose(fid);
    % write data to file
    dlmwrite(filename, allData,'-append','delimiter',',');
    
    disp('Done')
end

if (parPlot.plotFigures || parPlot.plotAll) && parSave.save_figures
    fprintf('\n');
    disp('Saving figures...')
    
    saveFigures( parSave.path_save,parSave.labelType,fig_hists,fig_kymo )
    
    disp('Done')
end

end

