function [dataBlink,dataPlatform] = selectRegion( shape,dataBlink,dataPlatform )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% selectRegion

% author:  Magdalena Schneider
% date:    19.03.2020
% version: 1.0

% selectRegion lets the user select a region of interest in a plotted
% figure by clicking and dragging

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n');
disp('Selecting desired regions of interests...')

colors = lines(10);


%% Plot first data file and select region of interest

filenum = 1; % plot first data file
figure('Name',dataBlink(filenum).filename,'Units','normalized','Position',[0.2 0.2 0.7 0.7]);
hold on
h1 = plot(dataBlink(filenum).locs.pos(:,1),dataBlink(filenum).locs.pos(:,2),'.','Color',colors(1,:));
if ~isempty(dataPlatform)
    h2 = plot(dataPlatform(filenum).locs.pos(:,1),dataPlatform(filenum).locs.pos(:,2),'o','Color',colors(2,:));
    xmax = max([h1.XData,h2.XData]);
    ymax = max([h1.YData,h2.YData]);
    legend([h1,h2],{'Blink data','Platform data'})
else
    xmax = max(h1.XData);
    ymax = max(h1.YData);
    legend(h1,'Blink data')
end
axis equal
title('Please select ROI!')
xlabel('x /nm')
ylabel('y /nm')
xlim([0 xmax+xmax/10])
ylim([0 ymax+ymax/10])
set(gca,'FontSize',12)
disp('Please draw desired ROI in image by clicking and dragging! Double-click on the ROI if finished!')

switch shape
    case 'polygon'
        h = drawpolygon;
    case 'rectangle'
        h = drawrectangle;
end
roi = customWait(h);


%% Limit localizations to selected ROI for all files

numFiles = size(dataBlink,2);
for f = 1:numFiles
    % Get points inside selected ROI
    % Blink data
    if ~isempty(dataBlink(f).locs)
        indices_in = inROI( roi,dataBlink(f).locs.pos(:,1), dataBlink(f).locs.pos(:,2));
        dataBlink(f).locs = dataBlink(f).locs(indices_in,:);
        dataBlink(f).csv = dataBlink(f).csv(indices_in,:);
    end
    
    % Platform data
    if ~isempty(dataPlatform)
        if ~isempty(dataPlatform(f).locs)
            indices_in = inROI( roi,dataPlatform(f).locs.pos(:,1), dataPlatform(f).locs.pos(:,2));
            dataPlatform(f).locs = dataPlatform(f).locs(indices_in,:);
        end
    end
end

disp('Done')

end