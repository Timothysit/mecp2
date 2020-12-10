%% Looking into single channel parameter tuning 

% load example data with TTX data
raw_data_folder = '/media/timsit/timsitHD-2020-03/mecp2/organoid_data/jeremi-detected-spikes-dec-2020/organoid/';
summary_plot_folder = '/media/timsit/timsitHD-2020-03/mecp2/organoid_data/jeremi-detected-spikes-summary-plot/dec-2020-organoid-single-channel-param-tune/';

recording_to_search = '200617_slice1';


recording_names = {dir([raw_data_folder '*.mat']).name};


target_recording_pre_ttx_files = {};
target_recording_post_ttx_files = {};

for r_name_idx = 1:length(recording_names)
    
    if contains(recording_names{r_name_idx}, recording_to_search)
        if ~contains(recording_names{r_name_idx}, 'TTX')
            target_recording_pre_ttx_files{end+1} = recording_names{r_name_idx};
        else
            target_recording_post_ttx_files{end+1} = recording_names{r_name_idx};
        end 
        
    end 
    
end 


%% Hard coded version for now 
% recording_to_search = '200617_slice9';
% recording_to_search = '191210_FTD_slice5_DIV_g07_2019';
% recording_to_search = '200708_slice3';
recording_to_search = '200127_FTDOrg_GrpD_5B_Slice2';

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


%% For each cost parameter, for each channel, look at pre-post TTX spike ratio 
start_time = 0;
new_sampling_rate = 1;
num_channel = 60;
num_param_searched = length(pre_ttx_results);

pre_post_ttx_channel_counts = zeros(num_param_searched, 2, num_channel);
cost_param_used = zeros(num_param_searched, 1);

f1 = figure;

for cost_param_idx = 1:num_param_searched
    % Get some basic info 
    cost_param_pre_ttx_results = pre_ttx_results{cost_param_idx};
    cost_param_post_ttx_results = post_ttx_results{cost_param_idx};
    fs = cost_param_pre_ttx_results.spikeDetectionResult.params.fs;
    
    % check their cost parameters are the same 
    pre_ttx_param = cost_param_pre_ttx_results.spikeDetectionResult.params.L;
    post_ttx_param = cost_param_post_ttx_results.spikeDetectionResult.params.L;
    assert(pre_ttx_param == post_ttx_param)
    
    % Pre TTX
    pre_ttx_end_time = cost_param_pre_ttx_results.spikeDetectionResult.params.duration;

    pre_ttx_channel_spike_matrix = spikeTimeToMatrix( ...
        cost_param_pre_ttx_results.spikeTimes, ...
    start_time,  pre_ttx_end_time, new_sampling_rate, fs);

    pre_ttx_per_channel_spike_rate = sum(pre_ttx_channel_spike_matrix, 1) / pre_ttx_end_time;
    
    % Post TTX
    post_ttx_end_time = cost_param_post_ttx_results.spikeDetectionResult.params.duration;

    post_ttx_channel_spike_matrix = spikeTimeToMatrix( ...
        cost_param_post_ttx_results.spikeTimes, ...
    start_time,  post_ttx_end_time, new_sampling_rate, fs);

    post_ttx_per_channel_spike_rate = sum(post_ttx_channel_spike_matrix, 1) / post_ttx_end_time;
    
    subplot(1, length(pre_ttx_results), cost_param_idx)
    scatter(pre_ttx_per_channel_spike_rate, post_ttx_per_channel_spike_rate)
    both_cond_min = min([pre_ttx_per_channel_spike_rate post_ttx_per_channel_spike_rate]);
    both_cond_max = max([pre_ttx_per_channel_spike_rate post_ttx_per_channel_spike_rate]);
    hold on;
    unity_vals = linspace(both_cond_min, both_cond_max, 100);
    line_alpha = 0.5;
    plot(unity_vals, unity_vals, 'color', [0, 0, 0]+line_alpha);
    
    xlim([both_cond_min, both_cond_max])
    ylim([both_cond_min, both_cond_max])
    xlabel('Pre-TTX spikes/s')
    ylabel('Post-TTX spikes/s')
    title_txt = sprintf('Cost parameter %.2f', pre_ttx_param);
    title(title_txt)
    
    pre_post_ttx_channel_counts(cost_param_idx, 1, :) = pre_ttx_per_channel_spike_rate(:);
    pre_post_ttx_channel_counts(cost_param_idx, 2, :) = post_ttx_per_channel_spike_rate(:);
    cost_param_used(cost_param_idx) = pre_ttx_param;
end 

set(gcf, 'color', 'w')
set(gca,'TickDir','out');
fig_save_name = [recording_to_search 'pre_post_unity'];
% print([summary_plot_folder fig_save_name], '-bestfit','-dpng')
f1.PaperUnits = 'inches';
f1.PaperPosition = [0 0 12 3]; 
print([summary_plot_folder fig_save_name], '-dpng', '-r600')

%% For each channel, look at spike ratio for different cost parameter 
reg_param = 1;
pre_post_ttx_ratio = pre_post_ttx_channel_counts(:, 1, :) ./ (pre_post_ttx_channel_counts(:, 2, :) + reg_param);
pre_post_ttx_ratio = squeeze(pre_post_ttx_ratio);

f2 = figure;
for channel_idx = 1:num_channel
    plot(cost_param_used, pre_post_ttx_ratio(:, channel_idx));
    scatter(cost_param_used, pre_post_ttx_ratio(:, channel_idx));
    hold on 
end 
xlabel('Cost parameter L')
ylabel('Pre-TTX / Post-TTX')
set(gcf, 'color', 'w')
set(gca,'TickDir','out');

fig_save_name = [recording_to_search 'pre_post_ttx_ratio'];
% print([summary_plot_folder fig_save_name], '-bestfit','-dpng')
f2.PaperUnits = 'inches';
f2.PaperPosition = [0 0 6 4]; 
print([summary_plot_folder fig_save_name], '-dpng', '-r600')
