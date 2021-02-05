function spike_matrix = spikeTimeToMatrix2(spikeTimesStruct, ...
start_time, end_time, spike_detection_method, sampling_rate)

% channel_names = fieldnames(spikeTimesStruct);
bin_edges = start_time:1/sampling_rate:end_time;

num_bins = length(bin_edges) - 1; 
num_channels = length(spikeTimesStruct);
spike_matrix = zeros(num_bins, num_channels);

for channel_idx = 1:num_channels
    channel_spike_times = spikeTimesStruct{channel_idx}.(spike_detection_method);
    spike_vector = histcounts(channel_spike_times, bin_edges);
    spike_matrix(:, channel_idx) = spike_vector;
end 

end 