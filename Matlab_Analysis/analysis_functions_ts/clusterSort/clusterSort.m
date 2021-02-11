function sortedSpikeMatrix = clusterSort(spikeMatrix)
%{
INPUT 
spikeMatrix (2D matrix)
    matrix with dimensions (numUnits, numTimeBins)
%}

%% Calculate distance / similarity matrix
% Correlation 
distMatrix = corr(spikeMatrix');
% Dynamic time warping (TODO)

%% Cluster distance matrix 

Z = linkage(distMatrix);
[~, ~, outperm] = dendrogram(Z, 0);


%% Sort rows based on distance 
sortedSpikeMatrix = spikeMatrix(outperm, :);


end 