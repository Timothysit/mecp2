% high resolution look at spike detection 
% TODO: the raster plot still doens't make sense... doens't correspond to
% crsosing threshold for some reason... 

% this is the example used for 12096ADIV22E11 
% startWindow = 25000 * 88.45; 
% endWindow = 25000 * 88.51; 

startWindow = 12000000; % this is for 12096ADIV22E58
endWindow = 12500000; % but didn't work very well

% try 88.2 - 88.6

%% raw plot 
subplot(100, 1, [1 25]) 

plot(data)
title('Raw data (1209 DIV22 6A Electrode 11) 88.45 - 88.51s')
xlim([startWindow endWindow ])
aesthetics()
removeAxis() 

% there is a more elegant way to do this with a for loop 
% and automaticly dividing subplots

%% Prez's method 
[spikeTrain, finalData, threshold] = detectSpikes(data, 'Prez', 4);

subplot(100, 1, [26 30]) % raster 
% singleRastPlot(spikeTrain(startWindow:endWindow)) % there is something wrong with this line
singleRastPlot(spikeTrain)
xlim([startWindow endWindow])

numSpike = sum(spikeTrain);
s = ' ';
title(['Prez: Elliptical, median - 4SD, 1.5ms RP,' s num2str(numSpike) s 'spikes'])
subplot(100, 1, [31 50]) 
plot(finalData); 
xlim([startWindow endWindow])
% threshold 
hold on; 
xlim([startWindow endWindow])
plot([1 length(data)], [threshold threshold], '-')
aesthetics()
removeAxis()

%% Manuel's method 
[spikeTrain, finalData, threshold] = detectSpikes(data, 'Manuel', 5);
subplot(100, 1, [51 55]) 
singleRastPlot(spikeTrain)
xlim([startWindow endWindow])

numSpike = sum(spikeTrain);
title(['Manuel: Butterworth, mean - 5SD, 2ms RP,' s num2str(numSpike) s 'spikes'])
subplot(100, 1, [56 75]) 
plot(finalData)
xlim([startWindow endWindow])
% threshold 
hold on; 
plot([1 length(data)], [threshold threshold], '-')
xlim([startWindow endWindow])
aesthetics()
removeAxis()


%% Tim's method 
[spikeTrain, finalData, threshold] = detectSpikes(data, 'Tim', 12);
subplot(100, 1, [76 80])
singleRastPlot(spikeTrain)
xlim([startWindow endWindow])

numSpike = sum(spikeTrain);
title(['Tim: Butterworth, nonlinear energy operator, mean + 12SD, 2ms RP,' ... 
    s num2str(numSpike) s 'spikes'])
subplot(100, 1, [81 100]) 
plot(finalData);
xlim([startWindow endWindow])
% threshold 
hold on; 
plot([1 length(data)], [threshold threshold], '-')
xlim([startWindow endWindow])
aesthetics()
removeAxis()



