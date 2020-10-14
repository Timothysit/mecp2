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

% params.wname_list =  {'mea', 'bior1.5', 'bior1.3', 'db2'};
params.wname_list =  {'bior1.5', 'bior1.3', 'db2'};
params.Wid = [0.5, 1];
% params.L = 0; % False Positive / True positive cost ratio
params.Ns = 5; % number of scales to use
params.n_spikes = 200; % number of spikes to make custom template
params.multiplier = 3; % threshold multiplier for initial 
params.grd = []; % which electordes are grounded / to ground in analysis
params.save_filter_trace = 0;  % whether to save filtered raw data
params.subsample_time = [];  % Start and end time (in seconds)
% if empty, then go through the entire recording 

% to extract a subsample of the data (to speed up parameter search)

% not recommended as it takes up a lot of space

%% Loop over desired parameters 

% L_to_search = linspace(-0.188, 0.188, 10);
L_to_search = [-0.15, -0.1, -0.05];

for file = 1:length(files)
	for L_index = 1:length(L_to_search)

	    params.L = L_to_search(L_index);
        params.save_suffix = ['_' strrep(num2str(params.L), '.', 'p')];
	    recording = files(file).name;
	    getSpikesCWT(path, recording, save_folder, params);

	end
end
