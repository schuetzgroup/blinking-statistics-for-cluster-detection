function [ R ] = draw_from_histo( hist, Nvec )
% DRAW_FROM_HISTO draws number of localizations per molecule from measured
% distribution
%
%% Input: 
%       - hist ... measured numbers of localizations per molecule
%       - Nvec ... number of values to draw from 
%% Output:
%       - R ... number of localizations per molecule for simulations
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% generate cdf from histograms
[cdf,X] = ecdf(hist);

if isscalar(Nvec)
    Nvec = [Nvec,1];
end
N = prod(Nvec);
% prepare random numbers
R = rand(N,1);
% transpond to given distribution
R = ceil(interp1(cdf,X,R,'linear'));
R = reshape(R,Nvec);

end

