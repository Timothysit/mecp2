function [effectiveRank, normEigenV] = effRank(spikeMatrix) 
% Computes Effective Rank of a matrix 
% assume matix of dimensions nChannels x nSamples 
% containing 0 = no spike, 1 = spike
% based on: Roy and Vetterli (2007) 
% http://ieeexplore.ieee.org/abstract/document/7098875

% 1. compute covariance matrix 
covM = cov(spikeMatrix'); 

% Option B: use correlation matrix 
% covM = corr(spikeMatrx); 

% 2. get eigenvalues of the covariance matrix 
eigenV = eig(covM); 

% 3. interpret the N eigenvalues as a distribution of N integers 
normEigenV = eigenV ./ sum(eigenV);

% 4. compute Shannon entropy of the vector 
sEn = -sum(normEigenV .* log(normEigenV)); 
% note that we are using natural log here 

% 5. take the exponential of the Shannon entropy 
effectiveRank = exp(sEn); 

end 