function [spikeDetectionResult, threshold_val] = getSpikesThreshold(data, params)




%% Initialise things for storing data 

spikeDetectionResult = struct();
spikeDetectionResult.fs = params.fs; 
spikeTimes = struct();


%% Some more spike detection params
lowpass = 600;
highpass = 8000;
wn = [lowpass highpass] / (fs / 2);
filterOrder = 3;
[b, a] = butter(filterOrder, wn);

%% Spike detection 

num_channel = length(params.channels);

for channel_idx = 1:num_channel
   
    channel_trace = data(:, channel_idx);
    filteredData = filtfilt(b, a, double(channel_trace));
    
    % Calculate threshold 
    if isfield(params, 'threshold')
        if ~isempty(params.threshold)
            threshold = params.threshold(channel_idx);
        else
            threshold = m - multiplier * s;
        end 
    else
        threshold = m - multiplier * s;
    end 
    
    % Detect spikes (defined as threshold crossings)
    spikeTrain = filteredData < threshold;
    spikeFrames = find(spikeTrain);
    channelSpikeTimes = spikeFrames / fs;
    
    spikeTimes.(strcat('channel', num2str(params.channels(channel_idx)))) ...
        = channelSpikeTimes;
    
end




%% Compile spike detection result

spikeDetectionResult.spikeTimes = spikeTimes;
spikeDetectionResult.method = 'threshold';
spikeDetectionResult.params = params;


end 


