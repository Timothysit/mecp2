%% Test script to look at appyling multiple wavelet to detect spikes 

% note I assume you run this script in analys_function_ts/spikeDetection 
% otherwise addPath

%% Load raw data
raw_data_path = '/home/timsit/mecp2/data/PAT200219_2C_DIV170002.mat';
raw_data = load(raw_data_path);
raw_traces = raw_data.dat;
fs = raw_data.fs;

%% Filter data 

% Filter signal 
lowpass = 600; 
highpass = 8000; 
wn = [lowpass highpass] / (fs / 2); 
filterOrder = 3;
[b, a] = butter(filterOrder, wn); 
filteredData = filtfilt(b, a, double(raw_traces)); 


%% Select a single trace to test things
channel_number = 13;
channel_trace = filteredData(:, channel_number);

figure()
plot(channel_trace)

%% Apply multiple wavelet methods on that one channel

Wid = [0.5, 1.0];
Ns = 5; % Ns - (scalar): the number of scales to use in detection (Ns >= 2);
option = 'c';
L = 0;

    
PltFlg = 0; 
CmtFlg = 0; 
%   PltFlg - (integer) is the plot flag: 
%   PltFlg = 1 --> generate figures, otherwise do not;
%  
%   CmtFlg - (integer) is the comment flag, 
%   CmtFlg = 1 --> display comments, otherwise do not;

wname_list = {'bior1.5', 'haar', 'bior1.3', 'db2'};
spike_struct = struct;

for wname = wname_list
    
    wname = char(wname);

    spikeFrames = detect_spikes_wavelet(channel_trace, fs/1000, ... 
        Wid, Ns, option, L, wname, PltFlg, CmtFlg); 
    
    % we can't use '.' as a field name
    valid_wname = strrep(wname, '.', 'p');
    spike_struct.(valid_wname) = spikeFrames;
    
    % spikeTrain = zeros(size(data)); 
    % spikeTrain(spikeFrames) = 1;
end 


%% Save spike detection results 
save('multi_wavelet_single_channel.mat', 'spike_struct');

%% Load spike detection results

spike_detection_result_path = 'multi_wavelet_single_channel.m';
load(spike_detection_result_path)

%% Plot the channel trace and the spike detected from each wavelet method

figure()

wavelet_method_used = fieldnames(spike_struct);


% plot the filtered trace 
plot(channel_trace)
hold on;

offset = max(channel_trace);

for method_number = 1:numel(wavelet_method_used)
    scatter(spike_struct.(wavelet_method_used{method_number}), ... 
        repmat(offset + method_number, ... 
        length(spike_struct.(wavelet_method_used{method_number})), 1));
   hold on;
end 

legend_labels = [{'Filtered data'}; wavelet_method_used];
legend(legend_labels);

% ylim([0, 5])

%% Extension of the above: also plot the moving average spike count 

moving_average_dur_in_sec = 10;
moving_average_window_frame = moving_average_dur_in_sec * fs;

figure()
ax1 = subplot(3, 1, 1);

for method_number = 1:numel(wavelet_method_used)
    spike_train = zeros(length(channel_trace), 1);
    spike_train(spike_struct.(wavelet_method_used{method_number})) = 1;
    spike_count_moving_mean = movmean(spike_train, moving_average_window_frame);
    plot(spike_count_moving_mean)
    hold on;
end 

legend(wavelet_method_used)

ylabel('Moving average spike count')

ax2 = subplot(3, 1, [2, 3]);
% plot the filtered trace 
plot(channel_trace)
hold on;

offset = max(channel_trace);

for method_number = 1:numel(wavelet_method_used)
    scatter(spike_struct.(wavelet_method_used{method_number}), ... 
        repmat(offset + method_number, ... 
        length(spike_struct.(wavelet_method_used{method_number})), 1));
   hold on;
end 

legend_labels = [{'Filtered data'}; wavelet_method_used];
legend(legend_labels);
ylabel('Filtered signal value')
xlabel('Time (frames)')

linkaxes([ax1, ax2], 'x');

% TODO: generalise this
sgtitle('Detected spikes from channel 15')

%% Find matching spike times from all method and unique ones from each method 
round_decimal_places = 3;
[intersection_matrix, unique_spike_times] = ... 
    findGroupIntersectSpikes(spike_struct, fs, round_decimal_places);

figure()
% heatmap(intersection_matrix')
imagesc(intersection_matrix')
xlabel('Spike number')
yticks(1:length(wavelet_method_used));
yticklabels(wavelet_method_used)
ylabel('Wavelet used')

%% Plot interspike interval distribution of unique spikes detected by all methods
% this help look at whether there are a large amount of very tiny 
% time differences, which suggest that some wavelets are detecting 
% the same spike with a very tiny offset


figure()
unique_spike_isi = diff(unique_spike_times);
edges = linspace(min(unique_spike_isi), 1, 1000);
histogram(unique_spike_isi, edges)
title('ISI distribution of spikes from all wavelets')
xlabel('Inter-spike interval (seconds)')
ylabel('Number of intervals');




%% Plot the average waveform of spikes detected by all methods


% Plot spikes that are shared by all wavelet methods

all_shared_spike_idx = find(sum(intersection_matrix, 2) == ... 
    length(wavelet_method_used));

all_shared_spike_times = unique_spike_times(all_shared_spike_idx);

edges = linspace(0, length(channel_trace) / fs, length(channel_trace)+1);
spikeTrain = histcounts(all_shared_spike_times, edges);
alignment_duration = 0.01;
fs = 25000;

[spikeWaves, averageSpike] = spikeAlignment(channel_trace, spikeTrain, ... 
    fs, alignment_duration);

peak_alignment_duration = 0.002;
spike_aligment_method = 'peakghost';
figure()
plotSpikeAlignment(spikeWaves, spike_aligment_method, ...
    fs, peak_alignment_duration)
xlabel('Time bins')
ylabel('Filtered amplitude')
title('Waveform of spikes detected by all wavelets')


%% Plot all spikes waveform detected by each method 
figure()
for wavelet_n = 1:numel(wavelet_method_used)
    subplot(1, numel(wavelet_method_used), wavelet_n)
    
    spike_idx_given_wavelet = find(...
    (intersection_matrix(:, wavelet_n) == 1) ... 
);

    spike_times_given_wavelet = unique_spike_times(spike_idx_given_wavelet);

    if length(spike_times_given_wavelet) >= 3
        spikeTrain = histcounts(spike_times_given_wavelet, edges);

        [spikeWaves, averageSpike] = spikeAlignment(channel_trace, spikeTrain, ... 
            fs, alignment_duration);
        plotSpikeAlignment(spikeWaves, spike_aligment_method, ...
            fs, peak_alignment_duration)
        xlabel('Time bins')
        ylabel('Filtered amplitude')

        title(wavelet_method_used{wavelet_n});
    end 
    
end

sgtitle('All spikes detected by each wavelet')

%% Plot waveform detected by uniquely by each method
% loop through each method and plot spike waveform 
% that is detected only by that method
% note that this block inherits the parameters from above
figure()
for wavelet_n = 1:numel(wavelet_method_used)
    subplot(1, numel(wavelet_method_used), wavelet_n)
    
    spike_idx_unique_to_wavelet = find(...
    (sum(intersection_matrix, 2) == 1) & ...
    (intersection_matrix(:, wavelet_n) == 1) ... 
);

    spike_times_unique_to_wavelet = unique_spike_times(spike_idx_unique_to_wavelet);

    if length(spike_times_unique_to_wavelet) >= 3
        spikeTrain = histcounts(spike_times_unique_to_wavelet, edges);

        [spikeWaves, averageSpike] = spikeAlignment(channel_trace, spikeTrain, ... 
            fs, alignment_duration);
        plotSpikeAlignment(spikeWaves, spike_aligment_method, ...
            fs, peak_alignment_duration)
        xlabel('Time bins')
        ylabel('Filtered amplitude')

        title(wavelet_method_used{wavelet_n});
    end 
    
end

sgtitle('Spikes detected uniquely by each wavelet')


%% Plot how much each method agree with each other

% not quite sure what's the best way to plot venn / Euler 
% alternative diagrams in matlab, using Python for this for now

