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

spike_detection_result_path = 'multi_wavelet_single_channel.mat';
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

frames = 1:size(channel_trace, 1);
time_in_milliseconds = frames / fs * 1000;

figure()
ax1 = subplot(3, 1, 1);

for method_number = 1:numel(wavelet_method_used)
    spike_train = zeros(length(channel_trace), 1);
    spike_train(spike_struct.(wavelet_method_used{method_number})) = 1;
    spike_count_moving_mean = movmean(spike_train, moving_average_window_frame);
    plot(time_in_milliseconds, spike_count_moving_mean)
    hold on;
end 

legend(wavelet_method_used)

ylabel('Moving average spike count')

ax2 = subplot(3, 1, [2, 3]);
% plot the filtered trace 
plot(time_in_milliseconds, channel_trace)
hold on;

offset = max(channel_trace);

for method_number = 1:numel(wavelet_method_used)
    scatter(spike_struct.(wavelet_method_used{method_number}) / fs * 1000, ... 
        repmat(offset + method_number, ... 
        length(spike_struct.(wavelet_method_used{method_number})), 1));
   hold on;
end 

legend_labels = [{'Filtered data'}; wavelet_method_used];
legend(legend_labels);
ylabel('Filtered signal value')
xlabel('Time (frames)')

linkaxes([ax1, ax2], 'x');

% TODO: add a scalebar to show 1 ms 
% scalebar(1)

% TODO: generalise this
sgtitle('Detected spikes from channel 15')




%% Find matching spike times from all method and unique ones from each method 
round_decimal_places = 0; % 1 / 1000;
round_method = 'nearest_to_value';
[intersection_matrix, unique_spike_times] = ... 
    findGroupIntersectSpikes(spike_struct, fs, round_decimal_places, ...
round_method);

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

%% Only plot spikes if ISI is below a certain value, to check at what time scale they need merging
%% TODO: this is WIP, need to use the unique spike instead of consider each wavelet
max_isi = 1 / 1000;
moving_average_dur_in_sec = 10;
moving_average_window_frame = moving_average_dur_in_sec * fs;

frames = 1:size(channel_trace, 1);
time_in_milliseconds = frames / fs * 1000;

figure()
ax1 = subplot(3, 1, 1);

for method_number = 1:numel(wavelet_method_used)
    spike_train = zeros(length(channel_trace), 1);
    spike_train(spike_struct.(wavelet_method_used{method_number})) = 1;
    spike_count_moving_mean = movmean(spike_train, moving_average_window_frame);
    plot(time_in_milliseconds, spike_count_moving_mean)
    hold on;
end 

legend(wavelet_method_used)

ylabel('Moving average spike count')

ax2 = subplot(3, 1, [2, 3]);
% plot the filtered trace 
plot(time_in_milliseconds, channel_trace)
hold on;

offset = max(channel_trace);

for method_number = 1:numel(wavelet_method_used)
    wavelet_spike_times = spike_struct.(wavelet_method_used{method_number}) / fs;
    
    for n_spike = 1:length(wavelet_spike_times)
        
        if (n_spike >= 2) && (n_spike < length(wavelet_spike_times))
            
            curr_spike_time = wavelet_spike_times(n_spike);
            prev_spike_time = wavelet_spike_times(n_spike - 1);
            next_spike_time = wavelet_spike_times(n_spike +  1);
            
            match_prev_spike = (curr_spike_time - prev_spike_time) <= max_isi;
            match_next_spike = (next_spike_time - curr_spike_time) <= max_isi;
            
            if match_prev_spike || match_next_spike
                scatter(curr_spike_time, offset + method_number);
            end 
            
        end 
        
    end 
    
    % scatter(spike_struct.(wavelet_method_used{method_number}) / fs * 1000, ... 
    %    repmat(offset + method_number, ... 
    %     length(spike_struct.(wavelet_method_used{method_number})), 1));
   hold on;
end 

legend_labels = [{'Filtered data'}; wavelet_method_used];
legend(legend_labels);
ylabel('Filtered signal value')
xlabel('Time (frames)')

linkaxes([ax1, ax2], 'x');

% TODO: add a scalebar to show 1 ms 
% scalebar(1)

% TODO: generalise this
sgtitle('Detected spikes from channel 15')



%% Try different values of merging spikes and plot the ISI histogram
round_values = [0, 0.10/1000, 0.25/1000, 0.5/1000, 1/1000, 2/1000, 3/1000, 5/1000, 10/1000];
round_method = 'nearest_to_value';

spike_time_cell = cell(length(round_values), 2);
unique_spikes_after_merging = zeros(length(round_values), 1);


for n_round_value = 1:length(round_values)
    round_v = round_values(n_round_value);
    [intersection_matrix, unique_spike_times] = ... 
        findGroupIntersectSpikes(spike_struct, fs, round_v, ...
    round_method);

    spike_time_cell{n_round_value, 1} = intersection_matrix;
    spike_time_cell{n_round_value, 2} = unique_spike_times;
    unique_spikes_after_merging(n_round_value) = size(intersection_matrix, 1);
end 


% 0 ISI can be removed I think, but include for now for bug check 


% Also look at the ISI within each spike detection method 
% to see when we begin to merge spikes detected by the same method 
min_spike_isi_given_method = zeros(length(wavelet_method_used), 1);
for method_number = 1:numel(wavelet_method_used)
    wavelet_spike_times = spike_struct.(wavelet_method_used{method_number}) / fs;
    wavelet_spike_times_isi = diff(wavelet_spike_times);
    min_spike_isi_given_method(method_number) = min(wavelet_spike_times_isi);
end 


%% Try different values of merging spikes and plot number of unique spikes after merging

figure()
plot(round_values, unique_spikes_after_merging)
hold on
scatter(round_values, unique_spikes_after_merging)

for method_number = 1:numel(wavelet_method_used)
    xline(min_spike_isi_given_method(method_number));
end 


xlabel('Rounding value (s)')
ylabel('Number of unique spikes')

%% Try different values of merging spikes and plot proportion of neighbour spike with 
% exactly the same amplitude 

edges = linspace(0, length(channel_trace) / fs, length(channel_trace)+1);
spikeTrain = histcounts(unique_spike_times, edges);
alignment_duration = 0.01;
fs = 25000;

% for each unique spike, find the closest peak and get it's location and
% amplitude

[spikeWaves, averageSpike] = spikeAlignment(channel_trace, spikeTrain, ... 
    fs, alignment_duration);

[peak_amplitude, peak_loc] = find_peak_amplitude(spikeWaves);

peak_amplitude_diff = diff(peak_amplitude);
prop_neighbour_amplitude_same = sum(peak_amplitude_diff == 0) / length(peak_amplitude_diff);


%% Do the above loop through the different merging values
alignment_duration = 1.5 / 1000;

round_values = [0, 0.10/1000, 0.25/1000, 0.5/1000, 1/1000, 2/1000, 3/1000, 5/1000, 10/1000];
round_method = 'nearest_to_value';

spike_time_cell = cell(length(round_values), 2);
unique_spikes_after_merging = zeros(length(round_values), 1);

prop_neighbour_amplitude_same_store = zeros(length(round_values), 1);

for n_round_value = 1:length(round_values)
    round_v = round_values(n_round_value);
    [intersection_matrix, unique_spike_times] = ... 
        findGroupIntersectSpikes(spike_struct, fs, round_v, ...
    round_method);

    spikeTrain = histcounts(unique_spike_times, edges);
    [spikeWaves, averageSpike] = spikeAlignment(channel_trace, spikeTrain, ... 
    fs, alignment_duration);

    [peak_amplitude, peak_loc] = find_peak_amplitude(spikeWaves);
    
    peak_amplitude_diff = diff(peak_amplitude);
    prop_neighbour_amplitude_same = sum(peak_amplitude_diff == 0) / length(peak_amplitude_diff);
    prop_neighbour_amplitude_same_store(n_round_value) = prop_neighbour_amplitude_same;
    
end 

figure()
plot(round_values, prop_neighbour_amplitude_same_store)
hold on;
scatter(round_values, prop_neighbour_amplitude_same_store)
ylabel({'Proportion of spikes with the same amplitude'; 'within 1 ms window'})
xlabel('Rounding value (s)')


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
plotSpikeAlignment(spikeWaves, spike_aligment_method, fs, peak_alignment_duration)
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
        
        % turn x axis to time relative to spike peak
        
        xlabel('Time relative to spike peak (ms)')
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

custom_wavelet_names = {'bior1.5', 'haar', 'bior1.3', 'db2'};

ax = [];
for wavelet_n = 1:numel(wavelet_method_used)
    ax(wavelet_n) = subplot(1, numel(wavelet_method_used), wavelet_n);
    
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
        % xlabel('Time bins')
        xlabel('Time relative to spike peak (ms)')
        ylabel('Filtered amplitude')

        % title(wavelet_method_used{wavelet_n});
        title(custom_wavelet_names{wavelet_n});
    end 
    
    set(gca, 'TickDir', 'out')
    box off;
    
end

set(ax([2:end]),'ycolor','none');
set(ax([2:end]),'xcolor','none');

linkaxes(ax(:), 'y');

sgtitle('Spikes detected uniquely by each wavelet')

set(gcf,'color','w');

% save figure
save_folder = '/home/timsit/mecp2/figures/multiwavelet-detection/';
set(gcf, 'PaperUnits', 'inches');
x_width=8 ;y_width=4;
set(gcf, 'PaperPosition', [0 0 x_width y_width]); %
% print -r900
file_name = 'unique_spike_waveforms_detected_highrest.png';
% saveas(gcf, fullfile(save_folder, file_name))

print(gcf,fullfile(save_folder, file_name),'-dpng','-r1200'); 

%% Merging spikes 




%% Plot how much each method agree with each other

% not quite sure what's the best way to plot venn / Euler 
% alternative diagrams in matlab, using Python for this for now

