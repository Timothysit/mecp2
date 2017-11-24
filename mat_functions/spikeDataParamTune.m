% detection algorithm parameter tuning 


%% Threshold 

spikeStore = zeros(1, 20); 
detectionMethods = {'Prez', 'Manuel', 'Tim'}; 
for method = 1:length(detectionMethods)
    for multiplier = 1:20
    % feed the threshold into detection algorithm
        [spikeTrain, finalData, threshold] = ... 
            detectSpikes(data, detectionMethods{method}, multiplier);
        numSpikes = sum(spikeTrain);
        spikeStore(multiplier) = numSpikes;
    end
    plot(log10(spikeStore))
    hold on
end
title('1209 6A DIV 22 E9')
set(findall(gca, 'Type', 'Line'),'LineWidth',2);
xlabel('Threshold multiplier')
ylabel('Log(Number of spikes)')
aesthetics()
legend('Prez', 'Manuel', 'Tim')
legend boxoff  


%% Mean vs Median 


%% Refractory period 
for refPeriod = 0:50 
    
end 

%% 