%% Load spike detection results 

load('/media/timsit/Seagate Expansion Drive/The_Mecp2_Project/organoid_data/spikes/CWT_param_search/all_duration/200708_slice1_1_-0p05_spikes.mat')


%% Get spike times 

spikeTimesStruct = spikeDetectionResult.spikeTimes;

%% Convert spike times to matrix 

% Specify time range to get spike matrix
% TODO: this info should be available 
% in the spike detection output
start_time = 0;
end_time = 360;

sampling_rate = 25000; % number of samples per second 

spike_matrix = spikeTimeToMatrix(spikeTimesStruct, ...
     start_time, end_time, sampling_rate);

 
 %% Optional: convert it to sparse matrix 
 
 sparse_spike_matrix = sparse(spike_matrix);


%% Save spike matrix 

save_folder = '/media/timsit/Seagate Expansion Drive/The_Mecp2_Project/organoid_data/spikes/CWT_param_search/all_duration_spike_matrix/';
save_name = '200708_slice1_1_-0p05_sspike_matrix.mat';
save([save_folder filesep save_name], 'sparse_spike_matrix')
spike_times == );