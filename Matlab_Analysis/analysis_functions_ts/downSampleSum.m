function outTrain = downSampleSum(spikeTrain, newSampleNum) 
% TODO: check this is functioning properly, especially with sum
    numElectrode = size(spikeTrain, 2); 
    downTrain = reshape(spikeTrain, [], newSampleNum, numElectrode);
    % downTrain = sum(downTrain); % this need resolving
    downTrain = sum(downTrain, 1); % maybe this
    outTrain = reshape(downTrain, newSampleNum, numElectrode);
end 