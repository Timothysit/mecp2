% Main "matlab notebook" without the notebook 

% choose spike file to analyse
spikeFile = uigetfile('.h5', 'Select spike file'); 
spikeTrain = lookAtHfile(spikeFile);

% choose voltage file to analyse 
vFile = uigetfile('.mat', 'Select voltage recording'); 
load(vFile)

% choose electrode to analyse
electrode = 21;
fprintf('Analysing electrode number\n')
% electrodeIndex(electrode + 1)
% there is some shift in electrodeIndex, probably due to the missing 15


%% First we may want to plot the spikes 

% plotSpikes(spikeTrain, electrodeMatrix, electrode); 

%% Autocorrelation 
% still work in progress, will get error if you run it
% https://www.mathworks.com/help/signal/ug/find-periodicity-using-autocorrelation.html
% https://link.springer.com/chapter/10.1007/978-3-642-20853-9_32 
% fs = 25000; % for voltage recording 
fs = 1; % for spikes
[autocor, lags] = xcorr(spikeTrain(:, electrode), fs * 120, 'coeff'); 
plot(lags/fs, autocor)
aesthetics(); 
xlabel('Lag (seconds)')
ylabel('Autocorrelation')

