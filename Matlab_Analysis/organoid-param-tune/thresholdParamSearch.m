%% Threshold method parameter search (pre/post TTX)

clear all; close all; clc;


% path = '/media/timsit/Seagate Expansion Drive/The_Mecp2_Project/organoid_data/mat/doSpikeDetection/';
% save_folder = '/media/timsit/Seagate Expansion Drive/The_Mecp2_Project/organoid_data/spikes/customCWT_multiplier_3_L_-0p376/';

% path = '/media/timsit/phts2/tempData/doSpikeDetection/';
path = '/media/timsit/Seagate Expansion Drive/The_Mecp2_Project/organoid_data/mat/doSpikeDetection/';
% save_folder = '/media/timsit/phts2/tempData/spikes/customCWT_multiplier_3/';
save_folder = '/media/timsit/phts2/tempData/spikes/CWT_param_search/all_duration/';

thisPath = pwd;
cd (path)
files = dir('*.mat');
cd (thisPath)

%% Fixed parameters

params.multiplier = 3; % threshold multiplier for initial 
params.grd = []; % which electordes are grounded / to ground in analysis
params.save_filter_trace = 0;  % whether to save filtered raw data
params.subsample_time = [];  % Start and end time (in seconds)
% if empty, then go through the entire recording 


%% Find pre and post TTX pairs 
% (threshold for post-TTX is dependent on pre-TTX condition)

multiplier_to_search = linspace(3, 6, 10); 

pre_TTX_files = 
TTX_files = 

for multiplier = multiplier_to_search

    params.multiplier = multiplier;
    params.save_suffix = ['_' strrep(num2str(params.multiplier), '.', 'p')];
    
    for file_idx = 1:length(pre_TTX_files)

        pre_TTX_file_path = pre_TTX_files(file_idx);
        pre_TTX_data = load(pre_TTX_file_path);

        params.TTX = 0;
        params.threshold = [];

        [pre_TTX_spike_detect_results, threshold_val] = ...
            getSpikesThreshold(pre_TTX_data, params)

        % Save Pre-TTX spike data

        post_TTX_file_path = post_TTX_files(file_idx);
        post_TTX_data = load(post_TTX_file_path);

        params.TTX = 1;
        params.threshold = threshold_val;

        [post_TTX_spike_detect_results, threshold_val] = ...
            getSpikesThreshold(pre_TTX_data, params);
        
        % Save post-TTX spike data

    end 

end

