%% Script - Run Ripley's Analysis

% author:  Magdalena Schneider
% date:    19.03.2020
% version: 1.1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Specify input parameters and files

data = 'example';
blink_statistics = 'example';
density = 10;
runs = 5;


%% Add current folder to path

% Get current folder
folder = fileparts(which(mfilename)); 
% Add folder and subfolders to path
addpath(genpath(folder));


%% Run analysis of blinking statistics

[rk_result_sample, rk_result_sim] = main_ripley_w_blinks(data, blink_statistics, density, runs);
