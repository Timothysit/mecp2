function [spikeDetectionResult, threshold_val] = getSpikesThreshold(data, params)


%% Initialise things for storing data 

spikeDetectionResult = struct();
spikeDetectionResult.fs = params.fs; 
spikeTimes = struct();


%% Some more spike detection params
fs = params.fs;
multiplier = params.multiplier;
refPeriod_ms = params.refPeriod_ms;

lowpass = 600;
highpass = 8000;
wn = [lowpass highpass] / (fs / 2);
filterOrder = 3;
[b, a] = butter(filterOrder, wn);

threshold_val = zeros(length(params.channels), 1);

%% Spike detection 

num_channel = length(params.channels);

for channel_idx = 1:num_channel
   
    channel_trace = data(:, channel_idx);
    filteredData = filtfilt(b, a, double(channel_trace));
    
    % s = median of the absolute deviation from the mean, divided by 0.6745
    s = median(abs(filteredData - mean(filteredData))) / 0.6745;
    m = mean(filteredData);

    
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
    
    threshold_val(channel_idx) = threshold;
    
end


% Impose the refractory period (ms)
refPeriod = refPeriod_ms * 10^-3 * fs;
for i = 1:length(spikeTrain)
    if spikeTrain(i) == 1
        refStart = i + 1;
        refEnd = round(i + refPeriod);
        if refEnd > length(spikeTrain)
            spikeTrain(refStart:length(spikeTrain)) = 0;
        else
            spikeTrain(refStart:refEnd) = 0;
        end
    end
end



%% Compile spike detection result

spikeDetectionResult.spikeTimes = spikeTimes;
spikeDetectionResult.method = 'threshold';
spikeDetectionResult.params = params;


end 


