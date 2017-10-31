% Check that the spike detected using Wave_Clus makes sense

% choose spike file to analyse
spikeFile = uigetfile('.h5', 'Select spike file'); 
spikeTrain = lookAtHfile(spikeFile);

% choose voltage file to analyse 
vFile = uigetfile('.mat', 'Select voltage recording'); 
load(vFile)

% choose electrode to analyse
electrode = 11;
fprintf('Analysing electrode number\n')
% electrodeIndex(electrode + 1)
% there is some shift in electrodeIndex, probably due to the missing 15
%% Plot 

figure; 
s1 = subplot(2, 1, 1); 
imagesc(spikeTrain(:, electrode)') % spike of electrode as heatmap
title('Spikes')
set(gca,'YTickLabel',[]); % get rid of Y as it means nothing
set(gca,'YTick', []); % need to find the code for tick mark
colorbar
% todo: change the tick values to integers only 
% https://www.mathworks.com/help/matlab/ref/matlab.graphics.illustration.colorbar-properties.html
xlabel('Time (seconds)')

s2 = subplot(2, 1, 2); 
rawPlot(electrodeMatrix, electrode, 100); 
title('Voltage')
set(gca, 'box', 'off')

% set polish of the figures
pos1 = get(s1, 'Position'); 
pos2 = get(s2, 'Position'); 
pos2(3) = pos1(3); % set width of axes to be equal
set(s2, 'Position', pos2); 
set(gcf,'color','w'); % white background


