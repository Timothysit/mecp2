function getSpikesCWT(path, recording, save_folder, params, subset_channels)
% Performs spike detection in a specific .mat file 
% Parameters 
% ----------

% save_folder (str)
    % path to save the spikes
% subset_channels : (int vector)
    % subset of channels to do spike detection 


%% Load raw data

fileName = [path recording];
file = load(fileName);
data = file.dat;  % 
channels = file.channels;
fs = file.fs;
ttx = contains(fileName, 'TTX');
spike_struct = struct;


%% Load parameters 
wname_list = params.wname_list;
Wid = params.Wid;
L = params.L;
Ns = params.Ns;
n_spikes = params.n_spikes;
multiplier = params.multiplier;
grd = params.grd;

%% Subset channels (mainly for testing purposes)
if ~exist('subset_channels', 'var') 
    channels = file.channels;
elseif ~isempty(subset_channels)
    channels = subset_channels; 
else
    channels = file.channels;
end 



%% (optional) Subsample data (used for quick parameter search)

if isfield(params, 'subsample_time')
    if ~isempty(params.subsample_time) 
        start_frame = params.subsample_time(1) * fs;
        end_frame = params.subsample_time(2) * fs;
        data = data(start_frame:end_frame, :);
    end 
end 


%% Detect spikes

% Pre-allocation to speed things up
traces = zeros(size(data'));
spikeDetectionResult = struct();
spikeDetectionResult.fs = fs; 
spikeTimes = struct();

% TODO: prreallocate templates as well (need to figure out the shape)

progressbar % initialise progressbar
for channel = 1:length(channels)
    
    for wname = wname_list
        wname = char(wname);
        valid_wname = strrep(wname, '.', 'p');
        spikeWaveforms = [];
        
        trace = data(:, channel);
        % timestamps = zeros(1, length(trace));
        if ~(ismember(channel, grd))
            [spikeFrames, spikeWaveforms, filtTrace, threshold] = ... 
                detectFramesCWT(...
                trace,fs,Wid,wname,L,Ns,...
                multiplier,n_spikes,ttx);
            
            if strcmp(wname, 'mea')
                load('mother.mat','Y');
                templates(channel, :) = Y;
            end
            
            % timestamps(spikeFrames) = 1;
            spike_wave_forms{channel} = spikeWaveforms;
            traces(channel, :) = filtTrace;
            spike_struct.(valid_wname) = spikeFrames;
        end
        
        % channel_spike_times = find(timestamps)
        % jSpikes(channel, :) = timestamps;
        spikeTimes.(strcat('channel', num2str(channels(channel)))) = ... 
            spikeFrames / fs;

    end
    spikeCell{channel} = spike_struct;
    
    progressbar(channel/length(channels))% update progress bar 
    
end


%% Compile spike detection result and save it 
spikeDetectionResult.spikeTimes = spikeTimes;
spikeDetectionResult.method = 'CWT';
spikeDetectionResult.params = params;

% TS 2020-09-12
% Added saving using MAT-file version 7.3 
% because traces and jSpikes may not be saved otherwise

if isfield(params, 'save_suffix')
   save_suffix = params.save_suffix;
else
    save_suffix = '';
end

% Determine which variables to save
vars_to_save = {'spike_wave_forms', 'spikeDetectionResult', 'L', 'threshold', ... 
                'channels', 'grd', 'spikeCell'};
            
if any(strcmp('wname_list', 'mea'))
    vars_to_save{end+1} = 'templates';
end 

if params.save_filter_trace == 1
    vars_to_save{end+1} = 'traces';
end 


save(fullfile(save_folder, [recording(1:end-4) save_suffix '_spikes.mat']), ... 
      vars_to_save{:}, '-v7.3');


end
