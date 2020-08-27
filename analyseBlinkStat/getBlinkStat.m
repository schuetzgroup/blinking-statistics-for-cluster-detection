function [dataBlink,blink_dist,timetraces,timetraces_normalized,numLabels,numSkippedClusts] = getBlinkStat( dataBlink,maxBlinks )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getBlinkStat

% author:  Magdalena Schneider
% date:    19.03.2020
% version: 1.0

% getBlinkStat calculates the blinking statistics for the input data

% Input:  dataBlink ... localization data
%         maxBlinks ... threshold for outliers (based on total
%                      number of detections)
%
% Output: dataBlink  ...  analyzed blinking data
%         blink_dist ... blinking statistics
%         timetraces ... timetraces of blinks
%         timetraces_normalized ... normalized timetraces of blink
%         numLables  ... number of analyzed labels
%         numSkippedClusts ... number of skipped clusters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numFilesBlink = length(dataBlink);

% Initialize
numLabels = NaN(numFilesBlink,1);
numSkippedClusts = NaN(numFilesBlink,1);

% Loop over all files

for f = 1:numFilesBlink
    if ~isempty(dataBlink(f).locs) % Check if any localizations available
        [dataBlink(f).locs,idxvec] = sortrows(dataBlink(f).locs,3); % sort rows according to framenumber
        dataBlink(f).csv = dataBlink(f).csv(idxvec,:); % sort rows of csv
        numLabels(f) = size(unique(dataBlink(f).locs.clustIDs),1); % get number of clusters
        
        numSkippedClusts(f) = 0; % number of skipped, invalid clusters
        dataBlink(f).skippedClusts = []; % initialize for saving IDs of skipped clusters
        Ids = unique(dataBlink(f).locs.clustIDs);
        dataBlink(f).clusts = cell(1,size(Ids,1));
        
        % Assign new cluster IDs
        startClustID = sum(numLabels(1:f))-numLabels(f)+1;
        endClustID = sum(numLabels(1:f));
        clustIds = [startClustID:1:endClustID];
        
        for n = 1:size(Ids,1) % loop over all labels
            
            c = clustIds(n);
            
            % get framenumbers belonging to this cluster (i.e. label)
            frames = dataBlink(f).locs.frame(dataBlink(f).locs.clustIDs==Ids(n),:);
            frames = sort(frames);
            
            % Check if all framenumbers are unique, otherwise the clustering is
            % wrong! -> discard this cluster
            % Check for outlier (threshold for max. number of blinks)
            if length(frames) == length(unique(frames)) && size(frames,1)<=maxBlinks
                
                %% Number of localizations
                % Get number of localizations per cluster (cluster from a single label-molecule)
                % read out how many locs have same cluster number (output of clustering algorithm)
                clust(c).numLocs = size(frames,1);
                
                %% Startframe
                % Get framenumber of first localization of each localization cluster
                % read out minimum value of framenumbers
                clust(c).startframe = min(frames);
                
                %% On-times
                % Get number of on-times
                frames_tmp = frames-(1:length(frames))'; % adjust so that consecutive framenumbers have same number
                clust(c).ton = histc(frames_tmp,unique(frames_tmp));
                
                %% Off-times
                % Get number of off-times
                clust(c).toff = nonzeros(diff(frames-(1:length(frames))'));
                
                %% Number of bursts
                clust(c).numBursts = length(clust(c).ton);
                
                %% Number of gaps
                clust(c).numGaps = length(clust(c).toff);
                
                %% Get timetrace
                clust(c).timetrace(:,1) = frames; % frames of appearance
                clust(c).timetrace(:,2) = c;      % clusterID
                
                clust(c).timetrace_normalized(:,1) = frames - clust(c).startframe + 1; % frames of appearance
                clust(c).timetrace_normalized(:,2) = c;      % clusterID
                
                %% Get csv data
                csv_tmp = dataBlink(f).csv(dataBlink(f).locs.clustIDs==Ids(n),:);
                csv_tmp.clustID = repmat(c,height(csv_tmp),1);
                clust(c).csv = {csv_tmp};
                
                
                %% Check results
                if any(clust(c).toff<=0)
                    warning('Wrong calculation of toff')
                    break
                end
                
            else
                if length(frames) == length(unique(frames))
                    warning('Repeated framenumber for the same cluster! Wrong clustering! There cannot be more than one localization in each frame from the same label!')
                elseif size(frames,1)<=maxBlinks
                    warning('Number of blinks exceeds threshold! Outlier is removed from analysis.')
                end
                % Skip cluster and assign empty arrays to blink statistics
                clust(c).numLocs = [];
                clust(c).startframe = [];
                clust(c).ton = [];
                clust(c).toff = [];
                clust(c).numBursts = [];
                clust(c).numGaps = [];
                numSkippedClusts(f) = numSkippedClusts(f) + 1;
                dataBlink(f).skippedClusts = [dataBlink(f).skippedClusts,Ids(n)]; % add clustID of skipped cluster
            end
        end
        
        % Combine statistics from all individual labels
        dataBlink(f).numsLocs = [clust(:).numLocs]';           % number of localizations for individual labels
        dataBlink(f).startframes = [clust(:).startframe]';     % frames of first appearance of individual labels
        dataBlink(f).tons = vertcat(clust(:).ton);             % on-times
        dataBlink(f).toffs = vertcat(clust(:).toff);           % off-times
        dataBlink(f).numsBursts = [clust(:).numBursts]';       % number of bursts
        dataBlink(f).numsGaps = [clust(:).numGaps]';           % number of gaps
        dataBlink(f).timetraces = vertcat(clust(:).timetrace); % time traces of individual labels (frames of appearance)
        dataBlink(f).timetraces_normalized = vertcat(clust(:).timetrace_normalized); % time traces of individual labels (frames of appearance), normalized to startframe number 1
        
        dataBlink(f).clusts_csv = vertcat(clust(:).csv);
        
        % Clear data for this file
        clear clust
    else
        warning(['No localizations to analyze for this file: ',dataBlink(f).filename])
        
        numLabels(f) = 0;
        % Save empty blinking statistics
        dataBlink(f).numsLocs = [];              % number of localizations for individual labels
        dataBlink(f).startframes = [];           % frames of first appearance of individual labels
        dataBlink(f).tons = [];                  % on-times
        dataBlink(f).toffs = [];                 % off-times
        dataBlink(f).numsBursts = [];            % number of bursts
        dataBlink(f).numsGaps = [];              % number of gaps
        dataBlink(f).timetraces = [];            % time traces of individual labels (frames of appearance)
        dataBlink(f).timetraces_normalized = []; % time traces of individual labels (frames of appearance), normalized to startframe number 1
        dataBlink(f).skippedClusts = [];
        
        dataBlink(f).clusts_csv = {};
    end
end

% Combine statistics from all input files
numsLocs = vertcat(dataBlink(:).numsLocs);
startframes = vertcat(dataBlink(:).startframes);
tons = vertcat(dataBlink(:).tons);
toffs = vertcat(dataBlink(:).toffs);
numsBursts = vertcat(dataBlink(:).numsBursts);
numsGaps = vertcat(dataBlink(:).numsGaps);

timetraces = vertcat(dataBlink(:).timetraces);

timetraces_normalized = vertcat(dataBlink(:).timetraces_normalized);
% check
if (size(timetraces,1) ~= sum(numsLocs)) || (size(timetraces_normalized,1) ~= sum(numsLocs))
    error('Time-traces not corresponding to total number of localizations!')
end

clusts_csv = vertcat(dataBlink(:).clusts_csv);

disp('Done')


%% Store acquired blinking statistics

blink_dist = struct;      % initialize structure for results

blink_dist.num = numsLocs;
blink_dist.start = startframes;
blink_dist.ton = tons;
blink_dist.toff = toffs;
blink_dist.numBursts = numsBursts;
blink_dist.numGaps = numsGaps;

end