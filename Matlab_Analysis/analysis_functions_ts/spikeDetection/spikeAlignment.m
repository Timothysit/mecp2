function [spikes, averageSpike] = spikeAlignment(data, spikeTrain)

fs = 25000; 
% duration = fs * 1 * 10^-3; % assume each spike is one millisec 
duration = fs * 2 * 10^-3;

% what we need is to find spike from the spike train 
% if it is a spike, then we plot duration frames around that point 
% then we hold, and search for the next spike

% subplot(1, 2, 1)
spikeTimes = find(spikeTrain == 1);
spikeStore = zeros(length(spikeTimes), 2*round(duration/2)+1); % pre-allocation is paramount here
for i = 1:length(spikeTimes)
     spikePoint = spikeTimes(i);
     % spikeRaw = data(spikePoint - round(duration/2):(spikePoint + round(duration/2))); 
     spikeStore(i, :) = data(spikePoint - round(duration/2):(spikePoint + round(duration/2))); 
     % spikeStore(i, :) = data(spikePoint - floor(duration/2):(spikePoint + floor(duration/2)));
end
% aesthetics()

averageSpike = mean(spikeStore);
spikes = spikeStore; 
%subplot(1, 2, 2)
%title('Average spike')
%plot(averageSpike)
%aesthetics()

end