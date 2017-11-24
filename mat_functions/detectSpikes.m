function [spikeTrain, finalData, threshold] = detectSpikes(data, method, multiplier)
% code inspired by Gaidica 
% http://gaidi.ca/weblog/extracting-spikes-from-neural-electrophysiology-in-matlab
% filter
% remove low frequency content of signal so high frequency spikes more
% detectable
% Wn values: Wn = Fc / (Fs / 2)
% where Fc is the cut-off frequency 
% Fs is the sampling frequency 


% artifact removal 

% filteredData = artifactThresh(filteredData,validMask,thresh); 

%% Prez's method 

if strcmp(method,'Prez') 
    par.detect_order = 4; % default, no idea why specifically this number
    par.ref_ms = 1.5; % refractor period in ms, not sure when this is going to be used...
    sr = 25000; % sampling rate 
    fmin_detect = 300; 
    fmax_detect = 8000;
    [b,a] = ellip(par.detect_order,0.1,40,[fmin_detect fmax_detect]*2/sr);
    % FiltFiltM does the same thing, but runs slightly faster
    % the parameters are default found in wave_clus
    filteredData = filtfilt(b, a, double(data)); 

    % finding threshold and spikes
    med = median(filteredData); 
    s = std(filteredData); 
    % multiplier = 4;
    threshold = med - multiplier*s; 
    spikeTrain = filteredData < threshold; % negative threshold
    spikeTrain = double(spikeTrain);
    finalData = filteredData;
    
   %  although it wasn't mentioned in the thesis, I think he implemented
   % the default Wave_clus 1.5 ms refractory period
    for i = 1:length(spikeTrain)
       if spikeTrain(i) == 1 
           refStart = i + 1; % start of refractory period 
           refEnd = round(i + par.ref_ms); % end of refractory period
           spikeTrain(refStart:refEnd) = 0; 
       end 
    end 
    
end 


%% implement different methods to detect spikes  
if strcmp(method,'Tim')
    % butterworth filter 
    lowpass = 600; 
    highpass = 8000; 
    fs = 25000; 
    wn = [lowpass highpass] / (fs / 2); 
    filterOrder = 3;
    [b, a] = butter(filterOrder, wn); 
    filteredData = filtfilt(b, a, double(data)); 
    % NEO by calling snle
    y_snle = snle(filteredData', 1); 
    m = mean(y_snle); 
    s = std(y_snle); 
    % multiplier = 12; % this is the crux of the detection 
    threshold = m + multiplier*s; 
    spikeTrain = y_snle > threshold; 
    % this is a much large std than what others had to use...
    % but this is because we used NEO
    spikeTrain = double(spikeTrain)';
    
    % refractory period 
    refPeriod = 2.0 * 10^-3 * fs; % 2ms 
    for i = 1:length(spikeTrain)
       if spikeTrain(i) == 1 
           refStart = i + 1; % start of refractory period 
           refEnd = round(i + refPeriod); % end of refractory period
           spikeTrain(refStart:refEnd) = 0; 
       end 
    end     
    
    
    finalData = y_snle;
end 

% Continuous Wavelet Transform 
% http://cbmspc.eng.uci.edu/SOFTWARE/SPIKEDETECTION/tutorial/tutorial.html

%% M.Schroter 2015 Spike Detection Procedure 

% bandpass filter : 3rd order Butterworth, 600 - 8000Hz 
% threshold of 5 x SD below backgroudn noise for each channel 
% impose 2 ms refractory period (Wagennaar et al 2006) 

% burst detection via ...
% spike times downsample to 1KHz 
% activity of all  electrodes averaged over windows of 10ms into one vector
% vector serached for clusters of activity ( <60ms inter-event internval) 
% if activity within cluster occured on at least 6 electrodes and contain
% at least 50 spike, then population spike 
% the numbers seem quite arbitrary to me...
if strcmp(method,'Manuel')
    % butterworth filter 
    lowpass = 600; 
    highpass = 8000; 
    fs = 25000; 
    wn = [lowpass highpass] / (fs / 2); 
    filterOrder = 3;
    [b, a] = butter(filterOrder, wn); 
    filteredData = filtfilt(b, a, double(data)); 

    % finding threshold and spikes
    m = mean(filteredData); 
    s = std(filteredData); 
    % multiplier = 5;
    threshold = m - multiplier*s; 
    spikeTrain = filteredData < threshold; % negative threshold

    % impose refractory period
    refPeriod = 2.0 * 10^-3 * fs; % 2ms 
    % I think there is a more efficient/elegant way to do this, but I haven't 
    % taken time to think about it yet 
    spikeTrain = double(spikeTrain);
    finalData = filteredData;
    % refractory period
    for i = 1:length(spikeTrain)
       if spikeTrain(i) == 1 
           refStart = i + 1; % start of refractory period 
           refEnd = round(i + refPeriod); % end of refractory period
           spikeTrain(refStart:refEnd) = 0; 
       end 
    end 
end 




end 