%% Script - Run blink analysis

% author:  Magdalena Schneider
% date:    16.03.2020
% version: 1.0

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Get current folder
folder = fileparts(which(mfilename)); 


%% Specify input files

% File path for blinking data
pathBlinkData = [folder,'\testdata\blinking_data'];
% File path for platform data
pathPlatformData = [folder,'\testdata\platform_data'];

% Transformation matrix for channel registration
file_corr = [folder,'\testdata\bead_data\result_affine_transform\affineCorr.mat'];
tform = load( file_corr );


%% Add current folder to path

% Add folder and subfolders to path
addpath(genpath(folder));


%% Run analysis of blinking statistics

[blink_dist,blink_data] = main_analyseBlinkStat( pathBlinkData,pathPlatformData,tform )


