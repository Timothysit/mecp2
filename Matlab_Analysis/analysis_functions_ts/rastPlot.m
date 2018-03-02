function rastPlot(spikeTrain)
% plots a raster plot with electrodes on x axis and time on y-axis 
% note, this assumes a matrix: numSample x numChannels
imagesc(spikeTrain') 
colormap(flipud(gray)) % if you want black and white
c = colorbar(); 
% c = colorbar('Ticks', 0:1:max(max(spikeTrain))); % only integer ticks 
% this won't work well if you have strong outliers
c.Label.String = 'Number of spikes';
xlabel('Time (s)') 
ylabel('Electrode')
aesthetics()
end


