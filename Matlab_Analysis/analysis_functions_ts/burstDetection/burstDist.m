% Look at the distribution of spikes over time 
% to see if there is any clear pattern of burst


S = sparseDownSample(spikes, 720 * 10, 'sum'); 
Stot = sum(S, 2); 
plot(Stot) 

