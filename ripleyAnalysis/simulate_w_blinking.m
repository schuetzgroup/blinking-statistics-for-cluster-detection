function [ locs ] = simulate_w_blinking( density, roi, blink_data, pa )
% SIMULATE_W_BLINKING simulates random distribution of molecules within a roi
% at specified density and adds overcounting
%
%% Input: 
%       - density ... density of molecules within roi
%       - roi ... region of interest for analysis
%       - blink_data ... specifies number of localizations per molecule
%       - pa ... specifies positional accuracy used for simulation
%% Output:
%       - locs ... xy positions of localisations
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% simulate molecules
no_mols = round(density *(roi*1e-3)^2);
molecules_xy=rand(no_mols,2)*roi;
molecules_xy(:,3)=1:size(molecules_xy,1);

%% add overcounting
[locs] = overcounting(molecules_xy, blink_data, pa);

end

