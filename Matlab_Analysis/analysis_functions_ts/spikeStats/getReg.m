function regularity = getReg(spikeISI, method, chunkLength)
% TODO: set default value for chunkLength, and method

%% Gamma Method 

if strcmp(method, 'gamma')
% Key parameter here is chunkLength, as any electrode with 
% spike number less than chunkLength will be excluded from analysis 

% The Eglen / Prez / Y. Mochizuki et al way of doing this is to fit ISI to gamma distribution 
% origin: http://www.jneurosci.org/content/36/21/5736
% find logshape and lograte 
% logshape = 0 : Poisson distributed spikes 
% logshape < 0 : bursting 
% logshape > 0 : sporadic firing 
% greater absolute value of logshape, more regular spiking

% outline of the algorithm 

% 1. create chunks of the spike train ISI 
% 2. for each chunk, calculate the fit to the gamma distribution 
% 3. take the log 

% step 1: chop up our spike train ISI 
% strange, difficult to guarantee it will chop up nicely ...
% we will also have to not process electrodes with not enough spikes
% note that in their paper: chunkLength = 100
% need to test to what extent this will affect outcome
% chunkLength = 100;

gammaReg = zeros(length(spikeISI), 1); % number of electrodes
for n = 1:length(spikeISI) 
    if length(spikeISI{n}) < chunkLength 
        gammaReg(n) = NaN; 
    else 
        numSeg = floor(length(spikeISI{n}) / chunkLength);
        % most number of segments that we can get 
        tempISI = spikeISI{n}(1:numSeg*chunkLength); 
        reshapeISI = reshape(tempISI, [], numSeg); 
        % each column is one segment
        for p = 1:size(reshapeISI, 2) % loop through each segment
            [phat, ~] = gamfit(reshapeISI(:, p));
            gammaReg(n) = gammaReg(n) + log(phat(1)); 
        end 
    end 
end 

regularity = gammaReg;

% info about the gamfit function: https://www.mathworks.com/help/stats/gamma-distribution.html
% phat: maximum liklihood estimates for the parameters of
% gamma distribution 
% phat(1): a, the shape parameter
% phat(2): b, the scale parameter
% pci: 95% confidence intervals [lower bound; upper bound]

end 

%% Other methods???




end 