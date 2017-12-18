%% raw plot 
subplot(100, 1, [1 25]) 

plot(data)
title('Raw data (1209 DIV22 6A Electrode 58)')
aesthetics()
removeAxis() 

% there is a more elegant way to do this with a for loop 
% and automaticly dividing subplots

%% Prez's method 
[spikeTrain, finalData, threshold] = detectSpikes(data, 'Prez', 4);

subplot(100, 1, [26 30]) % raster 
singleRastPlot(spikeTrain) 
numSpike = sum(spikeTrain);
s = ' ';
title(['Prez: Elliptical, median - 4SD, 1.5ms RP,' s num2str(numSpike) s 'spikes'])
subplot(100, 1, [31 50]) 
plot(finalData); 
% threshold 
hold on; 
plot([1 length(data)], [threshold threshold], '-')
aesthetics()
removeAxis()

%% Manuel's method 
[spikeTrain, finalData, threshold] = detectSpikes(data, 'Manuel', 5);
subplot(100, 1, [51 55]) 
singleRastPlot(spikeTrain) 
numSpike = sum(spikeTrain);
title(['Manuel: Butterworth, mean - 5SD, 2.0ms RP,' s num2str(numSpike) s 'spikes'])
subplot(100, 1, [56 75]) 
plot(finalData); 
% threshold 
hold on; 
plot([1 length(data)], [threshold threshold], '-')
aesthetics()
removeAxis()


%% Tim's method 
[spikeTrain, finalData, threshold] = detectSpikes(data, 'Tim', 12);
subplot(100, 1, [76 80])
singleRastPlot(spikeTrain) 
numSpike = sum(spikeTrain);
title(['Tim: Butterworth, nonlinear energy operator, mean + 12SD, 2.0ms RP,' ... 
    s num2str(numSpike) s 'spikes'])
subplot(100, 1, [81 100]) 
plot(finalData); 
% threshold 
hold on; 
plot([1 length(data)], [threshold threshold], '-')
aesthetics()
removeAxis()



