function spikeISI = findISI(spikeTimes)
%FINDISI Calculates inter-spike interval for spike matrix
    % assume input to be matrix of spikeTimes x numChannels
    % either in seconds or frames
    % will return empty cell if there is only one spike 
    
    spikeISI = cell(1, size(spikeTimes, 2)); % pre-allocate
    
    % for individual electrodes
    for n = 1:size(spikeTimes, 2)
        spikeISI{n} = diff(spikeTimes{n});
    end 
    
    % for the entire electrode??? (not sure if we need this)
    
end

