function [ locs_xy ] = overcounting( mol_xy, blink_data, pa_dist )
% OVERCOUNTING adds localisations to simulated molecules randomly spread
% around the original molecule according to specified positional accuracy.
%
%% Input:
%       - mol_xy ... xy positions of molecules 
%       - blink_data ... list of number of detections per molecule from
%       data
%       - pa_dist ... statistics specifying the positional accuracy
%% Output:
%       - locs_xy ... xy positions of localizations
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% allocate number of localisations per molecule
numoflocs=NaN*zeros(size(mol_xy,1),1);

%% get number of locs per molecule from blinking histogram
numoflocs(:,1) = draw_from_histo(blink_data.num,size(mol_xy,1));
shuffle = randperm(size(mol_xy,1));
numoflocs = numoflocs(shuffle,:);

%% add localisations
% preallocate list for localisations
locs_xy=zeros(sum(numoflocs(:,1)),5);
ind = 1;

for j=1:size(numoflocs,1)
    
    center = mol_xy(j,1:2);
    mol_id = mol_xy(j,3);
    number = numoflocs(j,1);
    
    % allocate localisations at label positions
    locs_xy(ind:ind+number-1,3:4) = repmat(center,number,1);    
    % add label id
    locs_xy(ind:ind+number-1,1) = j;
    % add molecule id
    locs_xy(ind:ind+number-1,2) = mol_id;
    
    % increase counter
    ind = ind + number;    
end

%% add random pa to each localisattion
% generate distribution of localisation precision (pa)
pd_pa = makedist('Normal','mu',pa_dist.mu,'sigma',pa_dist.std);
pd_pa = truncate(pd_pa,pa_dist.lo,pa_dist.up);
pa = random(pd_pa,[size(locs_xy,1),1]);

% displace each localisation with given localisation precision (pa)
loc_error = normrnd(0,repmat(pa,1,2),size(locs_xy,1),2);
locs_xy(:,3:4) = locs_xy(:,3:4) + loc_error;

% store localisation precision in column 6 of localisation file
locs_xy(:,5) = pa;

end

