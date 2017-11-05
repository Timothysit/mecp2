% Abbormal electrical activity Evalutationn 
% This selects recordings with abnormal activity, plots the detected spikes
% and the raw data to find out what is wrong 
% put .mat and .h5 together, using the same name for each pair of files 
% select the folder and it will loop through all the files
%% Define what is "abnormal" 
spikeThreshold = 10000; 
% a better threshold will be std based I think...
%% Select electrodes to analyse 
% select folder 
folder = uigetdir('Select folder with spikes and electrode recordings'); 
files = dir(fullfile(folder, '*.mat'));
% my current thinking is the loop through all mat files, and for each, find
% and plot the corresponding .h5 file 

for matFile = 1:length(files)
    matFullPath = strcat(files(matFile).folder, '\', files(matFile).name);
    load(matFullPath); 
    % find corresponding h5 file and load that too 
    h5FullPath = strcat(files(matFile).folder, '\', files(matFile).name(1:end-3), 'h5');
    spikeTrain = lookAtHfile(h5FullPath);
    spikeCount = sum(spikeTrain);
    abnormalIndex = find(spikeCount > spikeThreshold); % find if there are any abnormal electrode
    for electrode = 1:length(abnormalIndex) 
        plotSpikes(spikeTrain, electrodeMatrix, abnormalIndex(electrode));
        figName = strcat(files(matFile).name(1:end-4), 'e', num2str(abnormalIndex(electrode)), '.png'); 
        numSpike = spikeCount(abnormalIndex(electrode));
        newFigName = strrep(figName, '_', '-'); 
        suptitle(strcat(newFigName, '.Number of spikes: ', num2str(numSpike))); 
        % note that suptitle may require bioinformatics toolbox
        saveas(gcf, figName)
        close all 
        % also have to make sure that the spike in the h5 files agrees
        % with the matlab files... (v. important to make sure of this)
        % fprintf('Abnomral electrode detected! \n')
    end 
end 