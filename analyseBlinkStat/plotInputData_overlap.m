function plotInputData_overlap( dataBlink,dataPlatform )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plotInputData_overlap

% author:  Magdalena Schneider
% date:    19.03.2020
% version: 1.0

% plotInputData_overlap plots input blinking and platform data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numFiles = size(dataBlink,2);

colors = lines(10);
for f=1:numFiles
    figure('Name',dataBlink(f).filename);
    hold on
    h1 = plot(dataBlink(f).locs.pos(:,1),dataBlink(f).locs.pos(:,2),'.','Color',colors(1,:));
    h2 = plot(dataPlatform(f).locs.pos(:,1),dataPlatform(f).locs.pos(:,2),'o','Color',colors(2,:));
    axis equal
    title(['Input data, file number ',num2str(f)])
    xlabel('x /nm')
    ylabel('y /nm')
    legend([h1,h2],{'Blink data','Platform data'})
    set(gca,'FontSize',12)
end

end

