function [spikeFrames, spikeWaveforms, filteredData, threshold] = detectFramesCWT(...
    data, fs, Wid, wname, L, Ns, multiplier, n_spikes, ttx)

% Input:
%   data - 1 x n extracellular potential data to be analyzed
%
%   fs - sampling frequency [Hz]
%
%   Wid - 1 x 2 vector of expected minimum and maximum width [ms] of
%         transient to be detected Wid=[Wmin Wmax]
%         For most practical purposes Wid=[0.5 1.0]
%
%   wname - (string): the name of wavelet family in use
%       'bior1.5' - biorthogonal
%       'bior1.3' - biorthogonal
%       'db2'     - Daubechies
%       'mea'     - custom wavelet (https://github.com/jeremi-chabros/CWT)
%
%       Note: sym2 and db2 differ only by sign --> they produce the same
%       result
%
%	L - the factor that multiplies [cost of comission]/[cost of omission].
%       For most practical purposes -0.2 <= L <= 0.2. Larger L --> omissions
%       likely, smaller L --> false positives likely.
%       For unsupervised detection, the suggested value of L is close to 0
%
%   Ns - (scalar): the number of scales to use in detection (Ns >= 2)
%
%   multiplier - the threshold multiplier used for detection
%
%   n_spikes - the number of spikes used to adapt a custom wavelet
%
%   ttx - flag for the recordings with TTX added: 1 = TTX, 0 = control

% OUTPUT: 

% spikeFrames : 
% spikeWaveForms : 

refPeriod_ms = 1;

%  Filter signal
lowpass = 600;
highpass = 8000;
wn = [lowpass highpass] / (fs / 2);
filterOrder = 3;
[b, a] = butter(filterOrder, wn);
filteredData = filtfilt(b, a, double(data));

data = filteredData;

%   Set thresholds
% threshold = mad(filteredData, 1)/0.6745;
threshold = median(abs(filteredData - mean(filteredData))) / 0.6745;  % timS: this seems faster.
minThreshold = -threshold*2;    % min spike peak voltage
peakThreshold = -threshold*10;  % max spike peak voltage
posThreshold = threshold*4.0;   % positive peak voltage
win = 25;                       % [frames]; [ms] = window/25

%   If using custom template:
if strcmp(wname, 'mea') && ~ttx
    
    %   Use threshold-based spike detection to obtain the median waveform
    %   from n_spikes
    try
        ave_trace = getTemplate(data, multiplier, refPeriod_ms, n_spikes);
    catch
        disp(['Failed to obtain mean waveform']);
    end
    
    %   Adapt a custom template from the spike waveform obtained above
    try
        customWavelet(ave_trace);
    catch
        disp(['Failed to adapt custom wavelet']);
    end
end

%   Detect spikes
% try
    
    sFr = [];

    
    spikeFrames = detect_spikes_wavelet(filteredData, fs/1000, Wid, ... 
        Ns, 'l', L, wname, 0, 0);
    
    % spikeWaveforms = [];
    
    % Preallocate 
    spikeWaveforms = zeros(win*2+1, length(spikeFrames));
    
    %   Align the spikes by the negative peak
    %   Post-hoc artifact removal:
    %       a) max -ve peak voltage
    %       b) min -ve pak voltage
    %       c) +ve peak voltage
    
    for i = 1:length(spikeFrames)
        
        % TimS: Make sure that the spike frame is not (1) at the end of the
        % recording, suc that the window will clip and (2)
        % at the very beginning of the recording, such that it also clips
        % In the future it's much faster to just remove the clipping
        % spikeFrames instead of checking each time
        % Example: 
        % if recording length is 1000, and the last spike frame is at 998
        % and the window length is 25, then the condition (1) will be False
        % if window is 25, and the first spike is at 24, then 
        % condition (2) will be False
        if (spikeFrames(i)+win < length(data)) && (spikeFrames(i) - win >= 1)
            
            %   Look into a window around the spike
            bin = filteredData(spikeFrames(i)-win:spikeFrames(i)+win);
            spikeWaveforms(:, i) = bin;
            
            
            % Question: if negativePeak is just -max(npk), then this is the
            % same as taking -max(bin) right?
            
            %   Obtain peak voltages
            
            % pk = findpeaks(bin);
            % pk = sort(pk, 'descend');
            % npk = findpeaks(-bin);
            
            % for j = 1:length(pk)
            %     pkPos(j) = find(bin == pk(j));
            % end
            
            % for j = 1:length(npk)
            %     npkPos(j) = find(-bin == npk(j));
            % end
            
            % negativePeak = -max(npk);
            % positivePeak = max(pk);
            %   posPeak = pk(2);
            
            negativePeak = min(bin);
            positivePeak = max(bin);
            
            pos = find(bin == negativePeak);
            
            % TODO: I think this can be outside the for loop to prevent
            % having to append to sFr each time. 
            %   Remove the artifacts
            if negativePeak > peakThreshold && negativePeak < minThreshold
                if positivePeak < posThreshold
                    sFr = [sFr (spikeFrames(i)+pos-win)];
                end
            end
            
            % TODO: look into constraining the half-width of a spike
        end
    end
    spikeFrames = sFr;
   
% catch
%     disp(['Failed to detect spikes']);
%     spikeFrames = [];
% end
threshold = multiplier*threshold;
end
