%% Look at PCA: PCs and eigenvalue decay 

addpath('/home/timsit/mecp2/Matlab_Analysis/organoid-param-tune');

%% Load spike matrix 

load('/home/timsit/Dropbox/SANDbox-share/organoid/CWT_param_search/200708_slice1_1_-0p05_spikes.mat')
start_time = 0;
end_time = 300;
sampling_rate = 10;
spikeTimesStruct = spikeDetectionResult.spikeTimes;
spikeMatrix = spikeTimeToMatrix(spikeTimesStruct, start_time, end_time, sampling_rate);
num_channel = size(spikeMatrix, 2);
%% Check columsn are linearly independent 

corr_matrix = corr(spikeMatrix);
corr_sum = sum(corr_matrix);

if sum(corr_sum == num_channel) > 0
    fprintf('Warning: at least one channel is perfectly correlated with another')
end 

channel_spike_count = sum(spikeMatrix);
if min(channel_spike_count) == 0
    fprintf('Warning: at least one channel has no spikes, downstream dimensionality analysis may be wrong')
end 

%% Do PCA / SVD

% Note the matrix will be centered within pca() 
[coeff, score, latent, tsquared, explained, mu] = pca(spikeMatrix);

% score: pricnipel component scores
% latent: PC variances: eigenvalues of the covariance matrix of X

num_pc = size(coeff, 1);

figure 
yyaxis left 
plot(1:num_pc, explained)
scatter(1:num_pc, explained)
ylabel('Percentage variance')
hold on 
yyaxis right 
plot(1:num_pc, latent)
ylabel('Eigenvalue')
set(gcf,'color','w');

%% SVD on spike matrix 
mean_centered_spike_matrix = spikeMatrix - mean(spikeMatrix);
[U, S, V] = svd(mean_centered_spike_matrix);
diag_S = diag(S);

figure
subplot(5, 2, 1)
imagesc(mean_centered_spike_matrix'); 
title('Original (mean-centered) data')

num_component_to_plot = 4;

for component = 1:num_component_to_plot
    U_component = U(:, component);
    s_component = diag_S(component);
    V_component = V(:, component);
    data_component = U_component .* s_component * V_component';
    subplot(5, 2, 1+2*component)
    imagesc(data_component'); 
    title(strcat('Component ', num2str(component)))
    subplot(5, 2, 2+component*2);
    plot(score(:, component));
end 
    
%% Try non-negative matrix factorisation 
num_nnmf_components = 4;
[W, H] = nnmf(spikeMatrix, num_nnmf_components);

figure
subplot(num_nnmf_components+1, 1, 1)
imagesc(spikeMatrix'); 
title('Original data')


for nnmf_c = 1:num_nnmf_components

    subplot(num_nnmf_components+1, 1, nnmf_c+1)
    nnmf_component_matrix = W(:, nnmf_c) * H(nnmf_c, :);
    imagesc(nnmf_component_matrix')
    title(strcat('NMF Component ', num2str(nnmf_c)))
 
end 




