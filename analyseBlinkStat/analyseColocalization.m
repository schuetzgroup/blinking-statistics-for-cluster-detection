function [dataBlink, dataPlatform, coloc_platform_fracs, coloc_blinks_fracs, coloc_platform_frac_total, coloc_blinks_frac_total, xlims, ylims ] = analyseColocalization( dataBlink,dataPlatform,searchRadius,parPlot,parSave )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% analyseColocalization

% author:  Magdalena Schneider
% date:    19.03.2020
% version: 1.0

% analyseColocalization performs colocalization analysis between blinking
% data and platform data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


fprintf('\n');
disp('Colocalization Analysis...')
numFiles = size(dataPlatform,2);

xlims = NaN(numFiles,2);
ylims = NaN(numFiles,2);

coloc_platform_abs = NaN(numFiles,1);
platform_size = NaN(numFiles,1);
coloc_blinks_abs = NaN(numFiles,1);
blinks_size = NaN(numFiles,1);
coloc_platform_fracs = NaN(numFiles,1);
coloc_blinks_fracs = NaN(numFiles,1);


% Colocalization
for f = 1:numFiles
    
    % Find center of each localization cluster
    locsBlinks = dataBlink(f).locs.pos;
    clustIDs = dataBlink(f).locs.clustIDs;
    centers_x = splitapply(@mean,locsBlinks(:,1),clustIDs);
    centers_y = splitapply(@mean,locsBlinks(:,2),clustIDs);
    centersBlinks = [centers_x,centers_y];
    % save clust center corresponding to clust ID
    dataBlink(f).locs.clustCenter = centersBlinks(clustIDs,:);
    
    locsPlatform = dataPlatform(f).locs.pos;
    
    %% Platform to Blinks
    % search for neighbors within range
    idx = rangesearch(centersBlinks,locsPlatform,searchRadius);
    % get number of neighbors within range
    numNeighbors_R = cellfun('size',idx,2);
    
    isColoc_R = (numNeighbors_R>0);
    dataPlatform(f).locs.coloc = isColoc_R;
    
    % Number and fraction of colocalized platforms
    coloc_platform_abs(f) = length(find(numNeighbors_R)); % find and count entries ~=0
    platform_size(f) = size(locsPlatform,1);
    coloc_platform_fracs(f) = coloc_platform_abs(f) / platform_size(f);
    
    %% Blinks to Platform
    % search for neighbors within range
    idx = rangesearch(locsPlatform,centersBlinks,searchRadius);
    % get number of neighbors within range
    numNeighbors_B = cellfun('size',idx,2);
    
    isColocCenters = (numNeighbors_B>0);
    dataBlink(f).locs.coloc = isColocCenters(clustIDs,:);
    
    % Number and fraction of colocalized platforms
    coloc_blinks_abs(f) = length(find(numNeighbors_B)); % find and count entries ~=0
    blinks_size(f) = size(centersBlinks,1);
    coloc_blinks_fracs(f) = coloc_blinks_abs(f) / blinks_size(f);
    
    
    %% Plot colocalization
    isColocBlink = dataBlink(f).locs.coloc;
    blinkColoc = dataBlink(f).locs.pos(isColocBlink,:);
    blinkNotColoc = dataBlink(f).locs.pos(~isColocBlink,:);
    
    centersBlinkColoc = centersBlinks(isColocCenters,:);
    centersBlinkNotColoc = centersBlinks(~isColocCenters,:);
    
    isColocPlatform = dataPlatform(f).locs.coloc;
    platformColoc = dataPlatform(f).locs.pos(isColocPlatform,:);
    platformNotColoc = dataPlatform(f).locs.pos(~isColocPlatform,:);
    
    if parPlot.plotFigures && (f<=parPlot.endFile)
        fig_coloc = figure('Name',dataBlink(f).filename);
        hold on
        % Platform Data
        % Non-colocalized
        h1 = plot(platformNotColoc(:,1),platformNotColoc(:,2),'*','Color',0.8.*[1 1 1]);
        vecRadii = repmat(searchRadius,size(platformNotColoc,1),1);
        h2 = viscircles(platformNotColoc,vecRadii,'Color',0.8.*[1 1 1],'LineWidth',1,'LineStyle','--');
        % Colocalized
        h3 = plot(platformColoc(:,1),platformColoc(:,2),'r*');
        vecRadii = repmat(searchRadius,size(platformColoc,1),1);
        h4 = viscircles(platformColoc,vecRadii,'Color','r','LineWidth',1);
        % Blink Data
        % Non-colocalized
        h5 = plot(blinkNotColoc(:,1),blinkNotColoc(:,2),'.','Color',0.6.*[1 1 1]);
        h6 = plot(centersBlinkNotColoc(:,1),centersBlinkNotColoc(:,2),'o','Color',0.6.*[1 1 1]);
        % Colocalized
        h7 = plot(blinkColoc(:,1),blinkColoc(:,2),'b.');
        h8 = plot(centersBlinkColoc(:,1),centersBlinkColoc(:,2),'co');
        axis equal
        title('Colocalization Analysis')
        xlabel('x /nm')
        ylabel('y /nm')
        legend([h7,h5,h3,h1],{'Blink, coloc','Blink, non-coloc','Platform, coloc','Platform, non-colc'})
        set(gca,'FontSize',12)
        xlims(f,:) = xlim;
        ylims(f,:) = ylim;
    end
    
    %% Keep only colocalized points
    
    % Blink Data
    dataBlink(f).locs = dataBlink(f).locs( isColocBlink,: );
    dataBlink(f).csv = dataBlink(f).csv( isColocBlink,: );
    % Platform Data
    dataPlatform(f).locs = dataPlatform(f).locs( isColocPlatform,: );
    
    
    %% Save figures
    
    if parPlot.plotFigures && (f<=parPlot.endFile) && parSave.save_figures
        % go to path
        cd(parSave.path_save);
        
        % save histograms for blinking statistics
        fname.fig_coloc = [parSave.labelType,'_colocalization','_file',num2str(f)];
        saveas(fig_coloc, fullfile(parSave.path_save, fname.fig_coloc), 'png'); % as png
    end
    
    
end

coloc_platform_frac_total = sum(coloc_platform_abs) / sum(platform_size);
coloc_blinks_frac_total = sum(coloc_blinks_abs) / sum(blinks_size);

disp('Done')
end
