function outMatrix = downSampleMean(inMatrix, n)
%DOWNSAMPLEMEAN Takes the mean so that the number of samples is n
%   Assume matrix in form numSamples x numFeatures
%   Output matrix in form n x numFeatures
    reshapedMatrix = reshape(inMatrix, size(inMatrix,1)./ n, [], size(inMatrix, 2)); 
    outMatrix = mean(reshapedMatrix);
    outMatrix = reshape(outMatrix, n, size(inMatrix, 2));
end

