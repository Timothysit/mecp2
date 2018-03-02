function stat = getDist(spikes, method)
%GETDIST Analyse the distribution of spike counts
%   Expect spike matrix as input: numSampl x numChannel  


spikeCount = sum(spikes, 1); 

% test for normality 

if strcmp(method, 'normal') 
    % Kolmogorov-Smirnov test for normality 
    [h, p, ksstat, cv] = kstest(spikeCount); 
        % less powerful compared to SW
    
    % Shapiro-Wilk test
        % more suceptible to many repeated values
    % alpha = 0.05;
    % [h, p, W] = swtest(spikeCount, alpha)  
    
end 

stat = ksstat; 

end

