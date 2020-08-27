function [rk_result_sample, rk_result_sim] = main_ripley_w_blinks(data, blink_statistics, density, runs)

%% Function Description:
% This function simulates blinking molecules at a specified density
% according to specified blinking behaviour. It performs Ripley's K
% analysis on the simulated data, and/or on a sample input file.


%% Parameters to set:
steps = 1:5:750;        % Ripley's K sample distances
roi = 5e3;              % Side length of region of interest for simulation in nm

% Localization precision for simulations
pa.mu = 30;             % mean pa in nm
pa.std = 5;             % std of pa in nm
pa.lo = 10;             % lower bound in nm
pa.up = 60;             % upper bound in nm

f = 'rnd_simulation.mat'; % Specify output file name for storage of 1 simulation run


%% Preparation

% Create folder for saving results
path_save = [pwd,'\ripleyAnalysis_results'];
if ~exist(path_save, 'dir')
    mkdir(path_save)
end

% Get color map for figures
cols = lines(2);


%% Check input

fprintf('\n');
disp('Checking input parameters...')

% number of inputs
narginchk(4,4);

% validity of string inputs
validInput = ["example", "sample", "none"];
if ~(any(data == validInput) && any(blink_statistics == validInput))
    error('No valid input for SMLM- and/or Blinking-Data.');
end

if (runs < 5)
    runs = 5;
    fprintf('Set number of runs to minimum value of 5.\n');
end

% check for redundancy in density.
if (data ~= "none") && density > 0
    fprintf('Density is approximated from SMLM Data.\nUser-specified density is neglected.\n');
elseif (data == "none") && density == 0
    error('Specify density.');
end

disp('Done.')


%% Load localization & blinking data
% Load SMLM data in csv format (e.g. ThunderSTORM output):
% Only xy-coordinates are needed for the analysis (given in nm).
% Corresponding headers may be termed x_nm/x [nm]/pos_x or
% y_nm/y [nm]/pos_y, respectively.

fprintf('\n');
disp('Loading data..')

switch data
    case 'example'
        loc_dat = readtable('data\psCFP2_primaryTcell_CD3z.csv');
        columnNames = loc_dat.Properties.VariableNames;
        % check if correct column names and get column indices
        [xposColumn,yposColumn] = getColumnIndices( columnNames );
        % xy positions
        loc_dat_xy = loc_dat{:,[xposColumn,yposColumn]};
    case 'sample'
        [file path] = uigetfile('*.csv','Select csv files');
        loc_dat = readtable([path file]);
        columnNames = loc_dat.Properties.VariableNames;
        % check if correct column names and get column indices
        [xposColumn,yposColumn] = getColumnIndices( columnNames );
        % xy positions
        loc_dat_xy = loc_dat{:,[xposColumn,yposColumn]};
end

% Load blinking data as *.mat file
% Blinking data needs to be stored in a mat-file within blink_dist.num
% Each value represents the number of detections for 1 PS-CFP2 molecule
% data corresponds to Figure 1F, red.
switch blink_statistics
    case 'example'
        load('data\pscfp2_3kW2msPFA_blink_dist.mat');
        blink_dist=blink_dist;
        
    case 'sample'
        [fblink,pblink]=uigetfile('*.mat','Select blinking statistics');
        load(fullfile(pblink,fblink));
        blink_dist=blink_dist;
        
    case 'none'
        blink_dist.num = 1;
end

disp('Done.')


%% ROI selection & Density estimation & Ripley's K analysis for SMLM data

if (data == "example") || (data == "sample")
    
    %% Selection of a quadratic ROI
    
    fprintf('\n');
    disp('Selecting desired regions of interests...')
    
    % Minimal ROI-Size is 2 x 2 um
    figure('Name','Please select region of interest!')
    plot(loc_dat_xy(:,1),loc_dat_xy(:,2),'.r','MarkerSize',2);
    xlabel('x [nm]');
    ylabel('y [nm]');
    axis equal;
    axis tight;
    xy_sample = [0 0; 0 0];
    
    disp('Please draw desired region of interest (ROI) in image by clicking and dragging!')
    disp('Double-click on the ROI if finished!')
    
    while (xy_sample(2,2)-xy_sample(1,2)<2000)
        if (xy_sample(2,2)-xy_sample(1,2)<2000)
            hroi = drawrectangle('FixedAspectRatio',true);
            selectedRoi = customWait(hroi);
            roi_xywh = selectedRoi.Position;
            % Get corner points
            xy_sample = [roi_xywh(1) roi_xywh(2); ...
                roi_xywh(1) roi_xywh(2)+roi_xywh(4); ...
                roi_xywh(1)+roi_xywh(3) roi_xywh(2)+roi_xywh(4); ...
                roi_xywh(1)+roi_xywh(3) roi_xywh(2)];
            if (xy_sample(2,2)-xy_sample(1,2)<2000)
                fprintf('\n');
                fprintf('Selected ROI is too small! Please draw larger ROI!\n');
                delete(selectedRoi)
            end
            
        end
    end
    close(gcf);
    
    % Select localizations within ROI
    in = inpolygon(loc_dat_xy(:,1), loc_dat_xy(:,2), xy_sample(:, 1), xy_sample(:, 2));
    loc_xy_inRoi = loc_dat_xy(in==1,:);
    
    disp('Done.')
    
    
    %% Get Ripley's K statistics
    
    fprintf('\n');
    disp('Calculating Ripley''s K statistics for experimental input data...')
    
    [rk_result_sample, loc_density_sample] = ripley( loc_xy_inRoi, xy_sample, steps );
    
    % Get molecule density from data
    density = loc_density_sample * 1e6 / mean(blink_dist.num);
    
    
    %% Plot SMLM data & Ripley's K curve
    
    g = figure();
    set(gcf,'Position',[350 350 1250 450])
    
    % subplot #1: cell data
    subfigData = subplot(1,3,1);
    plot(loc_xy_inRoi(:,1),loc_xy_inRoi(:,2),'.r');
    title('SMLM data');
    xlabel('x [nm]');
    ylabel('y [nm]');
    axis equal; axis tight;
    
    % subplot #2: cell RK
    subfigRipley = subplot(1,3,3);
    dataRipley = plot(steps,rk_result_sample(4,:),'Color',cols(1,:),'LineWidth',2);
    xlabel('r [nm]');
    ylabel('L(r)-r [nm]');
    title('Ripley''s analysis')
    legend([dataRipley],{'Experimental data'})
    
    disp('Done.')
    
else
    % No SMLM to analyze, set output to 0
    rk_result_sample = 0;
end


%% Simulate Random Data with Blinking

fprintf('\n');
disp('Running simulations...')

% Allocate result
sim_loc_dist = cell(runs, 1);

% Repeat simulation
for j = 1 : runs
    % simulate random distributions with blinking
    sim_loc_dist{j} = simulate_w_blinking(density, roi, blink_dist, pa);
    
    % save distributions and plot last run
    if j == runs
        f_sim = strrep(f,'.mat','_loc_maps.mat');
        save(fullfile(path_save ,f_sim),'sim_loc_dist')
        
        if (data == "example") || (data == "sample")
            figure(g)
            subfigSim = subplot(1,3,2);
        else
            g = figure;
            set(gcf,'Position',[450 350 900 450])
            subfigSim = subplot(1,2,1);
        end
        plot(sim_loc_dist{j}(:,3),sim_loc_dist{j}(:,4),'.r');
        title('Exemplary simulation');
        xlabel('x [nm]');
        ylabel('y [nm]');
        axis equal; axis tight;
    end
end

disp('Done.')


%% Ripley's K Analysis of Simulated Data

fprintf('\n');
disp('Calculating Ripley''s K statistics for simulations...')

% Select ROI to  analyze from the simulations
xy = [round(0.1*roi) round(0.1*roi); round(0.1*roi) round(roi-0.1*roi); round(roi-0.1*roi) round(roi-0.1*roi); round(roi-0.1*roi) round(0.1*roi)];

for j = 1 : runs
    in = inpolygon(sim_loc_dist{j}(:,3), sim_loc_dist{j}(:,4), xy(:, 1), xy(:, 2));
    loc_xy_inRoi = sim_loc_dist{j}(in==1,3:4);
    rk_result = ripley( loc_xy_inRoi, xy, steps );
    rk_result_sim(j,:) = rk_result(4,:);
end

disp('Done.')


%% Plot simulation results

fprintf('\n');
disp('Plotting results...')

% Subplot: Ripley's K curves
if ~exist('subfigRipley')
    subfigRipley = subplot(1,2,2);
else
    axes(subfigRipley)
end
hold on
% Ripley's K for simulation data (mean)
meanRipley = plot(steps,mean(rk_result_sim),'-','Color',cols(2,:),'LineWidth',2); hold on;
% 'Confidence interval' (mean +- std)
h2 = plot(steps,mean(rk_result_sim)+std(rk_result_sim),'--','Color',cols(2,:)); hold on;
plot(steps,mean(rk_result_sim)-std(rk_result_sim),'--','Color',cols(2,:)); hold on;
xlabel('r [nm]');
ylabel('L(r)-r [nm]');
title('Ripley''s analysis')

% Adapt axes and save
f_rk = strrep(f,'.mat','_rk_results.mat');
if (data == "example") || (data == "sample")
    % Adapt axes for simulation locs plot
    axes(subfigSim)
    axis([0 xy_sample(2,2)-xy_sample(1,2) 0 xy_sample(2,2)-xy_sample(1,2)]);
    
    % Adapt Ripley's K plot
    axes(subfigRipley)
    dataRipley = plot(steps,rk_result_sample(4,:),'Color',cols(1,:),'LineWidth',2); % get data curve to front
    legend([dataRipley,meanRipley, h2],{'Experimental data','Mean of sims','Mean +/- std of sims'}) % add legend
    axis([0 max(steps) -1 max([mean(rk_result_sim)+std(rk_result_sim),rk_result_sample(4,:)])+5]); % adapt axes
    
    % Save results
    save(fullfile(path_save,f_rk),'rk_result_sample','rk_result_sim','density','steps');
else
    % Adapt Ripley's K plot
    legend([meanRipley, h2],{'Mean of simulations','Mean of simulations +/- std'}) % add legend
    %axis([0 max(steps) -1 max(mean(rk_result_sim)+std(rk_result_sim))+5]); % adapt axes
    
    % Save results
    save(fullfile(path_save ,f_rk),'rk_result_sim','density','steps');
end

% Save figure
fig_name = strrep(f,'.mat','_results.fig');
fig_store = [path_save,'\',fig_name];
savefig(fig_store)

disp('Done.')
end