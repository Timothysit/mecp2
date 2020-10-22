%% Define file to find best params 

% File locations 
raw_data_folder = '/media/timsit/Seagate Expansion Drive/The_Mecp2_Project/organoid_data/mat/';
wavelet_spike_folder = '/media/timsit/Seagate Expansion Drive/The_Mecp2_Project/organoid_data/spikes/CWT_param_search/all_duration/';
threshold_spike_folder = '/media/timsit/Seagate Expansion Drive/The_Mecp2_Project/organoid_data/spikes/thresholdParamSearch/';
summary_plot_folder = '/media/timsit/Seagate Expansion Drive/The_Mecp2_Project/organoid_data/spikes/';

% Params 
max_tolerable_spikes_in_TTX = 100;
max_tolerable_spikes_in_grounded = 100;
start_time = 0;
end_time = 600;
sampling_rate = 1;
threshold_ground_electrode_name = 15;
min_spike_per_electrode_to_be_active = 5;

%% Loop through each file 

recording_names = {dir([raw_data_folder '*.mat']).name};
recording_names_exclude_TTX = {};
selected_detection_method = {};


for r_name_idx = 1:length(recording_names)
    if ~contains(recording_names{r_name_idx}, 'TTX')
        recording_names_exclude_TTX{end+1} = recording_names{r_name_idx};

    end 
end 

TTX_used = num2cell(zeros(length(recording_names_exclude_TTX), 1));  % This can be pre-allocated
best_param_file = num2cell(zeros(length(recording_names_exclude_TTX), 1));
num_active_electrodes = num2cell(zeros(length(recording_names_exclude_TTX), 1));

f1 = figure();

for r_name_idx = 1:length(recording_names_exclude_TTX)
    
    [pathstr, recording_name, ext] = fileparts(recording_names_exclude_TTX{r_name_idx});
    
    fprintf('Looking at recording: %s \n', recording_name)
    
    % Loop through wavelet spike folder 
    wavelet_spike_detection_results_names = {dir([wavelet_spike_folder, strcat(recording_name, '*')]).name};
    
    wavelet_spike_detection_info = zeros(length(wavelet_spike_detection_results_names), 3);
    
    for file_idx = 1:length(wavelet_spike_detection_results_names)
        file_name = wavelet_spike_detection_results_names{file_idx};
        param_file = load([wavelet_spike_folder file_name]);
        wavelet_spike_matrix = spikeTimeToMatrix(param_file.spikeDetectionResult.spikeTimes, start_time, end_time, sampling_rate);
        total_spikes = sum(sum(wavelet_spike_matrix));
        L_param = param_file.spikeDetectionResult.params.L;
        wavelet_spike_detection_info(file_idx, 1) = L_param;
        wavelet_spike_detection_info(file_idx, 2) = total_spikes;
        wavelet_spike_detection_info(file_idx, 3) = contains(file_name, 'TTX');
        wavelet_spike_detection_info(file_idx, 4) = file_idx;
         
    end 
    
    if sum(wavelet_spike_detection_info(:, 3)) == 0
        fprintf('No TTX files found, using a pre-determined parameter file \n');
        % TODO: decide on which file to use
        wavelet_best_param_file_name = nan;
    else
        TTX_used{r_name_idx} = 1;
        ttx_info_idx = find(wavelet_spike_detection_info(:, 3) == 1);
        ttx_info = wavelet_spike_detection_info(ttx_info_idx, :);
        ttx_info_spike_okay_idx = find(ttx_info(:, 2) < max_tolerable_spikes_in_TTX);
        ttx_info_spike_okay_param = ttx_info(ttx_info_spike_okay_idx, 1);
            
        if isempty(ttx_info_spike_okay_param)
            fprintf('None of the wavelet parameters has false positive rate below threshold \n')
            fprintf('Skipping wavelet step and flagging this recording \n')
            wavelet_best_param_file_name = nan;
            % TODO: flag this recording
        elseif length(ttx_info_spike_okay_param) == 1
             % just one param meet the criteria
             fprintf('Only one CWT parameter meet the false positive rate criteria \n')
             best_param_file_idx = find( ...
                    (wavelet_spike_detection_info(:, 1) == ttx_info_spike_okay_param) & ...
                    (wavelet_spike_detection_info(:, 3) == 0));
             % use that index to copy somewhere
             wavelet_best_param_file_name = wavelet_spike_detection_results_names{best_param_file_idx};
        else
             % find the param that maximises spikes detected
             okay_param_info_idx = find( ...
                    ismember(wavelet_spike_detection_info(:, 1), ttx_info_spike_okay_param) & ...
                    wavelet_spike_detection_info(:, 3) == 0);
             okay_param_info = wavelet_spike_detection_info(okay_param_info_idx, :);
             best_param_idx = find(okay_param_info(:, 2) == max(okay_param_info(:, 2)));
             best_param = okay_param_info(best_param_idx, 1);
             best_param_file_idx = find(wavelet_spike_detection_info(:, 1) == best_param & ... 
             wavelet_spike_detection_info(:, 3) == 0);
             wavelet_best_param_file_name = wavelet_spike_detection_results_names{best_param_file_idx};
             fprintf('Wavelet best param value found \n')
        end 
            
    end 
    
    % Loop through threshold spike folder 
    threshold_spike_detection_results_names= {dir([threshold_spike_folder, strcat(recording_name, '*')]).name};
    threshold_spike_detection_info = zeros(length(threshold_spike_detection_results_names), 5);
    
    for file_idx = 1:length(threshold_spike_detection_results_names)
        threshold_file_name = threshold_spike_detection_results_names{file_idx};
        threshold_param_file = load([threshold_spike_folder threshold_file_name]);
        threshold_spike_matrix = spikeTimeToMatrix(...
            threshold_param_file.spikeDetectionResult.spikeTimes, ...
            start_time, end_time, sampling_rate);
        total_spikes = sum(sum(threshold_spike_matrix));
        multiplier_param = threshold_param_file.spikeDetectionResult.params.multiplier;
        ground_electrode_spikes = length( ...
        threshold_param_file.spikeDetectionResult.spikeTimes.( ... 
        strcat('channel', num2str(threshold_ground_electrode_name))));
        
        threshold_spike_detection_info(file_idx, 1) = multiplier_param;
        threshold_spike_detection_info(file_idx, 2) = total_spikes;
        threshold_spike_detection_info(file_idx, 3) = contains(threshold_file_name, 'TTX');
        threshold_spike_detection_info(file_idx, 4) = file_idx;
        threshold_spike_detection_info(file_idx, 5) = ground_electrode_spikes;
         
    end 
    
    % Subset to parameters where grounded electrode have fewer than
    % maximum allowable spikes 
    subset_threshold_spike_detection_info_idx = find( ...
        threshold_spike_detection_info(:, 5) < max_tolerable_spikes_in_grounded);
    subset_threshold_spike_detection_info = threshold_spike_detection_info(... 
        subset_threshold_spike_detection_info_idx, :);
    
    if isempty(subset_threshold_spike_detection_info)
        fprintf('None of the threshold param meet the grounded electrode criteria, flagging recording \n')
        threshold_best_param_file_name = nan;
    elseif sum(subset_threshold_spike_detection_info(:, 3)) == 0
        TTX_used{r_name_idx} = 1;
        fprintf('No TTX files found, using grounded electrode to set find best param \n');
        % TODO: decide on which file to use
        best_param_idx = find(subset_threshold_spike_detection_info(:, 2)...
            == max(subset_threshold_spike_detection_info(:, 2)));
        best_param = subset_threshold_spike_detection_info(best_param_idx, 1);
        best_param_file_idx = find(threshold_spike_detection_info(:, 1) == best_param & ... 
             threshold_spike_detection_info(:, 3) == 0);
        threshold_best_param_file_name = threshold_spike_detection_results_names{best_param_file_idx};
        
    else
        ttx_criteria_meet_idx = find(...
            (subset_threshold_spike_detection_info(:, 3) == 1) & ...
            (subset_threshold_spike_detection_info(:, 2) < max_tolerable_spikes_in_TTX));
        ttx_criteria_meet_params = subset_threshold_spike_detection_info(ttx_criteria_meet_idx, 1);
        % ttx_criteria_meet_subset_threshold_spike_detection_info_idx = find( ...
        % ismember(subset_threshold_spike_detection_info(:, 1), ttx_criteria_meet_idx));
        % ttx_criteria_meet_subset_threshold_spike_detection_info = ...
        %     ttx_criteria_meet_subset_threshold_spike_detection_info(subset_threshold_spike_detection_info, :);
        not_ttx_and_criteria_meet_idx = find(...
            (subset_threshold_spike_detection_info(:, 3) == 0) & ...
            ismember(subset_threshold_spike_detection_info(:, 1), ttx_criteria_meet_params));
        not_ttx_max_spikes = max(subset_threshold_spike_detection_info(not_ttx_and_criteria_meet_idx, 2));
        best_param_idx = find(...
            (subset_threshold_spike_detection_info(:, 3) == 0) & ... % Not TTX
            (subset_threshold_spike_detection_info(:, 2) == not_ttx_max_spikes) & ... % Max spikes 
            ismember(subset_threshold_spike_detection_info(:, 1), ttx_criteria_meet_params)); % TTX criteria met
        best_param = subset_threshold_spike_detection_info(best_param_idx, 1);
        best_param_file_idx = find(threshold_spike_detection_info(:, 1) == best_param & ... 
             threshold_spike_detection_info(:, 3) == 0);
        threshold_best_param_file_name = threshold_spike_detection_results_names{best_param_file_idx};
    end 
    
    if (length(wavelet_spike_detection_results_names) == 0) && (length(threshold_spike_detection_results_names) == 0)
        fprintf('No spike detection files found, skipping. \n')
        selected_detection_method{end+1} = nan;
        best_param_file{r_name_idx} = nan;
    elseif (length(wavelet_spike_detection_results_names) == 0)
        fprintf('Only threshold spike found, using that by default \n')
        selected_detection_method{end+1} = 'Threshold';
        best_param_file{r_name_idx} = threshold_best_param_file_name;
    elseif (length(threshold_spike_detection_results_names) == 0)
        fprintf('Only wavelet spike found, using that by default \n')
        selected_detection_method{end+1} = 'Wavelet';
        best_param_file{r_name_idx} = wavelet_best_param_file_name;
    elseif sum(~isnan(wavelet_best_param_file_name)) & sum(~isnan(threshold_best_param_file_name))
        fprintf('Both wavelet and threshold files found, comparing the two \n')
        selected_detection_method{end+1} = 'Wavelet';
        
        wavelet_best_param_file_data = load([wavelet_spike_folder wavelet_best_param_file_name]);
        threshold_best_param_file_data = load([threshold_spike_folder threshold_best_param_file_name]);
        wavelet_spike_matrix = spikeTimeToMatrix(wavelet_best_param_file_data.spikeDetectionResult.spikeTimes, start_time, end_time, sampling_rate);
        threshold_spike_matrix = spikeTimeToMatrix(threshold_best_param_file_data.spikeDetectionResult.spikeTimes, start_time, end_time, sampling_rate);
        
        % Total spikes over time (all electrodes)
        subplot(1, 2, 1)
        threshold_spike_over_t = sum(threshold_spike_matrix, 2);
        wavelet_spike_over_t = sum(wavelet_spike_matrix, 2);
        plot(threshold_spike_over_t)
        hold on
        plot(wavelet_spike_over_t)
        xlabel('Time')
        ylabel('Spikes over all electrodes')
        legend('Threshold', 'Wavelet')
        hold on 
        
        % Correlation
        subplot(1, 2, 2)
        [corr_r, corr_pval] = corr(wavelet_spike_matrix, threshold_spike_matrix);
        corr_diagonal = diag(corr_r);
        scatter(1:length(corr_diagonal), corr_diagonal);
        yline(nanmean(corr_diagonal)); 
        xlabel('Channel index')
        ylabel('Correlation between wavelet and threshold detection method') 
        % Common title
        sgtitle(recording_name,  'Interpreter', 'none');
        set(gcf,'color','w');
        fprintf('Press any key to continue ... \n')
        pause;
        clf('reset')
        
        % TODO: determine condition where threshold method is preferred
        % Use wavelet detection by default 
        best_param_file{r_name_idx} = wavelet_best_param_file_name;
        
        % Calculate number of active electrodes 
        num_spike_per_electrode = sum(wavelet_spike_matrix, 1);
        num_active_electrodes{r_name_idx} = length(find(num_spike_per_electrode >= min_spike_per_electrode_to_be_active));
        
    elseif sum(~isnan(wavelet_best_param_file_name))
        fprintf('Only wavelet method has parameters meeting criteria')
        selected_detection_method{end+1} = 'Wavelet';
        best_param_file{r_name_idx} = wavelet_best_param_file_name;
        wavelet_best_param_file_data = load([wavelet_spike_folder wavelet_best_param_file_name]);
        wavelet_spike_matrix = spikeTimeToMatrix(wavelet_best_param_file_data.spikeDetectionResult.spikeTimes, start_time, end_time, sampling_rate);
        num_spike_per_electrode = sum(wavelet_spike_matrix, 1);
        num_active_electrodes{r_name_idx} = length(find(num_spike_per_electrode >= min_spike_per_electrode_to_be_active));
        
    elseif sum(~isnan(threshold_best_param_file_name))
        fprintf('Only threshold method has parameters meeting criteria')
        selected_detection_method{end+1} = 'Threshold';
        best_param_file{r_name_idx} = threshold_best_param_file_name;
        threshold_best_param_file_data = load([threshold_spike_folder threshold_best_param_file_name]);
        threshold_spike_matrix = spikeTimeToMatrix(threshold_best_param_file_data.spikeDetectionResult.spikeTimes, start_time, end_time, sampling_rate);
        num_spike_per_electrode = sum(threshold_spike_matrix, 1);
        num_active_electrodes{r_name_idx} = length(find(num_spike_per_electrode >= min_spike_per_electrode_to_be_active));
    else
        selected_detection_method{end+1} = 'Flagged';
        best_param_file{r_name_idx} = 'NaN';
        num_active_electrodes{r_name_idx} = 'NaN';
    end 
end 

close(f1)

%% Print summary table for all files 
figure()
method = selected_detection_method';
T = table(method, TTX_used, best_param_file, num_active_electrodes, 'RowNames', recording_names_exclude_TTX');
uitable('Data',T{:,:},'ColumnName',T.Properties.VariableNames,...
    'RowName',T.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);

