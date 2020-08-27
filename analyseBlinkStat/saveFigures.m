function saveFigures( path_save,labelType,fig_hists,fig_kymo )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% saveFigures

% author:  Magdalena Schneider
% date:    19.03.2020
% version: 1.0

% saveFigures saves figures in the specified path

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd(path_save);

%% Save results

% Histograms for blinking statistics
fname.fig_hists = [labelType,'_histogramsBlinkDist.png'];
saveas(fig_hists, fullfile(path_save, fname.fig_hists), 'png'); % as png

% Timetraces kymographs
fname.fig_kymo = [labelType,'_timetraces.png'];
saveas(fig_kymo, fullfile(path_save, fname.fig_kymo), 'png'); % as png

end

