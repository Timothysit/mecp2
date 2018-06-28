%% The Mecp2 Project 

% this is the main script for the mecp2 project and aims to be a brief
% walkthrough of the usual steps taken for MEA data anlaysis. 
% Note that batch analysis is not included here yet. 
Currently this is focused on generating some visualisations and getting an overview of the activity level of MEAs.

% a lot of this is taken directly from the script I wrote for the organoid
% project 

% Author: Tim Sit 
% Last update: 20180627

%% Add dependencies to path

% TODO: rebrand those code into some sort of MEA processing code
addpath(genpath('/media/timothysit/Seagate Expansion Drive1/The_Mecp2_Project/feature_extraction/matlab/analysis_functions_ts/'))
% addpath(genpath('/media/timothysit/Seagate Expansion Drive1/The_Organoid_Project/organoid_data_analysis/'))

% scale bar 
addpath(genpath('/media/timothysit/Seagate Expansion Drive1/The_Mecp2_Project/feature_extraction/matlab/chenxinfeng4-scalebar-4ca920b/'))
% heatmaps 
addpath(genpath('/media/timothysit/Seagate Expansion Drive1/The_Mecp2_Project/feature_extraction/matlab/heatMap/'))
% human colours 
addpath(genpath('/media/timothysit/Seagate Expansion Drive1/The_Mecp2_Project/feature_extraction/matlab/XKCD_RGB/'))
% cwt spike detection 
addpath(genpath('/media/timothysit/Seagate Expansion Drive1/The_Mecp2_Project/feature_extraction/matlab/continuous_wavlet_transform/'))

% orgaoind project 
% addpath(genpath('/media/timothysit/Seagate Expansion Drive1/The_Organoid_Project')); 

% figure2eps
addpath(genpath('/media/timothysit/Seagate Expansion Drive1/The_Organoid_Project/figure2epsV1-3'));

%% Convert Data from .raw to .mat 

% I assume this is done for now 

%% Perform spike detection (whole MEA implementation) 

method = 'Manuel';
% method = 'cwt';
multiplier = 5.5;
L = 0; 
timeRange = 1: fs * 720;
% timeRange = 110 * fs: 185 * fs -1;
[spikeMatrix, filteredMatrix] = getSpikeMatrix(dat(timeRange, :), method, multiplier, L);

%% Filtered traces / grid traces (whole MEA implementation)

downFactor = 1000; % down sample factor for making grid trace
gridTrace(filteredMatrix, downFactor)

%% MEA Raster Plot 

figure
recordDuration = length(spikeMatrix) / fs;
downSpikeMatrix = downSampleSum(spikeMatrix, recordDuration * 1/5); 

h = imagesc(downSpikeMatrix' ./5); 

aesthetics 
ylabel('Electrode') 
xlabel('Time (s)')
cb = colorbar;
% ylabel(cb, 'Spike count')
ylabel(cb, 'Spike Frequency (Hz)') 
cb.TickDirection = 'out';
% cb.Ticks = 0:5; % for slice 5 specifically
set(gca,'TickDir','out'); 
cb.Location = 'Southoutside';
cb.Box = 'off';
set(gca, 'FontSize', 14)


set(h, 'AlphaData', ~isnan(downSpikeMatrix')) % for NaN values

timeBins = 5; % 5 second separation between marks
% timePoints = 1:timeBins:floor(length(spikeMatrix) / fs); 
timePoints = 0:20:floor(length(spikeMatrix) / fs); 
yticks([1, 10:10:60])
xticks(timePoints); 
xticklabels(string(timePoints * 5));
% xticklabels(string(timePoints -1 ));

yLength = 800; 
xLength = yLength * 2; 
set(gcf, 'Position', [100 100 xLength yLength])


%% Multiple single trace plots 

yGap = 100; % vertical gap bewteen traces 
electrodesToPlot = [3, 16, 53]; % list of electrodes to plot

figure 

for electrode = 1:length(electrodesToPlot)
   plot(filteredMatrix(:, electrodesToPlot(electrode)) - yGap * (electrode -1))
   hold on 
end

aesthetics 
removeAxis 

%% MEA Spike Sum Heat Map 

figure
makeHeatMap(spikeMatrix, 'rate')
set(gcf, 'Position', [100, 100, 800, 800 * 1])


