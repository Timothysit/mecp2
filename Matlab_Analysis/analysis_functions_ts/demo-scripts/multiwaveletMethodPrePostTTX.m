%% Testing multiple wavelet detection on pre and post-TTX data 

% add multiwavelet method to path 


%% load raw data 

pre_TTX_data = load('/home/timsit/mecp2/data/MPT200209_3A_DIV12.mat');

post_TTX_data = load('/home/timsit/mecp2/data/MPT200209_3A_DIV12_TTX.mat');

%% Run wavelet detection: Pre-TTX data

wname_list = {'bior1.5', 'haar', 'bior1.3', 'db2'};
filter_data = 1;
pre_TTX_raw_traces = pre_TTX_data.dat;
pre_TTX_channel_names = pre_TTX_data.channels;
fs = pre_TTX_data.fs;

pre_TTX_mea_spike_struct = detect_spikes_multiwavelet(pre_TTX_raw_traces, fs, ... 
    filter_data, wname_list, pre_TTX_channel_names);


% save the pre TTX detection data
save('MPT200209_3A_DIV_12_multiwavelet_spikes', 'pre_TTX_mea_spike_struct');


%% Run wavelet detectio: Post-TTX data

wname_list = {'bior1.5', 'haar', 'bior1.3', 'db2'};
filter_data = 1;
post_TTX_raw_traces = post_TTX_data.dat;
post_TTX_channel_names = post_TTX_data.channels;
fs = post_TTX_data.fs;

post_TTX_mea_spike_struct = detect_spikes_multiwavelet(post_TTX_raw_traces, fs, ... 
    filter_data, wname_list, post_TTX_channel_names);

% save the post TTX detection data
save('MPT200209_3A_DIV_12_TTX_multiwavelet_spikes', 'post_TTX_mea_spike_struct');


%% Incrementally adding spikes: bior1.5 and bior1.5 + bior1.3 
round_decimal_places = 3;
wname_list_1 = {'bior1p5'};
wname_list_2 = {'bior1p5', 'bior1p3'};
round_decimal_places = 3;

% look at the unique spikes detected in the first set of wavelet(s)
% TODO: this can be made into a function to avoid repeats
channel_fields = fieldnames(pre_TTX_mea_spike_struct);

wname_list_1_spike_count = zeros(numel(channel_fields, 1));
wname_list_2_spike_count = zeros(numel(channel_fields, 1));

for channel_idx = 1:numel(channel_fields)
    spike_struct = pre_TTX_mea_spike_struct.(channel_fields{channel_idx});
    
    if length(wname_list_1) == 1
        intersection_matrix_1 = nan;
        unique_spike_times_1 = spike_struct.(wname_list_1{1});
    else
        [intersection_matrix_1, unique_spike_times_1] = ... 
    findGroupIntersectSpikes(spike_struct, fs, round_decimal_places);        
    end 
    
    wname_list_1_spike_count(channel_idx) = length(unique_spike_times_1);
    
    subset_spike_struct = struct;
    
    for target_field_idx = 1:length(wname_list_2)
        field_name = wname_list_2{target_field_idx};
        subset_spike_struct.(field_name) = spike_struct.(field_name);
    end
    
    [interesection_matrix_2, unique_spike_times_2] = ...
        findGroupIntersectSpikes(subset_spike_struct, fs, round_decimal_places);  

    wname_list_2_spike_count(channel_idx) = length(unique_spike_times_2);
    
end 

% Repeat the same procedure with the post TTX data

post_TTX_wname_list_1_spike_count = zeros(numel(channel_fields, 1));
post_TTX_wname_list_2_spike_count = zeros(numel(channel_fields, 1));

for channel_idx = 1:numel(channel_fields)
    spike_struct = post_TTX_mea_spike_struct.(channel_fields{channel_idx});
    
    if length(wname_list_1) == 1
        intersection_matrix_1 = nan;
        unique_spike_times_1 = spike_struct.(wname_list_1{1});
    else
        [intersection_matrix_1, unique_spike_times_1] = ... 
    findGroupIntersectSpikes(spike_struct, fs, round_decimal_places);        
    end 
    
    post_TTX_wname_list_1_spike_count(channel_idx) = length(unique_spike_times_1);
    
    subset_spike_struct = struct;
    
    for target_field_idx = 1:length(wname_list_2)
        field_name = wname_list_2{target_field_idx};
        subset_spike_struct.(field_name) = spike_struct.(field_name);
    end
    
    [interesection_matrix_2, unique_spike_times_2] = ...
        findGroupIntersectSpikes(subset_spike_struct, fs, round_decimal_places);  

    post_TTX_wname_list_2_spike_count(channel_idx) = length(unique_spike_times_2);
    
end 


%% Plot results: bior1.5 vs. bior1.5 + 1.3

wavelet_combination_used = '';
for wavelet_idx = 1:length(wname_list_2)
    wavelet_combination_used = strcat(wavelet_combination_used, ... 
        wname_list_2(wavelet_idx), ',', {' '});
end 
wavelet_combination_used = char(wavelet_combination_used);

% unity plot of spikes detected per channel using the different set
% of templates (after merging overlapping spikes)
figure()
subplot(1, 2, 1)
pre_TTX_min = min([wname_list_1_spike_count, wname_list_2_spike_count]);
pre_TTX_max = max([wname_list_1_spike_count, wname_list_2_spike_count]);
scatter(wname_list_1_spike_count, wname_list_2_spike_count)
hold on;
pre_TTX_unity_values = linspace(pre_TTX_min, pre_TTX_max, 1000);
plot(pre_TTX_unity_values, pre_TTX_unity_values);
xlabel('Spike count using bior1.5 wavelet');
% ylabel('Spike count using bior1.5 + bior1.3 wavelet');

ylabel(strcat('Spike count using the wavelets:', {' '}, ...
    wavelet_combination_used(1:end-2)));
title('Pre-TTX')


subplot(1, 2, 2)

post_TTX_min = min([post_TTX_wname_list_1_spike_count, ...
                    post_TTX_wname_list_2_spike_count]);
       
post_TTX_max = max([post_TTX_wname_list_1_spike_count, ...
                    post_TTX_wname_list_2_spike_count]);


scatter(post_TTX_wname_list_1_spike_count, post_TTX_wname_list_2_spike_count)
hold on;
post_TTX_unity_values = linspace(post_TTX_min, post_TTX_max, 1000);
plot(post_TTX_unity_values, post_TTX_unity_values);
xlabel('Spike count using bior1.5 wavelet');
% ylabel('Spike count using bior1.5 + bior1.3 wavelet');
ylabel(strcat('Spike count using the wavelets:', {' '}, ...
    wavelet_combination_used(1:end-2)));
title('Post-TTX')


set(gcf,'color','w');

% save figure
set(gcf, 'PaperUnits', 'inches');
x_width=8 ;y_width=4;
set(gcf, 'PaperPosition', [0 0 x_width y_width]); %
print -r300
saveas(gcf,'bior1p5_vs_bior1p5_and_bior1p3.png')



%% Incrementally adding spikes: bior1.5 and bior1.5 + haar
round_decimal_places = 3;
wname_list_1 = {'bior1p5'};
wname_list_2 = {'bior1p5', 'haar'};
round_decimal_places = 3;

% look at the unique spikes detected in the first set of wavelet(s)
% TODO: this can be made into a function to avoid repeats
channel_fields = fieldnames(pre_TTX_mea_spike_struct);

wname_list_1_spike_count = zeros(numel(channel_fields, 1));
wname_list_2_spike_count = zeros(numel(channel_fields, 1));

for channel_idx = 1:numel(channel_fields)
    spike_struct = pre_TTX_mea_spike_struct.(channel_fields{channel_idx});
    
    if length(wname_list_1) == 1
        intersection_matrix_1 = nan;
        unique_spike_times_1 = spike_struct.(wname_list_1{1});
    else
        [intersection_matrix_1, unique_spike_times_1] = ... 
    findGroupIntersectSpikes(spike_struct, fs, round_decimal_places);        
    end 
    
    wname_list_1_spike_count(channel_idx) = length(unique_spike_times_1);
    
    for target_field_idx = 1:length(wname_list_2)
        field_name = wname_list_2{target_field_idx};
        subset_spike_struct.(field_name) = spike_struct.(field_name);
    end
    
    [interesection_matrix_2, unique_spike_times_2] = ...
        findGroupIntersectSpikes(subset_spike_struct, fs, round_decimal_places);  

    wname_list_2_spike_count(channel_idx) = length(unique_spike_times_2);
    
end 

% Repeat the same procedure with the post TTX data

post_TTX_wname_list_1_spike_count = zeros(numel(channel_fields, 1));
post_TTX_wname_list_2_spike_count = zeros(numel(channel_fields, 1));

for channel_idx = 1:numel(channel_fields)
    spike_struct = post_TTX_mea_spike_struct.(channel_fields{channel_idx});
    
    if length(wname_list_1) == 1
        intersection_matrix_1 = nan;
        unique_spike_times_1 = spike_struct.(wname_list_1{1});
    else
        [intersection_matrix_1, unique_spike_times_1] = ... 
    findGroupIntersectSpikes(spike_struct, fs, round_decimal_places);        
    end 
    
    post_TTX_wname_list_1_spike_count(channel_idx) = length(unique_spike_times_1);
    
    for target_field_idx = 1:length(wname_list_2)
        field_name = wname_list_2{target_field_idx};
        subset_spike_struct.(field_name) = spike_struct.(field_name);
    end
    
    [interesection_matrix_2, unique_spike_times_2] = ...
        findGroupIntersectSpikes(subset_spike_struct, fs, round_decimal_places);  

    post_TTX_wname_list_2_spike_count(channel_idx) = length(unique_spike_times_2);
    
end 


%% Plot results: bior1.5 vs. bior1.5 + haar

% unity plot of spikes detected per channel using the different set
% of templates (after merging overlapping spikes)
figure()
subplot(1, 2, 1)
pre_TTX_min = min([wname_list_1_spike_count, wname_list_2_spike_count]);
pre_TTX_max = max([wname_list_1_spike_count, wname_list_2_spike_count]);
scatter(wname_list_1_spike_count, wname_list_2_spike_count)
hold on;
pre_TTX_unity_values = linspace(pre_TTX_min, pre_TTX_max, 1000);
plot(pre_TTX_unity_values, pre_TTX_unity_values);
xlabel('Spike count using bior1.5 wavelet');
% ylabel('Spike count using bior1.5 + bior1.3 wavelet');

wavelet_combination_used = '';
for wavelet_idx = 1:length(wname_list_2)
    wavelet_combination_used = strcat(wavelet_combination_used, ... 
        wname_list_2(wavelet_idx), ',', {' '});
end 
wavelet_combination_used = char(wavelet_combination_used);

ylabel(strcat('Spike count using the wavelets:', {' '}, ...
    wavelet_combination_used(1:end-2)));
title('Pre-TTX')


subplot(1, 2, 2)

post_TTX_min = min([post_TTX_wname_list_1_spike_count, ...
                    post_TTX_wname_list_2_spike_count]);
       
post_TTX_max = max([post_TTX_wname_list_1_spike_count, ...
                    post_TTX_wname_list_2_spike_count]);


scatter(post_TTX_wname_list_1_spike_count, post_TTX_wname_list_2_spike_count)
hold on;
post_TTX_unity_values = linspace(post_TTX_min, post_TTX_max, 1000);
plot(post_TTX_unity_values, post_TTX_unity_values);
xlabel('Spike count using bior1.5 wavelet');
ylabel(strcat('Spike count using the wavelets:', {' '}, ...
    wavelet_combination_used(1:end-2)));
title('Post-TTX')

aesthetics();

% save figure
set(gcf, 'PaperUnits', 'inches');
x_width=8 ;y_width=4;
set(gcf, 'PaperPosition', [0 0 x_width y_width]); %
print -r300
saveas(gcf,'bior1p5_vs_bior1p5_and_haar.png')

