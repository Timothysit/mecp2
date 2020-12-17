%% Load threshold files 
% The wavelet analysis for the same thing is currently in:
% costParameterAndNetworkStructure.m
fs = 25000;
new_samples_per_s = 1;
m3_edited_file = load('/media/timsit/timsitHD-2020-03/mecp2/organoid_data/alex-theshold-spikes/191210_slice1_DIV_g04_2018_mSpikes_3.mat');
m4_edited_file = load('/media/timsit/timsitHD-2020-03/mecp2/organoid_data/alex-theshold-spikes/191210_slice1_DIV_g04_2018_mSpikes_4.mat');
m5_edited_file = load('/media/timsit/timsitHD-2020-03/mecp2/organoid_data/alex-theshold-spikes/191210_slice1_DIV_g04_2018_mSpikes_5.mat');
m6_edited_file = load('/media/timsit/timsitHD-2020-03/mecp2/organoid_data/alex-theshold-spikes/191210_slice1_DIV_g04_2018_mSpikes_6.mat');

recording_duration = size(m3_edited_file.mSpikes, 1) / fs;

m3_spike_matrix = downSampleSum(full(m3_edited_file.mSpikes), recording_duration * new_samples_per_s);
m4_spike_matrix = downSampleSum(full(m4_edited_file.mSpikes), recording_duration * new_samples_per_s);
m5_spike_matrix = downSampleSum(full(m5_edited_file.mSpikes), recording_duration * new_samples_per_s);
m6_spike_matrix = downSampleSum(full(m6_edited_file.mSpikes), recording_duration * new_samples_per_s);

%% Look at spike matrix 
figure;
subplot(1, 4, 1)
imagesc(m6_spike_matrix')
title('multiplier: 6') 
subplot(1, 4, 2)
imagesc(m5_spike_matrix')
title('multiplier: 5') 
subplot(1, 4, 3)
imagesc(m4_spike_matrix')
title('multiplier: 4') 
subplot(1, 4, 4)
imagesc(m3_spike_matrix')
title('multiplier: 3') 

set(gcf, 'color', 'w');

%% Calculate correlations - Pearson 

m3_corr_matrix = corr(m3_spike_matrix);
m4_corr_matrix = corr(m4_spike_matrix);
m5_corr_matrix = corr(m5_spike_matrix);
m6_corr_matrix = corr(m6_spike_matrix);

%% Calculate correlations - STTC
dtv = 1;
Time = [0; recording_duration];
m3_corr_matrix = sttcMat(m3_spike_matrix, new_samples_per_s, dtv, Time);
m4_corr_matrix = sttcMat(m4_spike_matrix, new_samples_per_s, dtv, Time);
m5_corr_matrix = sttcMat(m5_spike_matrix, new_samples_per_s, dtv, Time);
m6_corr_matrix = sttcMat(m6_spike_matrix, new_samples_per_s, dtv, Time);


%% Look at corelation matrix
figure;
subplot(1, 4, 1)
imagesc(m6_corr_matrix, [0.75, 1])
title('multiplier: 6') 
subplot(1, 4, 2)
imagesc(m5_corr_matrix, [0.75, 1])
title('multiplier: 5') 
subplot(1, 4, 3)
imagesc(m4_corr_matrix, [0.75, 1])
title('multiplier: 4') 
subplot(1, 4, 4)
imagesc(m3_corr_matrix, [0.75, 1])
title('multiplier: 3') 

set(gcf, 'color', 'w');

%% Look at effective rank

% Replace NaNs with zeros 
m6_corr_matrix(isnan(m6_corr_matrix)) = 0;
m5_corr_matrix(isnan(m5_corr_matrix)) = 0;
m4_corr_matrix(isnan(m4_corr_matrix)) = 0;
m3_corr_matrix(isnan(m3_corr_matrix)) = 0;


% Absolute effective rank
m6_effrank = effRank(m6_corr_matrix, 'covariance');
m5_effrank = effRank(m5_corr_matrix, 'covariance');
m4_effrank = effRank(m4_corr_matrix, 'covariance');
m3_effrank = effRank(m3_corr_matrix, 'covariance');



% Relative effective rank 
numShuffle = 1000;
[rel_eff_rank_L0, original_eff_rank_L0, all_shuffled_eff_rank_L0] = relEffRank(m6_corr_matrix, numShuffle);
[rel_eff_rank_L0p1, original_eff_rank_L0p1, all_shuffled_eff_rank_L0p1] = relEffRank(m5_corr_matrix, numShuffle);
[rel_eff_rank_L0p2, original_eff_rank_L0p2, all_shuffled_eff_rank_L0p2] = relEffRank(m4_corr_matrix, numShuffle);
[rel_eff_rank_L0p25, original_eff_rank_L0p25, all_shuffled_eff_rank_L0p25] = relEffRank(m3_corr_matrix, numShuffle);

figure;
subplot(1, 4, 1)
histogram(all_shuffled_eff_rank_L0)
hold on
plot([original_eff_rank_L0, original_eff_rank_L0], [0, 140])
title_txt = sprintf('Relative effective rank: %.3f',  rel_eff_rank_L0);
text(1, 100, sprintf('Absolute effective rank %.3f', original_eff_rank_L0))

title(title_txt)

subplot(1, 4, 2)
histogram(all_shuffled_eff_rank_L0p1)
hold on
plot([original_eff_rank_L0p1, original_eff_rank_L0p1], [0, 140])
title_txt = sprintf('Relative effective rank: %.3f',  rel_eff_rank_L0p1);
text(1, 100, sprintf('Absolute effective rank %.3f', original_eff_rank_L0p1))
title(title_txt)

subplot(1, 4, 3)
histogram(all_shuffled_eff_rank_L0p2)
hold on
plot([original_eff_rank_L0p2, original_eff_rank_L0p2], [0, 140])
title_txt = sprintf('Relative effective rank: %.3f',  rel_eff_rank_L0p2);
text(1, 100, sprintf('Absolute effective rank %.3f', original_eff_rank_L0p2))
title(title_txt)

subplot(1, 4, 4)
histogram(all_shuffled_eff_rank_L0p25)
hold on
plot([original_eff_rank_L0p25, original_eff_rank_L0p25], [0, 140])
title_txt = sprintf('Relative effective rank: %.3f',  rel_eff_rank_L0p25);
text(1, 100, sprintf('Absolute effective rank %.3f', original_eff_rank_L0p25))
title(title_txt)

set(gcf, 'color', 'w');


%% NMF 
spikeMatrix = m4_spike_matrix;
num_nnmf_components = 4;
[W, H] = nnmf(spikeMatrix, num_nnmf_components);

custom_vmin = 0;
custom_vmax = 50;


figure
subplot(num_nnmf_components+1, 1, 1)
imagesc(spikeMatrix', [custom_vmin, custom_vmax]); 
title('Original data')


for nnmf_c = 1:num_nnmf_components

    subplot(num_nnmf_components+1, 1, nnmf_c+1)
    nnmf_component_matrix = W(:, nnmf_c) * H(nnmf_c, :);
    imagesc(nnmf_component_matrix', [custom_vmin, custom_vmax])
    title(strcat('NMF Component ', num2str(nnmf_c)))
 
end 

set(gcf, 'color', 'w');
