
subplot(3, 1, 1); 
plot(data); 
title('Raw data')
aesthetics()

subplot(3, 1, 2); 
lowpass = 600; 
highpass = 8000; 
fs = 25000; 
wn = [lowpass highpass] / (fs / 2); 
filterOrder = 3;
[b, a] = butter(filterOrder, wn); 
filteredData = filtfilt(b, a, double(data)); 
% filteredData = filter(data, 'schroterButt'); 
plot(filteredData); 
title('3rd order Butterworth 600 - 8000Hz')
aesthetics()

subplot(3, 1, 3); 
y_snle = snle(filteredData', 1); 
plot(y_snle)
title('Non-linear Energy Operator')
aesthetics()

%% Quick and dirty spike detection after NEO 
m = mean(y_snle); 
s = std(y_snle); 
multiplier = 12; % this is the crux of the detection 
threshold = m + multiplier*s; 
spikeTrain = y_snle > threshold; 
% this is a much large std than what others had to use...
% but this is because we used NEO
spikeTrain = double(spikeTrain);
numSpike = sum(spikeTrain);

% visualise this threshold 

figure
plot(y_snle)
title('Non-linear Energy Operator')
hold on 
plot([1 length(y_snle)], [threshold threshold], '-')
aesthetics()

% visualise detected spikes 
sumSample = 25000; % we look at number of spikes per second 
spikeTrain = reshape(spikeTrain, sumSample, length(spikeTrain)/sumSample); 
spikeCount = sum(spikeTrain, 1);
imagesc(spikeCount)
figure 
aesthetics() 

%% Prez's method of spike detection 
% mainly based on Wave_clus
% elliptical filter
% no idea what 0.1 and 40 do ...
par.detect_order = 4; % default, no idea why specifically this number
par.ref_ms = 1.5; % refractor period in ms, not sure when this is going to be used...
sr = 25000; % sampling rate 
fmin_detect = 300; 
fmax_detect = 8000;
[b,a] = ellip(par.detect_order,0.1,40,[fmin_detect fmax_detect]*2/sr);
% FiltFiltM does the same thing, but runs slightly faster
% the parameters are default found in wave_clus
filteredData = filtfilt(b, a, double(data)); 
plot(filteredData); 
title('4th order Elliptical Filter 300 - 8000Hz')
aesthetics()

% directly look at filtered data without NEO 
% wave_clus seem to use something slightly more sophisticated than this 
% see amp_detect.m 
% noise_std_detect = median(abs(xf_detect))/0.6745;
med = median(filteredData); 
s = std(filteredData); 
multiplier = 4;
threshold = med - multiplier*s; 
spikeTrain = filteredData < threshold; % negative threshold
spikeTrain = double(spikeTrain);
numSpike = sum(spikeTrain);

% draw threshold 
figure
subplot(10, 1, [3, 10])
plot(filteredData)
title('Non-linear Energy Operator')
hold on 
plot([1 length(y_snle)], [threshold threshold], '-')
aesthetics()

% draw raster
subplot(10, 1, [1, 2])
singleRastPlot(spikeTrain) 



%% Multitaper filter 

% in the works... 


%% Schroter method 







