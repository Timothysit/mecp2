function burstTimes = LogISIbd(spikeTrain)
%LOGISIBD Detects bursts using LogISI method
%   Based on Pasquale et al 2010
    samplingRate = 25000;
    spikeTimes = findSpikeTimes(spikeTrain, 'seconds', samplingRate);
    spikeISI = findISI(spikeTimes); % returns a cell 
    
    
    %% PART I - Determination of ISI threshold (ISIth)
    
    % STEP 1: log10 and bin 
    
    % bin data in eqaully spaced windows of log_10(ISI) 
    % whose size is in 0.1 log_10(ISI) units
    spikeISI = cell2mat(spikeISI); 
    logIsi = log10(spikeISI);
    
    % my interpretation is to log the spikeISI, then put them into 10 equally spaced bins 
    % oh wait, it may be the bin size should be just 0.1. 
    %  h = hist(logIsi, 10);
    
    logIsiBins = min(logIsi):0.1:max(logIsi);
    h = histcounts(logIsi, logIsiBins); 
    
    
    % STEP 2: Filtering the histogram 
    % purpoes: highlight meaninful peaks and discard noisy oscilations in
    % histogram
    
    % since I don't want to fork 40 pounds to update my matlab
    % "maintainance" lincense and get the curve fitting toolbox, I will use
    % an alternative, that may be marginally better.
    % https://uk.mathworks.com/matlabcentral/fileexchange/55407-loess-regression-smoothing
    % add fLOESS to path for this to work
    
    smoothH = fLOESS(h', 4/round(length(h))); % the fraction of data used is not specified in the paper 
    % so I will just make a guess (using the minimum value allowed).
    
    % STEP 3: Find ISI threshold
    
    [pks,locs] = findpeaks(smoothH, 'minpeakdistance', 2); 
    
    
    if length(pks) >= 1
        % look for peaks within 100 ms, ie. 0.1s (which is the unit of our
        % spike times)
        % but how do you know the "time" of the peak???
        % ie. we need to know which bin the peak came from. 
        
        % ie. we need to reverse back to determining the logisi bins. then
        % reverse the logisi back to actual seconds
        % we first get the index of the peak 
        isiBins = 10 .^logIsiBins; % in seconds
        
        if length(pks) == 1 
            return % no ISIth can be determined if there is only one peak
        else % there is more than one peak 
            % for each pairs of peak consituted by the first and one of the
            % following 
            for 
            % compute void paramter 
            end 
            
            if % there is no minimum that satifies the threhsold 
                return % no ISIth can be determined
            else 
                % save the crresponding ISI value as ISIth 
            end 
        end 
        
    end 
        
     
    
     %% PART II - Actually detecting spikes
    
    
     % set a threshold
     % default is 100ms, but if ISIth from above can be determined and is lower than 100ms, use
     % that instead
     
     if ISIth > 0.1
         maxISI1 = 0.1; 
         maxISI2 = ISIth;
         extendFlag = 1; 
     else 
         maxISI1 = ISIth; 
         extendFlag = 0; 
     end 
     
     % detect "burst cores": what does this mean???
     
     
     

end

