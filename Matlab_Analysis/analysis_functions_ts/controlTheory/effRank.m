function [effectiveRank, normEigenV] = effRank(spikeMatrix, method) 
% Computes Effective Rank of a matrix 
% assume matix of dimensions nSamples x nChannels 
% containing 0 = no spike, 1 = spike
% based on: Roy and Vetterli (2007) 
% http://ieeexplore.ieee.org/abstract/document/7098875


% 1. compute covariance matrix 
if strcmp(method, 'covariance')
    try % cov will not work for sparse matrix
        covM = sparseCov(spikeMatrix);
    catch 
        covM = cov(spikeMatrix);
    end 
elseif strcmp(method, 'correlation')
    % Option B: use correlation matrix 
    covM = corr(spikeMatrix); 
    % PROBLEM: for electrodes where no spikes is detected, corre returns
    % NaN since the variance is 0 and you can't divide by 0 
    % current solution is to replace it with 0 but I am not sure if this is
    % justified 
    covM(isnan(covM)) = 0;
end 

% 2. get eigenvalues of the covariance matrix 
eigenV = eig(covM); 

% 3. interpret the N eigenvalues as a distribution of N integers 
normEigenV = eigenV ./ sum(eigenV);

% 4. compute Shannon entropy of the vector 
sEn = -sum(normEigenV .* log(normEigenV)); 
% note that we are using natural log here 

% 5. take the exponential of the Shannon entropy 
effectiveRank = exp(sEn); 

effectiveRank = real(effectiveRank); 
end 