function rawPlot(timeSeries, electrodeNum, downSample)
electrodeTseries = timeSeries(:, electrodeNum);
t = mean(reshape(electrodeTseries, downSample, [])); % downsamples the time series
plot(t)
% make title include file name and electrode number
xlabel('samples')
ylabel('voltage (uV)')
end