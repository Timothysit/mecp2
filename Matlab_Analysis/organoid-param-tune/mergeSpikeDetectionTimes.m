function spikeTimes = mergeSpikeDetectionTimes(spikeTimes, spikeWaveforms, fs, ... 
    round_decimal_places, diag_plot_path)
%{

Arguments 
    spikeTimes : (cell) 
        cell where each element is a structure corresponding to an electrode, 
        with each field name corresponding to a spike detection method,
        containing a vector with the spike times 
        example: spikeTimes{19}.('threshold') should give a vector with the
        spike times for electrode 19 detected using a method called
        'threshold'
    spikeWaveforms : (cell)
        similar to spikeTimes, but each field contains a matrix 
        of shape (numAlignmentFrames, numSpikes) containing the waveform
        for each detected spike. numAlignmentFrames currently assumed to be
        always 51.
    fs : (int)
        sampling rate of recording in samples/second (Hz)
    round_decimal_places : (int) (optional)
        number of decimal places to round the spike times by, which
        provides a quick hack to bin spikes by a small time window.
        eg. 3 corresponds to binning spikes in 1 ms bins 
      
    diag_plot_path : (str) (optional)
       
%}

if ~exist('round_decimal_places', 'var')
    round_decimal_places = 3;  % 10 ** -x seconds apart from each other
end 

if ~exist('diag_plot_path', 'var')
    diag_plot_path = 0;
end 



num_electrode = length(spikeTimes);

%% Loop through electrodes 
for electrode_idx = 1:num_electrode 
    
    spike_struct = spikeTimes{electrode_idx};
    spike_waveform_struct = spikeWaveforms{electrode_idx};
    spike_detection_methods = fieldnames(spike_struct);
    num_spike_detection_methods = length(spike_detection_methods);


    [intersection_matrix, unique_spike_times] = ... 
        findGroupIntersectSpikes(spike_struct, fs, round_decimal_places);

    % Check at most 1 spike per time bin
    if max(max(intersection_matrix)) > 1
        warning('More than one spike found in a single time bin, something is wrong')
    end 

    method_num_spikes = zeros(num_spike_detection_methods, 1);

    for method_number = 1:numel(spike_detection_methods)
        method_spike_times = spike_struct.(spike_detection_methods{method_number}) / fs;
        method_num_spikes(method_number) = length(method_spike_times);
    end 

    % Check unique spike times equal or greater than method with the most
    % spikes detected 
    if length(unique_spike_times) < max(method_num_spikes)
        warning('Unique spike times from all method is less than a single method, something is wrong')
    end 
    
    % Update spikeTimes with the new combined spikes 
    spikeTimes{electrode_idx}.('all') = unique_spike_times;
    
    
    %% Diagonistic plots
    if diag_plot_path ~= 0
        
        num_intersec_per_time_bin = sum(intersection_matrix, 2); 
        intersec_indices = find(num_intersec_per_time_bin >= 2);
        num_waveform_frames = 51;
        time_rel_to_spike_onset = ((1:num_waveform_frames) - num_waveform_frames/2) / fs;

        multi_spike_time = unique_spike_times(intersec_indices);

        ex_multi_spike_time = multi_spike_time(1);
        spike_detection_method = fieldnames(spike_struct); 
        detection_methods_involved_bool = intersection_matrix(intersec_indices(1), :);
        detection_methods_involved = spike_detection_method(find(detection_methods_involved_bool));
        num_detection_methods_involved = length(detection_methods_involved);

        all_method_method_multi_spike_waveform = zeros(num_detection_methods_involved, num_waveform_frames);


        for method_number = 1:numel(detection_methods_involved)
            method_spike_times = spike_struct.(detection_methods_involved{method_number}) / fs;
            time_diff_from_spike = abs(method_spike_times - ex_multi_spike_time);
            method_multi_spike_idx = find(time_diff_from_spike == min(time_diff_from_spike));
            method_waveforms = spike_waveform_struct.(detection_methods_involved{method_number});
            method_multi_spike_waveform = method_waveforms(:, method_multi_spike_idx);
            all_method_method_multi_spike_waveform(method_number, :) = method_multi_spike_waveform;
        end 

        
        figure('visible','off');
        plot(time_rel_to_spike_onset * 1000, all_method_method_multi_spike_waveform', 'LineWidth', 2);
        legend(detection_methods_involved)
        xlabel('Time relative to spike onset (ms)')
        ylabel('Potential difference (\muV)')
        set(gcf, 'color', 'white')
        title_txt = sprintf('Electrode %.f spike time %.3f s', electrode_idx, ex_multi_spike_time);
        title(title_txt)
        
        % TODO: save figure to folder
        % Save figure
        fig_name = spritnf('electrode_idx_%.f_unique_spike_idx_%.f', ...
            electrode_idx);
        
    end 

    %% Plot intersection matrix 
    if diag_plot_path ~= 0

        fig_save_path = '';

        figure('visible','off');
        subplot(2, 1, 1);
        imagesc(intersection_matrix');
        yticks(1:num_spike_detection_methods);
        yticklabels(spike_detection_methods);
        xlabel('Unique spikes (index)')
        ylabel('Spike detection method')
        subplot(2, 1, 2)

        set(gcf, 'color', 'white')

        % TODO: save figure to folder

    end 
    
end 


end 