function [ result, density ] = ripley( data, roi, steps)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ripley
% Calculates Ripley'S K statistics.

% author:  Magdalena Schneider
% date:    18.03.2020
% version: 1.0

% Input:  data  ... data to be analysed
%         roi   ... specified region of interest
%         steps ... distances to analyse for Ripley's K analysis
%
% Output: result  ... first row:  steps
%                     second row: Ripley's K
%                     third row:  Ripley's L
%                     fourth row: L(r)-r
%         density ... density within roi
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get roi area and density for normalization
roisize_x = roi(3,1) - roi(1,1);
roisize_y = roi(3,2) - roi(1,2);
A = roisize_x * roisize_y;
N = size(data,1);
density = N/A;

% Shift data to origin
data(:,1) = data(:,1)-roi(1,1);
data(:,2) = data(:,2)-roi(1,2);

% Calculate Ripley's K statistics
K = NaN(1,size(steps,2)); % allocate array for K statistics
for m = 1:size(steps,2) % loop through step sizes
    r = steps(m);
    idx_left = data(:,1)>r; % take out left side
    idx_right = data(:,1)<(roisize_x-r); % take out right side
    idx_bottom = data(:,2)>r; % take out bottom
    idx_top = data(:,2)<(roisize_y-r); % take out top
    
    indx_in = idx_left & idx_right & idx_bottom & idx_top;
    data_in = data( indx_in,: );
    
    Idx = rangesearch(data,data_in,steps(m));
    % Get number of neighbors for each points
    % (subtract 1 because rangesearch counts itself)
    numsNeighbors = cellfun('length',Idx)-1;
    % Get average number of neighbors
    K(m) = sum(numsNeighbors) / length(numsNeighbors);
end

% Get ripley's k statistics
K_p = K/density;
L = sqrt(K_p/pi);
lr = L - steps;
result = [steps; K_p; L; lr];

end
