function outTrain = sparseDownSample(spikeMatrix, newSampNum, method)
%SPARSEDOWNSAMPLE Peforms downsampling for sparse matrix 
%   Assume input is sparse double: numSamp x numChannel 

% preallocate sparse matrix
outTrain = spalloc(newSampNum, size(spikeMatrix, 2), sum(sum(spikeMatrix)));  

if strcmp(method, 'sum') 
    for c = 1:size(spikeMatrix, 2) 
        spikeVec = spikeMatrix(:, c); 
        reshapeVec = reshape(spikeVec, [], newSampNum);  
        outVec = sum(reshapeVec, 1); 
        outTrain(:, c) = outVec; 
    end 
elseif strcmp(method, 'mean')
    
else
    error('Please select a valid method for downsampling') 
end 

end

