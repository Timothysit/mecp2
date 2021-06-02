function corrcoef_given_shift = binned_corr_w_shift(cell_1_spike_times, cell_2_spike_times, ...
    bin_width, recording_duration, shift_windows_to_try, conv_vec)

    if ~exist('conv_vec', 'var')
        conv_vec = 0;
    end 



   
    edges = 0:bin_width:recording_duration;
    [cell_1_binned_fr, ~] = histcounts(cell_1_spike_times, edges);
    
    if conv_vec ~= 0
        cell_1_binned_fr = conv(cell_1_binned_fr, conv_vec);
    end 
 

    corrcoef_given_shift = zeros(length(shift_windows_to_try), 1);

    for n_shift_window = 1:length(shift_windows_to_try)

        shift_time = shift_windows_to_try(n_shift_window);
        cell_2_spike_times_shifted = cell_2_spike_times + shift_time;
        shift_subset_idx = find(cell_2_spike_times_shifted >= 0 & ... 
                                cell_2_spike_times_shifted <= recording_duration); 
        cell_2_spike_times_shifted = cell_2_spike_times_shifted(shift_subset_idx);

        [cell_2_binned_fr_shifted, ~] = histcounts(cell_2_spike_times_shifted, edges);
        
        if conv_vec ~= 0 
            cell_2_binned_fr_shifted = conv(cell_2_binned_fr_shifted, conv_vec);
        end 

        corrcoef_r = corrcoef(cell_1_binned_fr, cell_2_binned_fr_shifted);
        corrcoef_given_shift(n_shift_window) = corrcoef_r(1, 2);

    end 

end 