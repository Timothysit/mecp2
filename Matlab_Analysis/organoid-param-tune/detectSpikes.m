function [spikeTrain, finalData, threshold] = ...
    detectSpikes(data, multiplier, refPeriod_ms)

% Input:
%   data: n x 1 vector containing the raw signal, where n is the number of
%   samples
%   multiplier: the threshold multiplier used for detection
%   refPeriod_ms: the refractory period (in ms) after a spike in which no spikes
%   will be detected

% Set the sampling frequency (Hz)
fs = 25000;

% Filtering
lowpass = 600;
highpass = 8000;
wn = [lowpass highpass] / (fs / 2);
filterOrder = 3;
[b, a] = butter(filterOrder, wn);
filteredData = filtfilt(b, a, double(data));

% Calculate the threshold (median absolute deviation)
% See: https://en.wikipedia.org/wiki/Median_absolute_deviation
s = (mad(filteredData, 1)/0.6745);
m = mean(filteredData);
threshold = m - multiplier*s;

% Detect spikes (defined as threshold crossings)
spikeTrain = filteredData < threshold;
spikeTrain = double(spikeTrain);
finalData = filteredData;

% Impose the refractory period (ms)
refPeriod = refPeriod_ms * 10^-3 * fs;
for i = 1:length(spikeTrain)
    if spikeTrain(i) == 1
        refStart = i + 1;
        refEnd = round(i + refPeriod);
        if refEnd > length(spikeTrain)
            spikeTrain(refStart:length(spikeTrain)) = 0;
        else
            spikeTrain(refStart:refEnd) = 0;
        end
    end
end












