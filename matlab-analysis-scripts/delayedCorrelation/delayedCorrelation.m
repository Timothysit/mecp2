%% Simulate delayed correlation 

addpath('/home/timsit/mecp2/Matlab_Analysis/analysis_functions_ts/corrAnalysis')
addpath('/home/timsit/mecp2/matlab-analysis-scripts/delayedCorrelation')

%% Two cell network 
random_walk_start_loc = 0;
recording_duration = 60;
sampling_rate = 1000;

num_time_steps = recording_duration * sampling_rate;
time_steps = linspace(0, recording_duration, num_time_steps);

cell_1_fr_mean = 10;  % spikes / second
cell_1_fr_std = 2;
cell_1_rand_walk = random_walk(num_time_steps, 1, random_walk_start_loc);
cell_1_zscore = zscore(cell_1_rand_walk);

cell_1_fr = cell_1_fr_mean + cell_1_fr_std * cell_1_zscore;

% sample from poisson process
cell_1_spikes = poissrnd(cell_1_fr / sampling_rate);
cell_1_spike_times = time_steps(find(cell_1_spikes >= 1));
cell_1_n_spikes = length(cell_1_spike_times);


% Make cell 2 a shifted version of cell 1
cell_2_fr_mean = 10;
cell_2_fr_std = 2;
cell_2_lag = 1;  % lag in seconds
cell_2_fr = zeros(num_time_steps, 1);
cell_2_init_rand_walk = random_walk(cell_2_lag*sampling_rate, 1, cell_1_rand_walk(1));
cell_2_init_rand_walk = fliplr(cell_2_init_rand_walk);
cell_2_init_zscore = zscore(cell_2_init_rand_walk);
cell_2_corr_zscore = zscore(cell_1_rand_walk(1:num_time_steps-cell_2_lag*sampling_rate));
cell_2_zscore = [cell_2_init_zscore; cell_2_corr_zscore];
cell_2_fr = cell_2_fr_mean + cell_2_fr_std * cell_2_zscore;

% sample from poisson process
cell_2_spikes = poissrnd(cell_2_fr / sampling_rate);
cell_2_spike_times = time_steps(find(cell_2_spikes >= 1));
cell_2_n_spikes = length(cell_2_spike_times);


figure; 
ax1 = subplot(2, 1, 1);
plot(time_steps, cell_1_fr);
title('Cell 1')
hold on 

max_fr = max(cell_1_fr);
scatter(cell_1_spike_times, repmat(max_fr + 1, cell_1_n_spikes, 1), 'k');
ylabel('Firing rate (spikes/s)')

ax2 = subplot(2, 1, 2);
plot(time_steps, cell_2_fr);
hold on
scatter(cell_2_spike_times, repmat(max_fr + 1, cell_2_n_spikes, 1), 'k');
title('Cell 2')

ylabel('Firing rate (spikes/s)')
xlabel('Time (seconds)')
set(gcf, 'color', 'white')

%% Method 1: calculate pearson correlation of binned spikes 

lag_duration_to_search = 10; %3 * sampling_rate;

% [r, lags] = xcorr(cell_1_spike_times, cell_2_spike_times);
% figure;
% plot(lags, r);

%{
cell_1_fr_circshift = circshift(cell_1_fr, cell_2_lag * sampling_rate);

figure;
plot(cell_1_fr);
hold on
plot(cell_1_fr_circshift);
%}

% [c, lags] = xcorr(cell_1_fr, cell_1_fr_circshift, lag_duration_to_search, 'normalized');
% figure;
% plot(lags, c);
% title('Cross corr on firing rate')

figure; 
plot(time_steps, cell_1_fr)
hold on 
plot(time_steps, cell_2_fr)
xlabel('Time')
ylabel('Firing rate (spikes/s)')
set(gcf, 'color', 'white')



lag_range_to_try = 2;
shifts_to_try = -lag_range_to_try * sampling_rate:lag_range_to_try * sampling_rate;
corrcoef_given_shift = zeros(length(shifts_to_try), 1);

for n_shift = 1:length(shifts_to_try)
    shift = shifts_to_try(n_shift);
    cell_2_fr_circshift = circshift(cell_2_fr, shift);
    corrcoef_r = corrcoef(cell_1_fr, cell_2_fr_circshift);
    corrcoef_given_shift(n_shift) = corrcoef_r(1, 2);
end 

figure; 
plot(shifts_to_try/sampling_rate, corrcoef_given_shift)
xlabel('Shifts (seconds)');
ylabel('Pearson correlation');
set(gcf, 'color', 'white')



%% Test 
n = 0:15;
x = 0.84.^n;
y = circshift(x,5);

figure;
plot(x)
hold on
plot(y)

figure

[c,lags] = xcorr(x,y,10,'normalized');
stem(lags,c)

%% Method 2: calculate STTC 
sttc_windows = linspace(0, 2, 100);
Time = [0 recording_duration];
N1v = length(cell_1_spike_times);
N2v = length(cell_2_spike_times);

tile_coef_given_dtv = zeros(length(sttc_windows), 1);

for n_dtv = 1:length(sttc_windows)
    dtv = sttc_windows(n_dtv);
    tileCoef_n1_n2 = sttc(N1v, N2v, dtv, Time, cell_1_spike_times, cell_2_spike_times);
    tile_coef_given_dtv(n_dtv) = tileCoef_n1_n2;
end 

figure;
plot(sttc_windows, tile_coef_given_dtv);
xlabel('STTC time window')
ylabel('STTC value')
set(gcf, 'color', 'white')

%% Do method 2 for multiple samples from the poissoin process 
num_simulations = 1000;
Time = [0 recording_duration];
cell_1_latent_spikes_per_s = cell_1_fr / sampling_rate;
cell_2_latent_spikes_per_s = cell_2_fr / sampling_rate;
dtv = 0.1;

num_shift_vals = 100;
lag_range_to_try = 2;
shift_windows_to_try = linspace(-lag_range_to_try, lag_range_to_try, num_shift_vals);
tile_coef_given_dtv_simulations = zeros(num_simulations, num_shift_vals);

for n_sim = 1:num_simulations
    [~, cell_1_spike_times] = simSpikesFromLatent(cell_1_latent_spikes_per_s, time_steps);
    [~, cell_2_spike_times] = simSpikesFromLatent(cell_2_latent_spikes_per_s, time_steps); 
    tile_coef_given_dtv_simulations(n_sim, :) = sttc_w_shifts(cell_1_spike_times, cell_2_spike_times, dtv, ...
                                             shift_windows_to_try, recording_duration, Time);
end 

%% Plot results 
figure;
subplot(1, 2, 1)
plot(shift_windows_to_try, median(tile_coef_given_dtv_simulations, 1));
subplot(1, 2, 2)
imagesc(tile_coef_given_dtv_simulations)


%% Method 3: fix the dtv, but then calculate STTC for given time shift
lag_range_to_try = 2;
shift_windows_to_try = linspace(-lag_range_to_try, lag_range_to_try, 100);
dtvs_to_try = [0.1, 0.2, 0.3, 0.5];
sttc_w_shift_results = zeros(length(shift_windows_to_try), length(dtvs_to_try));

for n_shift_window = 1:length(shift_windows_to_try)
    
    shift_time = shift_windows_to_try(n_shift_window);
    cell_2_spike_times_shifted = cell_2_spike_times + shift_time;
    shift_subset_idx = find(cell_2_spike_times_shifted >= 0 & ... 
                            cell_2_spike_times_shifted <= recording_duration); 
    cell_2_spike_times_shifted = cell_2_spike_times_shifted(shift_subset_idx);
    N1v = length(cell_1_spike_times);
    N2v = length(cell_2_spike_times_shifted);
    
    for n_dtv = 1:length(dtvs_to_try) 
        
        dtv = dtvs_to_try(n_dtv);
        tileCoef_n1_n2 = sttc(N1v, N2v, dtv, Time, ...
            cell_1_spike_times, cell_2_spike_times_shifted);
        sttc_w_shift_results(n_shift_window, n_dtv) = tileCoef_n1_n2;
        
    end 
    
    
end 

figure;
hold all;
for n_dtv = 1:length(dtvs_to_try) 
    
    plot(shift_windows_to_try, sttc_w_shift_results(:, n_dtv), 'linewidth', 2)
    
end 
legend('0.1', '0.2', '0.3', '0.5')
xlabel('Shift (seconds)')
ylabel('STTC')
set(gcf, 'color', 'white')

%% Method 4: bin spikes, then do pearson correlation
bin_width = 0.5;
edges = 0:bin_width:recording_duration;
shift_windows_to_try = linspace(-lag_range_to_try, lag_range_to_try, 100);
[cell_1_binned_fr, ~] = histcounts(cell_1_spike_times, edges);

corrcoef_given_shift = zeros(length(shift_windows_to_try), 1);

for n_shift_window = 1:length(shift_windows_to_try)
    
    shift_time = shift_windows_to_try(n_shift_window);
    cell_2_spike_times_shifted = cell_2_spike_times + shift_time;
    shift_subset_idx = find(cell_2_spike_times_shifted >= 0 & ... 
                            cell_2_spike_times_shifted <= recording_duration); 
    cell_2_spike_times_shifted = cell_2_spike_times_shifted(shift_subset_idx);
    
    [cell_2_binned_fr_shifted, ~] = histcounts(cell_2_spike_times_shifted, edges);

    corrcoef_r = corrcoef(cell_1_binned_fr, cell_2_binned_fr_shifted);
    corrcoef_given_shift(n_shift_window) = corrcoef_r(1, 2);

end 

figure;
plot(shift_windows_to_try, corrcoef_given_shift, 'linewidth', 2)
xlabel('Shift')
ylabel('Pearson correlation')
set(gcf, 'color', 'white')

%% Do the same but using many simulations 

num_simulations = 1000;
bin_width = 0.3;
edges = 0:bin_width:recording_duration;
num_lag_vals = 100;
shift_windows_to_try = linspace(-lag_range_to_try, lag_range_to_try, num_lag_vals);
corrcoef_given_shift_per_sim = zeros(num_simulations, num_lag_vals);

for n_sim = 1:num_simulations
    [~, cell_1_spike_times] = simSpikesFromLatent(cell_1_latent_spikes_per_s, time_steps);
    [~, cell_2_spike_times] = simSpikesFromLatent(cell_2_latent_spikes_per_s, time_steps); 
    
    corrcoef_given_shift = binned_corr_w_shift(cell_1_spike_times, cell_2_spike_times, ...
        bin_width, recording_duration, shift_windows_to_try);
    corrcoef_given_shift_per_sim(n_sim, :) = corrcoef_given_shift;
end 

%% Plot results 

figure;
subplot(1, 2, 1)
plot(shift_windows_to_try, median(corrcoef_given_shift_per_sim, 1));
subplot(1, 2, 2)
imagesc(corrcoef_given_shift_per_sim)




%% Try to shift the spikes directly (Poisson may be noisy...)


%% Try smoothing with half gaussian distribution

pd = makedist('HalfNormal','mu',0,'sigma',0.5);
x = 0:0.01:10;
pdf_half_normal = pdf(pd, x);
conv_vec = pdf_half_normal;
figure; 
plot(x, pdf_half_normal);

num_simulations = 1000;
bin_width = 0.01;
edges = 0:bin_width:recording_duration;
num_lag_vals = 100;
shift_windows_to_try = linspace(-lag_range_to_try, lag_range_to_try, num_lag_vals);
corrcoef_given_shift_per_sim = zeros(num_simulations, num_lag_vals);

for n_sim = 1:num_simulations
    [~, cell_1_spike_times] = simSpikesFromLatent(cell_1_latent_spikes_per_s, time_steps);
    [~, cell_2_spike_times] = simSpikesFromLatent(cell_2_latent_spikes_per_s, time_steps); 
    
    corrcoef_given_shift = binned_corr_w_shift(cell_1_spike_times, cell_2_spike_times, ...
        bin_width, recording_duration, shift_windows_to_try, conv_vec);
    corrcoef_given_shift_per_sim(n_sim, :) = corrcoef_given_shift;
end 


%% Plot results

figure;
subplot(1, 2, 1)
plot(shift_windows_to_try, median(corrcoef_given_shift_per_sim, 1));
subplot(1, 2, 2)
imagesc(corrcoef_given_shift_per_sim)





