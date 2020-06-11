function mea_spike_struct = detect_spikes_multiwavelet(raw_traces, fs, ... 
    filter_data, wname_list, channel_names)
%
% Performs spike detection using multiple wavelets
%
% TODO: set sensible defaults for wname_list and filter_data

% Some default parameters for the wavelet method 
Wid = [0.5, 1.0];
Ns = 5; % Ns - (scalar): the number of scales to use in detection (Ns >= 2);
option = 'c';
L = 0;


PltFlg = 0; 
CmtFlg = 0; 
%   PltFlg - (integer) is the plot flag: 
%   PltFlg = 1 --> generate figures, otherwise do not;
%  
%   CmtFlg - (integer) is the comment flag, 
%   CmtFlg = 1 --> display comments, otherwise do not;

% wname_list = {'bior1.5', 'haar', 'bior1.3', 'db2'};

% Filter signal 
if filter_data

    lowpass = 600; 
    highpass = 8000; 
    wn = [lowpass highpass] / (fs / 2); 
    filterOrder = 3;
    [b, a] = butter(filterOrder, wn); 
    filteredData = filtfilt(b, a, double(raw_traces)); 

else
    filteredData = raw_traces;
end 


% Loop through each channel, and for each channel, loop through each 
% wavelet 

% TODO: look into whether it is possible to do the inner wavelet loop 
% in parallel

num_channel = size(filteredData, 2);

% Start loading bar
progress_bar = waitbar(0,'Performing wavelet detection on each channel...');

for channel_idx = 1:num_channel
    
    channel_trace = filteredData(:, channel_idx);

    spike_struct = struct;

    % For loop implementation 
    %
    for wname = wname_list

        wname = char(wname);

        spikeFrames = detect_spikes_wavelet(channel_trace, fs/1000, ... 
            Wid, Ns, option, L, wname, PltFlg, CmtFlg); 

        % we can't use '.' as a field name
        valid_wname = strrep(wname, '.', 'p');
        spike_struct.(valid_wname) = spikeFrames;

        % spikeTrain = zeros(size(data)); 
        % spikeTrain(spikeFrames) = 1;
    end 
    %}
    
    % Parallelised for-loop implementation 
    % TODO: need to re-do the indexing (allow arbitrary order first, 
    % reorder / rename thigns later 
    % eg. see: https://uk.mathworks.com/matlabcentral/answers/103298-parfor-indexing-basic-question
    %{
    parfor wavelet_idx = 1:length(wname_list)
        wname = wname_list(wavelet_idx);
        wname = char(wname);

        spikeFrames = detect_spikes_wavelet(channel_trace, fs/1000, ... 
            Wid, Ns, option, L, wname, PltFlg, CmtFlg); 

        % we can't use '.' as a field name
        valid_wname = strrep(wname, '.', 'p');
        spike_struct.(valid_wname) = spikeFrames;
        
    end 
    %}
    
    
    channel_str = strcat('channel_', num2str(channel_names(channel_idx)));
    mea_spike_struct.(channel_str) = spike_struct;
    
    % update progress bar 
    waitbar(channel_idx / num_channel, progress_bar, ...
           strcat(num2str(channel_idx), ' channel(s) processed'));
 

end 

% close progress bar 
close(progress_bar)


end