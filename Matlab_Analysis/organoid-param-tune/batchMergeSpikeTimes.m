%% batchMergeSpikeTimes 
%{
Loop through spike detection output files to update the 'spikeTimes' 
field to include a new field 'all' which includes the spikes detected
by any of the spike detection methods.

Parameters

spike_detection_file_folder : (str)
    path to the folder containing the spike detection result outputs (.mat
    files)
replace_existing_files : (bool or int)
    whether to replace the existing files with the merged spike 
    if False or 0, then create new files with the suffix '_merged')
    

%}

%% Set Parameters 
spike_detection_file_folder = '/media/timsit/timsitHD-2020-03/mecp2/organoid_data/jeremi-detected-spikes-dec-2020/test-merge-spikes/';
replace_existing_files = 0;
round_decimal_places = 3; 
diag_plot_path = 0;

vars_to_save = {'channels', 'spikeDetectionResult', ...
                'spikeTimes', 'spikeWaveforms'};


%% Loop through files and update spikeTimes 

mat_files = dir(fullfile(spike_detection_file_folder, '*.mat'));

for mat_file_idx = 1:length(mat_files)
    
    mat_file_folder = mat_files(mat_file_idx).folder;
    mat_file_name = mat_files(mat_file_idx).name;
    mat_file_full_path = fullfile(mat_file_folder, mat_file_name);
    
    load(mat_file_full_path);
    
    fs = spikeDetectionResult.params.fs;
    spikeTimes = mergeSpikeDetectionTimes(spikeTimes, ...
     spikeWaveforms, round_decimal_places, fs, diag_plot_path);
 
    
    if replace_existing_files == 1
       save(mat_file_full_path, '-struct', vars_to_save{:});
    
    %{ 
    % saver method without loading everything as variables
    % but still haven't figured out a good way to save non-scalar structure s
    % as variables
    mat_file_data = load(mat_file_full_path);
    
    fs = mat_file_data.spikeDetectionResult.params.fs;
    spikeTimes = mergeSpikeDetectionTimes(mat_file_data.spikeTimes, ...
     mat_file_data.spikeWaveforms, round_decimal_places, fs, diag_plot_path);
 
    % Replace existing spikeTimes field with the merged one 
    mat_file_data.spikeTimes = spikeTimes;
    
    if replace_existing_files == 1
       save(mat_file_full_path, '-struct', mat_file_data);
    %}
    
    else 
       [~, file_name_without_ext, file_ext] = fileparts(mat_file_full_path);
       save_file_name = strcat(file_name_without_ext, '_merged');
       save_full_path = fullfile(mat_file_folder, strcat(save_file_name, file_ext));
       % Use the '-struct' option to unpack the structure contents before
       % saving
       save(save_full_path, vars_to_save{:});
    end 
    
end 