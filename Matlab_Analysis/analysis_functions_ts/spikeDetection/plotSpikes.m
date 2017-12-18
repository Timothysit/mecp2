function plotSpikes(spikeTrain, electrodeMatrix, electrode)
    % note that spikeTrain will be spikeTrain for the entire MEA
    % ie. numChannel x numSamples
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
    
    % adjust size 
    x0 = 10; 
    y0 = 10; 
    height = 400;
    width = height * 21 / 9; % #aesthetics
    set(gcf, 'units', 'points', 'position', [x0, y0, width, height])
    % set polish of the figures
    pos1 = get(s1, 'Position'); 
    pos2 = get(s2, 'Position'); 
    pos2(3) = pos1(3); % set width of axes to be equal
    set(s2, 'Position', pos2); 
    set(gcf,'color','w'); % white background
end