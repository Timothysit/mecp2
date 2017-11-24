% Control Theory Analysis Main Script

%% Get file and spikes 

% get the spikes
vFile = uigetfile('.mat', 'Select voltage recording'); 
load(vFile)

method = 'Manuel';
multiplier = 5;
spikeTrain = zeros(size(electrodeMatrix)); 
for i = 1:size(electrodeMatrix, 2)
data = electrodeMatrix(:, i); 
[spikeTrain(:, i), finalData, threshold] = detectSpikes(data, method, multiplier); 
end 

spikeTrain = spikeTrain'; 
numElectrode = size(spikeTrain, 1); 
% downsample our spikeTrain 
newSampleNum = 720 * 10;
downTrain = reshape(spikeTrain, numElectrode, newSampleNum, []);
downTrain = sum(downTrain, 3);
downTrain = reshape(downTrain, numElectrode, newSampleNum);



%% PCA 

[coeff, score, latent] = pca(downTrain);
% latent returns the eigenvalues 
plot(latent ./ sum(latent), '-o')
title('Principal Component analysis')
ylabel('Proportion variance')
xlabel('Principal components')
set(findall(gca, 'Type', 'Line'),'LineWidth',2);
vline(6.81, 'r', 'Effective Rank = 6.81')
aesthetics() 

% visualise PCA 
[coeff, score, latent] = pca(downTrain, 'NumComponents',3);
figure
biplot(coeff, 'Scores', score) % with the components
figure
scatter3(score(:, 1), score(:, 2), score(:, 3), 'LineWidth', 1)
xlabel('PC 1') 
ylabel('PC 2')
zlabel('PC 3')
aesthetics()

% zooming in particular region for 12096ADIV22 

xlim([-2 -1.6]) 
ylim([-0.7 -0.4]) 
zlim([0.12 0.2])

%% Effective Rank 

[effectiveRank, normEigenV] = effRank(downTrain); 
% effective rank for 12096ADIV22 is 6.8 without downsampling
% still 6.8 upon downsampling 

%fprintf(effectiveRank)

% plot the normalised eigen values
plot(normEigenV)

%% Auttocorrelation 

% https://dsp.stackexchange.com/questions/26547/matlab-how-to-create-an-autocorrelogram-using-a-spike-train/26572
fs = 1000; % for spikes
electrode = 20;
[autocor, lags] = xcorr(downTrain(electrode, :), fs * 120, 'coeff'); 
plot(lags/fs, autocor)
aesthetics(); 
xlabel('Lag (seconds)')
ylabel('Autocorrelation')

%% Cross-correlation 

crossCov = cov(downTrain');
crossCor = corrcoef(downTrain');

figure 
imagesc(crossCor)
colormap('hot');
colorbar; 
aesthetics() 


%% Factor Analysis 





