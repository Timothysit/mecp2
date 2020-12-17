% Does using different cost parameter change our view of network structure 

raw_data_folder = '/media/timsit/timsitHD-2020-03/mecp2/organoid_data/jeremi-detected-spikes-dec-2020/organoid/';
summary_plot_folder = '/media/timsit/timsitHD-2020-03/mecp2/organoid_data/jeremi-detected-spikes-summary-plot/dec-2020-organoid-single-channel-param-tune/';


recording_to_search = '200708_slice1';

pre_ttx_L0 = load([raw_data_folder sprintf('%s_L_0_spikes.mat', recording_to_search)]);
pre_ttx_L0p1 = load([raw_data_folder sprintf('%s_L_-0.1_spikes.mat', recording_to_search)]);
pre_ttx_L0p2 = load([raw_data_folder sprintf('%s_L_-0.2_spikes.mat', recording_to_search)]);
pre_ttx_L0p25 = load([raw_data_folder sprintf('%s_L_-0.25_spikes.mat', recording_to_search)]);

post_ttx_L0 = load([raw_data_folder sprintf('%s_TTX_L_0_spikes.mat', recording_to_search)]);
post_ttx_L0p1 = load([raw_data_folder sprintf('%s_TTX_L_-0.1_spikes.mat', recording_to_search)]);
post_ttx_L0p2 = load([raw_data_folder sprintf('%s_TTX_L_-0.2_spikes.mat', recording_to_search)]);
post_ttx_L0p25 = load([raw_data_folder sprintf('%s_TTX_L_-0.25_spikes.mat', recording_to_search)]);

pre_ttx_results = {pre_ttx_L0; pre_ttx_L0p1; pre_ttx_L0p2; pre_ttx_L0p25};
post_ttx_results = {post_ttx_L0; post_ttx_L0p1; post_ttx_L0p2; post_ttx_L0p25};

%% Look at spike matrix 
start_time = 0;
pre_ttx_end_time = pre_ttx_L0.spikeDetectionResult.params.duration;
new_sampling_rate = 1;
fs = 25000;

pre_ttx_L0_spikeMatrix = spikeTimeToMatrix( ...
        pre_ttx_L0.spikeTimes, ...
    start_time,  pre_ttx_end_time, new_sampling_rate, fs);

pre_ttx_L0p1_spikeMatrix = spikeTimeToMatrix( ...
        pre_ttx_L0p1.spikeTimes, ...
    start_time,  pre_ttx_end_time, new_sampling_rate, fs);

pre_ttx_L0p2_spikeMatrix = spikeTimeToMatrix( ...
        pre_ttx_L0p2.spikeTimes, ...
    start_time,  pre_ttx_end_time, new_sampling_rate, fs);

pre_ttx_L0p25_spikeMatrix = spikeTimeToMatrix( ...
        pre_ttx_L0p25.spikeTimes, ...
    start_time,  pre_ttx_end_time, new_sampling_rate, fs);


figure;
subplot(1, 4, 1)
imagesc(pre_ttx_L0_spikeMatrix')
title('multiplier: 6') 
title('L: 0') 
subplot(1, 4, 2)
imagesc(pre_ttx_L0p1_spikeMatrix')
title('multiplier: 5') 
title('L: -0.1') 
subplot(1, 4, 3)
imagesc(pre_ttx_L0p2_spikeMatrix')
title('L: -0.2') 
subplot(1, 4, 4)
imagesc(pre_ttx_L0p25_spikeMatrix')
title('L: -0.25') 

set(gcf, 'color', 'w');


%% For each of them, compute correlation matrix 

%%  Using pearson correlation 
pre_ttx_L0_corr_matrix = corr(pre_ttx_L0_spikeMatrix);
pre_ttx_L0p1_corr_matrix = corr(pre_ttx_L0p1_spikeMatrix);
pre_ttx_L0p2_corr_matrix = corr(pre_ttx_L0p2_spikeMatrix);
pre_ttx_L0p25_corr_matrix = corr(pre_ttx_L0p25_spikeMatrix);

%%  Use STTC
dtv = 1;
Time = [0; pre_ttx_end_time];
pre_ttx_L0_corr_matrix = sttcMat(pre_ttx_L0_spikeMatrix, new_sampling_rate, dtv, Time);
pre_ttx_L0p1_corr_matrix = sttcMat(pre_ttx_L0p1_spikeMatrix, new_sampling_rate, dtv, Time);
pre_ttx_L0p2_corr_matrix = sttcMat(pre_ttx_L0p2_spikeMatrix, new_sampling_rate, dtv, Time);
pre_ttx_L0p25_corr_matrix = sttcMat(pre_ttx_L0p25_spikeMatrix, new_sampling_rate, dtv, Time);

%% Plot correlation matrix

figure;
subplot(1, 4, 1)
imagesc(pre_ttx_L0_corr_matrix, [0.75, 1])
title('L: 0') 
subplot(1, 4, 2)
imagesc(pre_ttx_L0p1_corr_matrix, [0.75, 1])
title('L: -0.1') 
subplot(1, 4, 3)
imagesc(pre_ttx_L0p2_corr_matrix, [0.75, 1])
title('L: -0.2') 
subplot(1, 4, 4)
imagesc(pre_ttx_L0p25_corr_matrix, [0.75, 1])
title('L: -0.25') 

set(gcf, 'color', 'w');

%% Absolute effective rank
pre_ttx_L0_effrank = effRank(pre_ttx_L0_spikeMatrix, 'covariance');
pre_ttx_L0p1_effrank = effRank(pre_ttx_L0p1_spikeMatrix, 'covariance');
pre_ttx_L0p2_effrank = effRank(pre_ttx_L0p2_spikeMatrix, 'covariance');
pre_ttx_L0p25_effrank = effRank(pre_ttx_L0p25_spikeMatrix, 'covariance');

% Relative effective rank 
numShuffle = 1000;
[rel_eff_rank_L0, original_eff_rank_L0, all_shuffled_eff_rank_L0] = relEffRank(pre_ttx_L0_spikeMatrix, numShuffle);
[rel_eff_rank_L0p1, original_eff_rank_L0p1, all_shuffled_eff_rank_L0p1] = relEffRank(pre_ttx_L0p1_spikeMatrix, numShuffle);
[rel_eff_rank_L0p2, original_eff_rank_L0p2, all_shuffled_eff_rank_L0p2] = relEffRank(pre_ttx_L0p2_spikeMatrix, numShuffle);
[rel_eff_rank_L0p25, original_eff_rank_L0p25, all_shuffled_eff_rank_L0p25] = relEffRank(pre_ttx_L0p25_spikeMatrix, numShuffle);

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
spikeMatrix = pre_ttx_L0p1_spikeMatrix;
num_nnmf_components = 4;
custom_vmin = 0;
custom_vmax = 30;

[W, H] = nnmf(spikeMatrix, num_nnmf_components);

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

