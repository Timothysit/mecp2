function spikeTimes = spikeMatrixToTimes(spikeMatrix, fs, channel_names)
% Convert spike matrix to spike times (in seconds)
% Parameters
% -----------
% spikeMatrix : (double matrix) of dimensions (numSamples, numChanels)
% fs : (int) sampling rate
% Output
% ----------
% spikeTimes : (structure)
% structure where the field is the name of the channel 
% and the entry is a vector of spike times
% NOTE: 
% ---------
% this assumes that sampling rate is high enough such that 
% there are rarely / no more than one spike in each frame

% loop through each channel to get spike times 

num_channel = size(spikeMatrix, 2);


if ~exist('channel_names', 'var')
    channel_names = 1:num_channel;
end 

spikeTimes = struct();

for channel_idx = 1:num_channel

    channel_spikes = spikeMatrix(:, channel_idx);
    spike_frames = find(channel_spikes >= 1);
    channel_spike_times = spike_frames / fs;
    channel_name = strcat('channel', num2str(channel_names(channel_idx)));
    spikeTimes.(channel_name) = channel_spike_times;
    
end


end 