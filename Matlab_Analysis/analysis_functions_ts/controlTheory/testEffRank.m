% Test effective rank result with different transformation on the raw
% spike train 

%% varying bin width 
samplingRate = 25000;
binWidth = 10.^(0:6); 
timeWidth = binWidth / samplingRate;
eRank = zeros(length(binWidth), 1); 
eRankCor = zeros(length(binWidth), 1); 
eRankSqCov = zeros(length(binWidth), 1); 
for n = 1:length(binWidth)
    dSpikes = downSampleSum(spikeMatrix, length(spikeMatrix) / binWidth(n)); 
    eRank(n) = effRank(dSpikes, 'covariance');
    eRankCor(n) = effRank(dSpikes, 'correlation'); 
    eRankSqCov(n) = effRank(sqrt(dSpikes), 'covariance'); 
end 

plot(log10(binWidth), eRank)
aesthetics
lineThickness(2)
% xlabel('Log_{10}(binWidth)') 
xlabel('Bin width (seconds)')
xticklabels(timeWidth) % convert binWidth to seconds
ylabel('Effective Rank') 

hold on 

plot(log10(binWidth), eRankCor) % using correlation
plot(log10(binWidth), eRankSqCov) % squareroot transform beforehand 

legend('covariance', 'correlation', 'sqrt transform, covariance') 
legend boxoff 

