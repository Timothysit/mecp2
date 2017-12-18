% check spike algorithm accuracy 


%% Generate noisy spikes 
fs = 25000;
[signals target r1] = ... 
    generatenoisysamples('Duration', 60, 'SampleRate', fs, 'N_Targets', 1, 'RefractoryPeriod', 0.025);

signals = signals(32:end); % not sure why there is 31 additional samples
sampleRate = 0.001; % let's look at spikes every 1 ms
window = 0+sampleRate:sampleRate:60; 
spikeTimes = target.targettimes;
realSpikeTrain = histc(spikeTimes, window); 

% current the number of spikes is quite high: 6000 spikes in 60 seconds...
% read the manual but there doens't seem to be a way to control the number
% of spikes other than chaning the refractory period...
data = signals'; 
compareSpikeDetect 

