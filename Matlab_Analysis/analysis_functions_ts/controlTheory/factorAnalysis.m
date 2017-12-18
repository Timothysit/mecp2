% Factor Analysis 

%% some notes 

% Clustered factor analysis of multineuronal spike data
% http://stat.columbia.edu/~cunningham/pdf/BuesingNIPS2014.pdf
% http://papers.nips.cc/paper/5339-clustered-factor-analysis-of-multineuronal-spike-data

% Gaussian-Process Factor Analysis (GPFA)
% https://users.ece.cmu.edu/~byronyu/software.shtml

% https://scholars.opb.msu.edu/en/publications/long-term-correlations-in-the-spike-trains-of-medullary-sympathet-4

% see factoran on matlab 
% https://www.mathworks.com/help/stats/examples/factor-analysis.html

%% parameters  
newSampRate = 1000; % new sampling rate
duration = 720; % duration of recording, in seconds

% we downsample (by summing frames) our original spiketrain 

downTrain = downSampleSum(spikeTrain, newSampRate * duration);

%% Factor Analysis 

% This is not proper, see two-stage factor analysis

numFactor = 6; % first assume there is only a single common factor
% input matrix X is of dimension: obsv x variable
[loadings, specVar, T, stats] = factoran(downTrain, numFactor); 
% factroan fits factor analysis model using maximum liklihood
% lam is the factor loadings 

% fit the model until we fail to reject the null hypothesis 

for numFactor = 1:size(downTrain, 2)
    [loadings, specVar, T, stats] =  factoran(downTrain, numFactor);
    if stats.p > 0.05 
        break 
    end 
end 

figure 
plot(loadings) 
legend(string(1:size(loadings, 2)))
legend boxoff 
aesthetics
lineThickness(2)
xticks(1:size(loadings, 1)); 
title('Factor loading estimates (unrotated): 1209-6A-DIV22')

%% Two-stage factor analysis 

% first check that spikes are indeed Poisson distributed 

% bin the data (non-overlapping bins)  

% perform square-root transform to stabilise the noise variance
% need to make sure noise are isotorpic across diff
% neurons and time points 

% kernel-smooth the transformed counts 


% apply factor analysis 



%% Gaussian Process Factor Analysis (GPFA) 
