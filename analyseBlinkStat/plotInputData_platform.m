function [xlims,ylims] = plotInputData_platform( data,parPlot )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plotInputData_platform

% author:  Magdalena Schneider
% date:    19.03.2020
% version: 1.0

% plotInputData_platform plots input platform data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numFiles = size(data,2);

if nargin == 1
    
    xlims = NaN(numFiles,2);
    ylims = NaN(numFiles,2);
    
    for f=1:numFiles
        figure('Name',data(f).filename);
        plot(data(f).locs.pos(:,1),data(f).locs.pos(:,2),'r.')
        axis equal
        title('Platform data')
        xlabel('x /nm')
        ylabel('y /nm')
        set(gca,'FontSize',12)
        xlims(f,:) = xlim;
        ylims(f,:) = ylim;
    end
    
elseif nargin == 2
    
    for f=1:numFiles
        figure('Name',data(f).filename);
        plot(data(f).locs.pos(:,1),data(f).locs.pos(:,2),'r.')
        axis equal
        title('Platform data')
        xlabel('x /nm')
        ylabel('y /nm')
        set(gca,'FontSize',12)
        xlim(parPlot.xl_platform(f,:));
        ylim(parPlot.yl_platform(f,:));
    end
    
end

