function [fig_hists, fig_kymo] = plotBlinkDist( blink_dist,timetraces,timetraces_normalized,numFrames )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plotBlinkDist

% author:  Magdalena Schneider
% date:    19.03.2020
% version: 1.0

% plotBlinkDist generates plot of blinking statistics

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Histograms
fig_hists = figure;
subplot(2,3,1)
histogram(blink_dist.num)
xlabel('Number of detections')
title('Detections of one label','FontSize',10)

subplot(2,3,4)
histogram(blink_dist.start)
xlabel('Frame number of start frame')
title('Start frames','FontSize',10)

subplot(2,3,2)
histogram(blink_dist.ton)
xlabel('Time (in frames)')
title('On-times','FontSize',10)

subplot(2,3,5)
histogram(blink_dist.toff)
xlabel('Time (in frames)')
title('Off-times','FontSize',10)

subplot(2,3,3)
histogram(blink_dist.numBursts)
xlabel('Number of bursts')
title('Bursts','FontSize',10)

subplot(2,3,6)
histogram(blink_dist.numGaps)
xlabel('Number of gaps')
title('Gaps','FontSize',10)

suptitle('Blinking statistics')
set(gcf,'Position',[350 150 1000 550])


% Kymographs
fig_kymo = figure;
% Timetraces
subplot(2,1,1)
hold on
labelIDs = unique(timetraces(:,2));
x(1) = 0;
x(2) = numFrames;
for i=1:size(labelIDs,1)
    plot([x(1) x(2)], [labelIDs(i) labelIDs(i)],'Color',[0.85 0.85 0.85])
end
plot(timetraces(:,1),timetraces(:,2),'.b')
title('Time traces','FontSize',13)
xlabel('framenumber','FontSize',13)
ylabel('label ID','FontSize',13)

% Timetraces normalized
subplot(2,1,2)
hold on
labelIDs = unique(timetraces_normalized(:,2));
x(1) = 0;
x(2) = numFrames;
for i=1:size(labelIDs,1)
    plot([x(1) x(2)], [labelIDs(i) labelIDs(i)],'Color',[0.85 0.85 0.85])
end
plot(timetraces_normalized(:,1),timetraces_normalized(:,2),'.b')
title('Time traces - normalized to first frame','FontSize',13)
xlabel('framenumber','FontSize',13)
ylabel('label ID','FontSize',13)
set(gcf,'Position',[350 150 800 550])
end

