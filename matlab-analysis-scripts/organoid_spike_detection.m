%% Organoid spike detection 

% specify path of folder with .mat files we want to extract spikes 
data_folder = '/media/timsit/Seagate Expansion Drive/The_Mecp2_Project/organoid_data/mat/';
mat_file_list_struct = dir(fullfile(data_folder,'*.mat'));


mat_file_list = {};
for mat_file_idx = 1:length(mat_file_list_struct)
    
    mat_file_list{mat_file_idx} = mat_file_list_struct(mat_file_idx).name;
    
end 


%% Threshood spike detection - one example file, to check code works 

example_file = mat_file_list{1};
data = load(fullfile(data_folder, example_file));

method = 'Manuel';
multiplier = 5;
spikeMatrix = getSpikeMatrix(data.dat, method, multiplier);
spikeTimes = spikeMatrixToTimes(spikeMatrix, data.fs, data.channels);

spikeDetectionResult = struct();
spikeDetectionResult.spikeTimes = spikeTimes;
spikeDetectionResult.method = method;
spikeDetectionResult.multiplier = multiplier;


%% Threshold spike detection - loop through all files 

% specify where to save the spike detection results
save_folder = '/media/timsit/Seagate Expansion Drive/The_Mecp2_Project/organoid_data/spikes/manuelMedian_multiplier_5/';

method = 'ManuelMedian';
multiplier = 5;

for mat_file_idx = 1:length(mat_file_list)
    
    mat_file_name = mat_file_list{mat_file_idx};
    data = load(fullfile(data_folder, mat_file_name));
    
    
    spikeMatrix = getSpikeMatrix(data.dat, method, multiplier);
    spikeTimes = spikeMatrixToTimes(spikeMatrix, data.fs, data.channels);

    spikeDetectionResult = struct();
    spikeDetectionResult.spikeTimes = spikeTimes;
    spikeDetectionResult.method = method;
    spikeDetectionResult.multiplier = multiplier;
    
    [pathstr, filename, file_ext] = fileparts(mat_file_name);
    
    save_filename = strcat(filename, method, ... 
        num2str(multiplier), '_spikes.mat');
    
    save(fullfile(save_folder, save_filename), 'spikeDetectionResult');

    
end 



%% Wavelet spike detection 
% Adapted from Jeremi's getSpikeCWTmain 

% which channels to exclude
excluded = [];

for mat_file_idx = 1:length(mat_file_list)
    

end 