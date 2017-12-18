function burstMatrix = burstDetect(spikeMatrix, spikeTimes, method)

if strcmp(method, 'Manuel')
    % implements Rich club topology paper method 
    % 1. spike times donwsampled to 1Khz resolution 
    % activity of all electrodes averaged over windows of 10ms
    % into one vector 
    sampRate = 25000; 
    duration = 720; 
    downMatrix = downsample(spikeMatrix, 25);
    
    % 10 ms at 1000Hz means 10 samples 
    % 1kHz = 1000 samples / second = 1 sample / millisecond 
    % therefore, if you want each bin to mean 10ms, you need 
    % 720 * 10 bins
    ddownMatrix = downSampleMean(downMatrix, duration * 10); 
    
    % average activity over all electrodes 
    downVec = mean(ddownMatrix, 2);
    
    % 2. vector searched for clusters of activity (< 60ms 
    % inter-event interval) 
    
    % one approach is to calculate the ISI, then search for sequence of > 2
    % where ISI < 60ms 
    % the term 'cluster' is quite vague, email Manuel about this. 
    samplingRate = 1000;
    spikeTimes = findSpikeTimes(downVec, 'seconds', samplingRate);
    spikeISI = findISI(spikeTimes);
    
    % 3. if activity within cluster occur on at least 6 
    % electrodes and contained at least 50 spikes, 
    % population burst defined 
    
    
    % merge bursts closer than 200ms 
    

end 

if strcmp(method, 'Tim')
    % implements my method 
end 

if strcmp(method, 'nno')
    % These are default values
    start_ISI = 0.08; % maximum ISI to start a burst
    continue_ISI = 0.16; % maximum ISI to continue a burstca
    min_nspikes = 3; % minimum number of spikes to count as burst
    burstMatrix =  cell(1, size(spikeMatrix, 2)); % pre-allocate
    for n = 1:length(spikeTimes) 
        burstMatrix{n} = buda_detect_bursts_canonical(spikeTimes{n}, start_ISI, continue_ISI,min_nspikes);
    end    
end 

if strcmp(method, 'surprise') 
    minSpike = 3; % do not analyse trains with less than this many spikes
    for n = 1:length(spikeTimes) 
        if length(spikeTimes{n}) < minSpike
            burstMatrix{n} = NaN;
        else 
            [burstMatrix{n}.archive_burst_RS, ... 
                burstMatrix{n}.archive_burst_length, ... 
                burstMatrix{n}.archive_burst_start] = ... 
                surpriseBurst(spikeTimes{n}); 
        if isempty(burstMatrix{n}.archive_burst_RS) % no bursts
            burstMatrix{n} = NaN; 
        end 
    end 
end 




end