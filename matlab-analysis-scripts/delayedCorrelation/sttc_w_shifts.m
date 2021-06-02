function sttc_w_shift_results = sttc_w_shifts(cell_1_spike_times, cell_2_spike_times, dtv, ...
                                             shift_windows_to_try, recording_duration, Time)


    sttc_w_shift_results = zeros(length(shift_windows_to_try), 1);

    for n_shift_window = 1:length(shift_windows_to_try)

        shift_time = shift_windows_to_try(n_shift_window);
        cell_2_spike_times_shifted = cell_2_spike_times + shift_time;
        shift_subset_idx = find(cell_2_spike_times_shifted >= 0 & ... 
                                cell_2_spike_times_shifted <= recording_duration); 
        cell_2_spike_times_shifted = cell_2_spike_times_shifted(shift_subset_idx);
        N1v = length(cell_1_spike_times);
        N2v = length(cell_2_spike_times_shifted);

        tileCoef_n1_n2 = sttc(N1v, N2v, dtv, Time, ...
            cell_1_spike_times, cell_2_spike_times_shifted);
        sttc_w_shift_results(n_shift_window) = tileCoef_n1_n2;

    end 


end 