function plotSpikeAlignment(spikeMatrix, method, fs, durationInSec)

% Author: Tim Sit, sitpakhang@gmail.com
% Last update: 20180621
% 20180405: Added positive / negative peaks
% 20180621: Clairifed that I added the "ghost method" (for the organoid project)
% 20200628: Default behaviour now plots time relative to peak on the x-axis

% fs = 25000; 
% durationInSec = 2 * 10^-3; 
durationInFrame = fs * durationInSec;
x_axis_units = 'ms-rel-to-peak';  

% Parameters
    % method
        % 'simple' makes individual as different colours
        % the 'ghost' method makes the individual spikes as gray
        % semitransparent traces 
    % x_axis_units (str)
        % what to plot on the x-axis
        % if 'ms-rel-to-peak' this will be the time in milliseconds 
        % relative to the peak of spike
    

% if ~exist(method) 
%     method = 'simple';
% end 

% INPUT 
    % spikeMatrix   | 
    % method        | 
    % fs            | 
    % durationInSec | Note that input here has to be smaller than the
    % durationInSec in spikeAlignment!!! (they are not the same thing!)

% figure 
if strcmp(method, 'simple')
    % this makes sures that 0 is the point where the spike is detected
    % only tested when number of frames is an odd number (63)
    if strcmp(x_axis_units, 'ms-rel-to-peak')
        xAxis = linspace(-durationInSec/2, durationInSec/2, size(spikeMatrix, 2));
    else
        xAxis = [0:size(spikeMatrix, 2)-1] - ((size(spikeMatrix, 2) - 1) /2);
    end 
    plot(xAxis, spikeMatrix') 
    % title('Simple method') 
    % aesthetics
end 

% for loop equivalent
% for i = 1:size(spikeMatrix, 1)
%     plot(spikeMatrix(i, :))
%     hold on
% end 

% ghost method 
% makes each trace semitransparent gray traces 
if strcmp(method, 'ghost') 
    if strcmp(x_axis_units, 'ms-rel-to-peak')
        xAxis = linspace(-durationInSec/2, durationInSec/2, size(spikeMatrix, 2));
    else
        xAxis = [0:size(spikeMatrix, 2)-1] - ((size(spikeMatrix, 2) - 1) /2);
    end 
    alpha = 0.3; % 0 for black, 1 for white
    plot(xAxis, spikeMatrix', 'Color', [0 0 0] + alpha) 
end



% a slightly more sophisticated method based on finding the peak and
% aligning that 

% TODO: make this work for negative peak
% figure 
if strcmp(method, 'peak')
    % fprintf('Using peak method \n') 
    if strcmp(x_axis_units, 'ms-rel-to-peak')
        xAxis = linspace(-durationInSec/2, durationInSec/2, size(spikeMatrix, 2));
    else
        xAxis = [0:size(spikeMatrix, 2)-1] - ((size(spikeMatrix, 2) - 1) /2);
    end 
    
    for spikeTimeSeries = 1:size(spikeMatrix, 1)
        % find positive peaks
        % [pks,locs] = findpeaks(spikeMatrix(spikeTimeSeries, :));
        % spikePeakLoc = locs(pks == max(pks)); % the spike peak is the max peak 
        % that's an assumption, but should be true in most cases
        % find negative peaks 
        [pks,locs] = findpeaks(-spikeMatrix(spikeTimeSeries, :));
        spikePeakLoc = locs(abs(pks) == max(abs(pks)));
        
        spStart = spikePeakLoc - round(durationInFrame / 2);
        spEnd = spikePeakLoc + round(durationInFrame / 2);
        if spStart > 0 && spEnd < size(spikeMatrix, 2)
            plot(xAxis, spikeMatrix(spikeTimeSeries, spStart:spEnd));
        else
            warning(['Spike exceeded limit, not plotted. Spike Number: ' num2str(spikeTimeSeries)])
        end 
        hold on
    end 
end 
% title('Find peak method')
% aesthetics

% 3D Plot so overlapping lines are more obvious 
if strcmp(method, 'peak3D')
    plotSpikeCount = 0; 
    
    % Define time axis 
    if strcmp(x_axis_units, 'ms-rel-to-peak')
        xAxis = linspace(-durationInSec/2, durationInSec/2, size(spikeMatrix, 2)) * 1000; 
    else
        xAxis = [0:size(spikeMatrix, 2)-1] - ((size(spikeMatrix, 2) - 1) /2);
    end 
    
    % fprintf('Using peak method \n') 
    for spikeTimeSeries = 1:size(spikeMatrix, 1)
        % find positive peaks
        % [pks,locs] = findpeaks(spikeMatrix(spikeTimeSeries, :));
        % spikePeakLoc = locs(pks == max(pks)); % the spike peak is the max peak 
        % that's an assumption, but should be true in most cases
        % find negative peaks 
        [pks,locs] = findpeaks(-spikeMatrix(spikeTimeSeries, :));
        spikePeakLoc = locs(abs(pks) == max(abs(pks)));
        
        spStart = spikePeakLoc - round(durationInFrame / 2);
        spEnd = spikePeakLoc + round(durationInFrame / 2);
        if spStart > 0 && spEnd < size(spikeMatrix, 2)
            plotSpikeCount = plotSpikeCount + 1;
            % xMat = 1:length(spStart:spEnd);
            % yMat = spikeTimeSeries; 
            % yMat = repmat(spikeTimeSeries, length(xMat)); % say in same place in y-axis
            % zMat = spikeMatrix(spikeTimeSeries, spStart:spEnd);
            xMat(:, plotSpikeCount) = 1:length(spStart:spEnd);
            yMat(:, plotSpikeCount) = repelem(plotSpikeCount, length(xMat(:, plotSpikeCount)) );
            zMat(:, plotSpikeCount) = spikeMatrix(spikeTimeSeries, spStart:spEnd);
        else
            warning('Spike exceeded limit, not plotted')
        end 
        plot3(xMat, yMat, zMat);
    end 
    xlim([1 length(spStart:spEnd)]);
    grid; 
    view(40,40);
end 


if strcmp(method, 'peakghost')
    % fprintf('Using peak method \n') 
    

    alpha = 0.2;
    peakAlignedSpikeMatrix  = [];
    for spikeTimeSeries = 1:size(spikeMatrix, 1)
        % find positive peaks
        % [pks,locs] = findpeaks(spikeMatrix(spikeTimeSeries, :));
        % spikePeakLoc = locs(pks == max(pks)); % the spike peak is the max peak 
        % that's an assumption, but should be true in most cases
        % find negative peaks 
        [pks,locs] = findpeaks(-spikeMatrix(spikeTimeSeries, :));
        spikePeakLoc = locs(abs(pks) == max(abs(pks)));
        
        if length(spikePeakLoc) > 1
            spikePeakLoc = spikePeakLoc(1);
        end 
        
        spStart = spikePeakLoc - round(durationInFrame / 2);
        spEnd = spikePeakLoc + round(durationInFrame / 2);
        
         % Define time axis 
        if strcmp(x_axis_units, 'ms-rel-to-peak')

            xAxis = linspace(-durationInSec/2, durationInSec/2, spEnd - spStart + 1) * 1000; 

        else
            xAxis = spStart:spEnd;
        end 
  
        if spStart > 0 && spEnd < size(spikeMatrix, 2)
            plot(xAxis, spikeMatrix(spikeTimeSeries, spStart:spEnd), 'Color', [0 0 0] + 1 - alpha);
            peakAlignedSpikeMatrix = [peakAlignedSpikeMatrix; ...
                spikeMatrix(spikeTimeSeries, spStart:spEnd)];
                
        else
            warning(['Spike exceeded limit, not plotted. Spike Number: ' num2str(spikeTimeSeries)])
        end 
        hold on
    end 
    % plot the average waveform on top 
    % aveSpikeWaveForm = mean(spikeMatrix);
    
    % a better mean average waveform after aligning to the peak
    aveSpikeWaveForm = mean(peakAlignedSpikeMatrix);
    
    [pks,locs] = findpeaks(-aveSpikeWaveForm);
    spikePeakLoc = locs(abs(pks) == max(abs(pks)));
    spStart = spikePeakLoc - round(durationInFrame / 2);
    spEnd = spikePeakLoc + round(durationInFrame / 2);
    if spStart > 0 && spEnd < size(spikeMatrix, 2)
       plot(xAxis, aveSpikeWaveForm(spStart:spEnd), 'Color', [0 0 0]);
    else
       warning(['Spike exceeded limit, not plotted. Spike Number: ' num2str(spikeTimeSeries)])
    end 
    
end 


end 
