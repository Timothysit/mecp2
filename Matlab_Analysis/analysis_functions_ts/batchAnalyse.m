function batchAnalyse 
% Goes through the .mat files, detect spikes, bursts, then 
% go on to derive other characteristics, and save it in another file 

%% some parameters 

files = dir('*.mat');  % where your .mat files are 
% assume it takes the form numSamp x numChannels
samplingRate = 25000; 

progressbar
for file = 1:length(files)
    
data = load(files(file).name, 'mSpikes'); 
spikes = data.mSpikes; 

% detect spikes now moved to batchGetSpike; 
% spikes = mSpikes; 
% spikes = sparse(getSpikeMatrix(data, 'Manuel', 5));
% mSpikes = spikes; 
% tSpikes = sparse(getSpikeMatrix(data, 'Tim', 11));
% pSpikes = sparse(getSpikeMatrix(data, 'Prez', 4));

% since we are doing highpass 8kHz, I think it's actually okay if 
% we do the rest of the anlaysis by downsamplin to 10kHz (just if things
% need to be faster). But I will stick to 25kHz for now

% get spike times 

spikeTimes = findSpikeTimes(spikes, 'seconds', samplingRate);

% inter-spike interval 

spikeISI = findISI(spikeTimes);

%% average firing rate 
% returns it in Hz
% takes the sum of all electrodes
aveFireRate = sum(sum(spikes)) / (size(spikes, 1) / samplingRate); 

%% detect individual electrode bursts - NNO method

% the nno method is problematically implemented 
% currently only allow min_spike = 2
% electrodeBurst = burstDetect(spikes, spikeTimes, 'nno'); 
% 
% % extract burst statistics from the cell of structures 
% % (that was a stupid way to do it) 
% 
% burstCount = zeros(length(electrodeBurst), 1); 
% % average burst duration of each electrode (in milliseconds, I think) 
% aveBurstDur = zeros(length(electrodeBurst), 1); 
% % average number of spikes per burst
% aveBurstNumSpike = zeros(length(electrodeBurst), 1); 
%  
% % within burst spiking frequency
% aveBurstSpFreq = zeros(length(electrodeBurst), 1); 
% for n = 1:length(electrodeBurst) 
%     burstCount(n) = length(electrodeBurst{n}.BuDur); 
%     aveBurstDur(n) =  mean(electrodeBurst{n}.BuDur);
%     aveBurstNumSpike(n) = mean(electrodeBurst{n}.nSp);
%     aveBurstSpFreq(n) = mean(electrodeBurst{n}.SpFreq); 
% end 
% 
% % same burst metrics for the entire electrode array 
% totalBurstCount = sum(burstCount); 
% meaAveBurstDur = nanmean(aveBurstDur); % in seconds I think 
% meaAveBurstNumSpike = nanmean(aveBurstNumSpike); 
% meaAveBurstSpFreq = nanmean(aveBurstSpFreq); % in Hz I think

% Store the burst times away for further analysis ? 

%% detect individual electrode bursts - Rank Surprise Method 
numBurst = zeros(size(spikes, 2), 1); 
aveBurstSpikeNum = zeros(size(spikes, 2), 1); 
electrodeBurst = burstDetect(spikes, spikeTimes, 'surprise'); 
for n = 1:length(electrodeBurst)
    if ~ isfield(electrodeBurst{n}, 'archive_burst_RS')
        % check if there is a structure 
        numBurst(n) = 0; 
        aveBurstSpikeNum(n) = NaN;
    else 
        numBurst(n) = length(electrodeBurst{n}.archive_burst_RS); 
        % total number of burst from that electrode
        aveBurstSpikeNum(n) = mean(electrodeBurst{n}.archive_burst_length);
        % average number of spikes per burst from that electrode
    end 
end

% burstTimes 

% total number of burst 

totalBurstCount = sum(numBurst); 
totalBurstRate = totalBurstCount / (size(spikes, 1) / samplingRate);
totalAveBurstSpikeNum = nanmean(aveBurstSpikeNum); 

% Other statitics that may be useful: 
% within burst firing frequency 
% number of electrodes activte during burst 
% burst duration in ms, or frames

%% detect network bursts 



%% get firing regulatiry 

regularity = getReg(spikeISI, 'gamma', 10);
totalReg = nanmean(regularity);

%% Relationship beteween chunk length and regularity '
% TODO: incorporate this into the getReg function 
% comment out when doing batch analysis, this is only for exploration 
% might be a good idea to make a new metric that takes this into account 
% perhaps taking the mean of this, or fitting this to another distribution?

% for n = 1:100 
%     regularity = getReg(spikeISI, 'gamma', n); 
%     totalReg(n) = nanmean(regualrity); 
% end 
% 
% plot(totalReg)
% xlabel('Chunk length (number of spike intervals)')
% ylabel('Average regularity') 
% aesthetics
% lineThickness(2)

%% ISI correlation 


%% save variables to structure
% fileName = strcat(files(file).name, '_info'); 
% save(fileName, spikes, spikeTimes, aveFireRate, regularity, '-append');

% Basic Info 
featMatrix(file).batch = files(file).name(4:11); 
featMatrix(file).ID = files(file).name(4:14); 
featMatrix(file).DIV = str2num(files(file).name(19:20)); 
featMatrix(file).genotype = files(file).name(1:2); 

% spike and burst statistics
featMatrix(file).aveFireRate = full(aveFireRate); 
% featMatrix{file}.totalBurstRate = totalBurstRate; 
featMatrix(file).totalBurstCount = totalBurstCount; 
featMatrix(file).totalAveBurstSpikeNum = totalAveBurstSpikeNum;

% regularity 
featMatrix(file).totalReg = totalReg; 

% control theory
featMatrix(file).effRankCov = effRank(spikes, 'covariance');
% assume sparse matrix, may take long / run out of mem 
% if a full matrix is used


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% average and modal controllability 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

downSpikes = sparseDownSample(spikes, 720 * 100, 'sum');

% Remove electrodes with no spikes 
% When considering correlation / partial correlation, having zero variance
% creates NaN (you can't divide by 0). 
noSpikeElectrode = find(sum(downSpikes) == 0); 
downSpikes(:, noSpikeElectrode) = []; 

adjM = getAdjM(downSpikes, 'partialcorr'); 
aveControl = ave_control(adjM); 
modalControl = modal_control(adjM);

% skewness of the cotrollability metrics 
% skweness function: 0 = correct for bias, 1 = don't correct for bias
featMatrix(file).aveControlSkew = skewness(aveControl, 0);
featMatrix(file).modalControlSkew = skewness(modalControl, 0); 

% uniformness of the controllability metrics
    % with the KS test 
featMatrix(file).aveControlSkew = eveness(aveControl, 'ks'); 
featMatrix(file).modalControlSkew = eveness(modalControl, 'ks'); 

% average of the controllability metrics 
featMatrix(file).aveControlave = mean(aveControl); 
featMatrix(file).modalControlave = mean(modalControl); 

% graph theory? 

progressbar(file / length(files))
end

save('featMatrixM5', 'featMatrix'); 


end 
