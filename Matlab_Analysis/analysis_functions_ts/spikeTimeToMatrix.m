function spike_matrix = spikeTimeToMatrix(spikeTimesStruct, start_time, ...
    end_time, sampling_rate, recording_fs)

% recording_fs (optional) : (int)
% If this argument is provided, then spikeTimes are in frames rather than
% in seconds, and the spike time in second is obtained by dividing
% spikeFrames by recordign_fs

if ~exist('recording_fs', 'var')
    recording_fs = 0;
end 

bin_edges = start_time:1/sampling_rate:end_time;
num_bins = length(bin_edges) - 1; 


if isstruct(spikeTimesStruct)
    channel_names = fieldnames(spikeTimesStruct);
    num_channels = length(channel_names);
    spike_matrix = zeros(num_bins, num_channels);
    for channel_idx = 1:numel(channel_names)
        channel_spike_times = spikeTimesStruct.(channel_names{channel_idx});
       
        if recording_fs ~= 0
            channel_spike_times = channel_spike_times / recording_fs;
        end 
        
        spike_vector = histcounts(channel_spike_times, bin_edges);
        spike_matrix(:, channel_idx) = spike_vector;
    end 

elseif iscell(spikeTimesStruct)
    % 2020-11-18 New Jeremi file format: cell of structures
    spikeTimesCell = spikeTimesStruct;
    num_channels = length(spikeTimesCell);
    spike_matrix = zeros(num_bins, num_channels);
    for channel_num = 1:length(spikeTimesCell)
        channel_spike_times = spikeTimesCell{channel_num}.('mea');
        
        if recording_fs ~= 0
            channel_spike_times = channel_spike_times / recording_fs;
        end 
        
        spike_vector = histcounts(channel_spike_times, bin_edges);
        spike_matrix(:, channel_num) = spike_vector;
    end 
    
    
end 

end 
