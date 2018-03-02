function spikeMatrix = getSpikeMatrix(data, method, multiplier)
% Loop through detectspikes for each channel 
% Assume input matrix: numSamp x numChannels
spikeMatrix = zeros(size(data)); 
for j = 1:size(data, 2)
    [spikeMatrix(:, j), finalData, threshold] = detectSpikes(data(:, j), method, multiplier);
    % fprintf(num2str(j)) % this was for debugging, to see which electrode 
    % is making an error
end 

end 