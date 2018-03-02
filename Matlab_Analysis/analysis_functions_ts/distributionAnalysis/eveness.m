function eve = eveness(dist, method) 
    % look at the eveness (uniformality) of a distribution 
    % my current plan is to use to look at the controllability matrices
    % ie. see if the control of a network is biased or even
    % INPUT
        % dist : the distribution to test uniformality. Assume continuous.
        % method: the method to use to test uniformality
            % chi-square test (OKAY)
            % KS test (OKAY) 
            % Entropy (TODO)
            % KL Divergecnce (TODO)
    % OUTPUT 
        % eve : real number value quantifying how even the distribution is 
        % the range of the value will depend on the method used
    
    % useful resources 
    % https://stackoverflow.com/questions/12996380/uniform-distribution-fitting-in-matlab
    
    %% Chi-square test 
    % this is not particularly reliable, avoid this one
    if strcmp(method, 'chisquare')
        N = length(dist); % sample size 
        a = min(dist); % lower boundary 
        b = max(dist); % higher boundary 
    
        x = unifrnd(a, b, N, 1); 
        % x(x<.9) = rand(sum(x<.9),1);
            % add some bias the dist to make it not uniform
        plot(x)
        nbins = 10; % number of bin
        edges = linspace(a,b,nbins+1); % edges of the bins
        E = N/nbins*ones(nbins,1); % expected value (equal for uniform dist)
        [h,p,stats] = chi2gof(x,'Expected',E,'Edges',edges);
        % where p is the probability of observing a test statistic to this 
        % extreity under the null hypothesis 
        % small value of p cast doubt on the validity of the null
        % hypothesis
        % ie. closer to 1 means more regular distribution
        
        eve = p;
    end 
    
    %% Skew 
    if strcmp(method, 'skew')
        % look at skewness rather than uniformality of distribution
        skewness = (aveControl);
        eve = 1 / abs(skewness);
    end
    %% KS Test 
    if strcmp(method, 'ks')
        pd = makedist('uniform', 'lower', min(dist), 'upper', max(dist));
        [h,p] = kstest(dist,'cdf',pd);
        eve = p;
    end
    
    %% Entropy 
        % uniform distribution maximises the entropy 
        % non-uniform distribution will have a lower entropy 
    
        
    %% KL divergence
    
    
    
end 