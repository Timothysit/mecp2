% Adjust the paramters for the Bakkum 2014 Algorithm (and the minChannel) 
% and see what happens 

% also try out different spikes; mSpikes, tSpikes, pSpikes 

% 1209 6A DIV 22

load('/media/timothysit/Seagate Expansion Drive/The_Mecp2_Project/feature_extraction/matlab/data/goodSpikes/KO_12_09_17-6A_DIV22_info.mat')

%% set some paramters 
samplingRate = 25000; 
spikeMatrix = mSpikes;


%% Look at number of detected bursts vs numChannel 


numChannel = 1:10; 
N = 10; 

numBurst = zeros(size(numChannel));
for nC = numChannel
    burstMatrix = bakkumBurstDetect(spikeMatrix, samplingRate, N, nC);
    numBurst(nC) = length(burstMatrix);
end 

plot(numChannel, numBurst) 
xlabel('Minimum number of channels') 
ylabel('Number of bursts detected')
title('Minimum number of spikes - N - fixed to 10')
lineThickness(3) 
aesthetics

%% Look at number of detected bursts vs numSpike 

numSpike = 10:30; 
numBurst = zeros(size(numSpike));
nC = 1;
for nS = 1:length(numSpike)
    burstMatrix = bakkumBurstDetect(spikeMatrix, samplingRate, numSpike(nS), nC);
    numBurst(nS) = length(burstMatrix);
end 

plot(numSpike, numBurst) 
xlabel('Minimum number of spikes') 
ylabel('Number of bursts detected')
title('Minimum number of channels - N - fixed to 1')
lineThickness(3) 
aesthetics

%% Look at both 

numChannel = 5:10; 
numSpike = 10:30; 
numBurst = zeros(size(numSpike));
for nC = numChannel
    for nS = 1:length(numSpike)
        burstMatrix = bakkumBurstDetect(spikeMatrix, samplingRate, numSpike(nS), nC);
        numBurst(nS) = length(burstMatrix);
    end 
    plot(numSpike, numBurst) 
    xlabel('Minimum number of spikes') 
    ylabel('Number of bursts detected')
    lineThickness(1.5) 
    aesthetics
    hold on 
end 

lg = legend('5', '6', '7', '8', '9', '10'); 
title(lg,'Minimum of channels')
lg.FontSize = 14;
legend boxoff

