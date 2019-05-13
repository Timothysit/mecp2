function [downFilteredMatrix, spikeMatrix] = electrodeByElectrodeDetect
% electrodeByElectrodeDetect assumes you have a folder where each .mat file
% contains a variable (named 'dat') that contains the raw signal for an
% electrode. This function performs spike detection over each channel and
% combine them into one (sparse) variable containing the spikes for the
% entire miroelectrode array 

% INPUT 
    % (none)
    % just make sure you will run this code in the directory where each
    % file contains a variable 'dat' containing the raw data for one
    % electrode

% OUTPUT 
    % spikeMatrix | numSamp x numChannel sparse, binary matrix 
        % where numSamp is the number of samples in your recording 
        % numChannel is the number fo channels in your recording 
        % 0 means no spike, 1 means spike
    % downFiltered | newSamp x numChannel matrix with filtered data 
    % adjust the new sample rate to something reasonable without being too
    % harsh on memory usage; perhaps 10,000 Hz

% Author: Tim Sit 
% Last Update: 20180627


% get list of files in directory 
files = dir('*.mat'); 


% specify downsampling factor 
% you may need to play around with this a bit depending on memory available
% original smpaling rate  / downFactor --> new sampling rate
downFactor = 10;



% loop through each file and perform spike detection 
progressbar
for file = 1:length(files)
    % load raw data
    data = load(files(file).name, 'dat');
    data = data.dat;
    
    %% Pre-allocate variables during first iteration 
    % since from loading the first file we know the duration of the
    % recording 
    % and from the number of files we know the number of electrodes
    if file == 1
       spikeMatrix = sparse(length(data), length(files)); 
       downFilteredMatrix = zeros(length(data) / downFactor, length(files));
    end 
    %% spike detection (entire grid)
    method = 'Manuel'; % alternatives; cwt, NEO
    multiplier = 5;
    L = 0; % specific loss-ratio parameter for CWT spike detection
    % timeRange = 1: fs * 720; 
    [spikeTrain, filteredData, ~] = detectSpikes(data, method, multiplier, L);
    
    %% Add spikes to spikeMatrix
   
    spikeMatrix(:, file) = sparse(spikeTrain);
    
    %% Down sample the filtered data and add that to downFilteredMatrix 
    
    downFilteredMatrix(:, file) = downsample(filteredData, downFactor);
    
    % update progreesbar 
    progressbar(file / length(files))
end 

end 
