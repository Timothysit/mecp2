%% Trying out spike sorting code on organoid data

spike_results = load('/home/timsit/Dropbox/SANDbox-share/organoid/CWT_param_search/200708_slice1_1_-0p05_spikes.mat');

spike_wave_forms = spike_results.spike_wave_forms;

%% Naive approach, do PCA on spike waveform from each electrode 

electrode = 40;
electrode_spike_wave_forms = spike_wave_forms{electrode};

figure;
plot(electrode_spike_wave_forms);
title('All waveform from electrode');

new_waveform_matrix = zeros(41, num_waveform);

num_waveform = size(electrode_spike_wave_forms, 2);

for waveform_idx = 1:num_waveform
    waveform = electrode_spike_wave_forms(:, waveform_idx);
    % [pks,locs] = findpeaks(-waveform);
    peak = max(-waveform); 
    peak_loc = find(-waveform == peak);
    window_start = peak_loc - 20;
    window_end = peak_loc + 20;
    % window_start = max(1, peak_loc - 20);
    % window_end = min(51, peak_loc + 20);
    
    if (window_start >= 1) && (window_end <= 51)
        new_waveform_matrix(:, waveform_idx) = waveform(window_start:window_end); 
    end 
end 

new_waveform_matrix_with_waveform_idx = find(~all(new_waveform_matrix == 0,1));
new_waveform_matrix_subset = new_waveform_matrix(:, new_waveform_matrix_with_waveform_idx);

figure;
plot(new_waveform_matrix_subset)
title('All waveform from electrode min aligned')
set(gcf,'color','w')

%% Run PCA
[coeff, score, latent, tsquared, explained, mu] = pca(new_waveform_matrix_subset);

figure;
scatter(coeff(:, 1), coeff(:, 2));
xlabel('PC1')
ylabel('PC2')
set(gcf,'color','w')

num_PC = 2;
reduced_X = coeff(:, 1:num_PC);

%% Do HDBSCAN: https://github.com/Jorsorokin/HDBSCAN/blob/master/docs/fit_hdbscan_model.mdown

addpath(genpath('/home/timsit/HDBSCAN/'));
clusterer = HDBSCAN(reduced_X); 

% we can view our data matrix size
fprintf( 'Number of points: %i \n',clusterer.nPoints );
fprintf( 'Number of dimensions: %i \n',clusterer.nDims );

clusterer.fit_model(); 			% trains a cluster hierarchy
clusterer.get_best_clusters(); 	% finds the optimal "flat" clustering scheme
clusterer.get_membership();		% assigns cluster labels to the points in X

clustering_labels = clusterer.labels;

unique_clusters = unique(clustering_labels);
num_cluster = length(unique_clusters);

y_min = min(new_waveform_matrix_subset(:));
y_max = max(new_waveform_matrix_subset(:));

figure;
for cluster_label_idx = 1:num_cluster
    cluster_label = unique_clusters(cluster_label_idx);
    label_idx = find(clustering_labels == cluster_label);
    subplot(1, 1+num_cluster, 1)
    scatter(reduced_X(label_idx, 1), reduced_X(label_idx, 2));
    hold on
    xlabel('PC1')
    ylabel('PC2')
    
    subplot(1, 1+num_cluster, cluster_label_idx+1);
    plot(new_waveform_matrix_subset(:, label_idx))
    title_txt = sprintf('Cluster %.f', cluster_label); 
    title(title_txt);
    ylim([y_min, y_max]);
    xlabel('Time bins')
end 

set(gcf,'color','w')

% optional: use the HDBSCAN function to plot cluster
figure
clusterer.plot_clusters();

%% TODO: Run this across all electrodes






