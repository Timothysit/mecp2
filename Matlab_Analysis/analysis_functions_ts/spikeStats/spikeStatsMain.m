% computes basic spike statistics for our data 

% general analysis: https://github.com/nno/burstiDAtor



%% set some parameters 

samplRate = 25000; 

%% Burst Rate

%% burst rate 

%% Percentage of spikes in bursts 



%% average firing rate 

% let's have it in spikes / seconds (ie. unit: Hz)
aveFireRate = sum(spikeMatrix) / sampleRate;

%% Network Spike Duration 


%% Within-burst firing rate 



%% Firing Regularity 

% fir inter-spike interval to gamma distribution 
isi = findISI(spikeMatrix);  
phta = gamfit(data);

