function randActivity = randNetwork(spikes)
%RANDNETWORK Generates random network activity
% Takes in a spike train or spike matrix, and generate a vector / matrix 
% with the same number of spikes, but in random temporal order 

% Author: Tim Sit (sitpakhang (at) gmail dot com)
% Last Update: 20180621

% INPUT 
    % spikes 
        % a vector of spike train; numSample x 1 
        % OR a matrix of spike trains; numSample x numChannels
        % 1 = spike, 0 = no spike
% OUTPUT 
    % randActivity
        % same dimension as the output, same number of spikes but spikes are now
        % randomised
% author: Tim Sit 2018 
% last update: 20180228 

[numSamp, numChannel] = size(spikes); 
randActivity = zeros(numSamp, numChannel);

for c = 1:numChannel 
    numSpike = sum(spikes(:, c)); % get number of spikes of channel
    randSpikeLoc = randperm(numSamp, numSpike); % redistribute it randomly
    randActivity(randSpikeLoc, c) = 1;
end 

end

