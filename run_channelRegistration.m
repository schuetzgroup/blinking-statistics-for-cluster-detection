%% Script - Run channel registration

% author:  Magdalena Schneider
% date:    12.03.2020
% version: 1.0

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Specify input files

% File path for channel 1
filepathCh1 = 'testdata\bead_data\channel1';
% File path for channel 2
filepathCh2 = 'testdata\bead_data\channel2';


%% Add current folder to path

% Get current folder
folder = fileparts(which(mfilename)); 
% Add folder and subfolders to path
addpath(genpath(folder));


%% Run channel registration

tform = main_channelRegistration( filepathCh1,filepathCh2 )
