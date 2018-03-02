function burstMatrix = bakkumBurstDetect(spikeMatrix, samplingRate, N, minChannel) 
    % samplingRate = 25000;
    
    % combine spike times to a single train 
    
    trainCombine = sum(spikeMatrix, 2);
    
    % make sure it is all either 1 or 0, treat coincident spikes as one
    % spike. Expect this to be quite rate 
    trainCombine(find(trainCombine > 1)) = 1;
    
    
    allSpikeTimes = findSpikeTimes(trainCombine, 'seconds', samplingRate); 
    
    % combine them into a single vector
    
    
    Spike.T = cell2mat(findSpikeTimes(trainCombine, 'seconds', samplingRate));
    
    % convert it to a structure 
    
    
    % 'Spike' is a structure with members: 
    % Spike.T Vector of spike times [sec] 
    % Spike.C (optional) Vector of spike channels 
        % I assume this is the channel causing the spike for that bin 
        % I think it must be just one value, therefore won't accept
        % conincident spike (although they are quite rare I think).
    % 
    % 'N' spikes within 'ISI_N' [seconds] satisfies the burst criteria
    
    % N = 20; % N is the critical paramter here, 
    % ISI_N can be automatically selected (and this is dependent on N)
    Steps = 10.^[-5:0.05:1.5]; 
    % exact values of this doens't matter as long as its log scale, covers 
    % the possible spikeISI times,(but we don't care about values about
    % 0.1s anyway)
    plotFig = 0;
    ISInTh = getISInTh(Spike.T, N, Steps, plotFig);
    
    [Burst SpikeBurstNumber] = BurstDetectISIn(Spike, N, ISInTh); 
    
    % Burst.T_start Burst start time [sec] 
    % Burst.T_end Burst end time [sec] 
    % Burst.S Burst size (number of spikes) 
    % Burst.C Burst size (number of channels) 
    
    % burstMatrix = Burst;
    
    
    % now, covert it to a cell structure, where each cell contain a matrix 
    % with the spike trains during a burst period 
    burstCell = cell(length(Burst.S), 1);
    
    
    
    for bb = 1:length(Burst.S)
        T_start_frame = round(Burst.T_start(bb) * samplingRate); % convert from s back to frame 
        T_end_frame = round(Burst.T_end(bb) * samplingRate); 
        burstCell{bb} = spikeMatrix(T_start_frame:T_end_frame, :);
    end 
     
    % burstMatrix = burstCell; 
    
   %  minChannel = 5; 
    % minimum number of channel to be active for a burst to be considered network burst
    % this can be incorporated to the above can can be vectorised
    % active means at least one spike within the time window
    removeBurstIndex = [ ]; 
    for i = 1:length(burstCell)
        if length( find(sum(burstCell{i}) >= 1)) < minChannel % numChannel active
        removeBurstIndex = [removeBurstIndex, i]; 
        end 
    end 
    
    burstCell(removeBurstIndex, :) = [ ];
    
    burstMatrix = burstCell; 
end 
