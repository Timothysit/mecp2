function getSpikesCWTmain(path, recording, plts)

% path: path to the folder containing the recording(s)
% recording: the .mat raw voltage recording to analyze
% plts: 
    % plot & save plots = 1
    % otherwise = 0

currentPath = pwd;

excluded = [15 23 32];

% Create output folder and set paths
folderName = strrep(recording, '_TTX', '');
folderName = folderName(1:end-4);

if ~exist(folderName, 'dir')
    mkdir(folderName)
end

savePath = [currentPath '/' folderName '/'];

%% Load raw data
fileName = [path recording];
file = load(fileName);
data = file.dat;
channels = file.channels;
fs = file.fs;

%%   Run sequentially for each electrode (channel):
for channel = 1:length(channels)
    clearvars -except channel data file fileName fs ...
        channels savePath recording excluded plts
    
    if ~ismember(channel, excluded)
        %% Parameters
        Wid = [0.5 1.0];
        wname_list = {'bior1.5','bior1.3','mea','db2'};
        L = 0;
        Ns = 5;
        multiplier = 4;
        n_spikes = 200;
        ttx = contains(fileName, 'TTX');
        
        disp(['Electrode ', num2str(channel), ':']);
        
        % Initialize
        trace = data(:, channel);
        spike_struct = struct;
        
        
        %% Detect Spikes
        newFile = [recording(1:end-4) '_L=', num2str(L),'_ch=', num2str(channel),'_spike_struct.mat'];
        newFileName = [savePath newFile];
        
        disp(['Running spike detection']);
        tic
        for wname = wname_list
            sFr = [];
            wname = char(wname);
            
            [spikeFrames, filtTrace, threshold] = detectFramesCWT(trace, fs, Wid, wname, L, Ns, multiplier, ...
                n_spikes, ttx);
            
            valid_wname = strrep(wname, '.', 'p');
            spike_struct.(valid_wname) = spikeFrames;
        end
        toc
        
        disp(['Spike detection complete']);
        
        if ~exist(newFileName, 'file')
            save(newFileName, 'spike_struct');
        end
        
        wavelets = fieldnames(spike_struct);
        
        %% Merge all spikes together
        all_spikes = [];
        for wav = 1:numel(wavelets)
            all_spikes = union(all_spikes, spike_struct.(wavelets{wav}));
        end
        
        %% Generate intersection matrix
        intersectMatrix = zeros(length(all_spikes),length(wavelets));
        
        for wav = 1:length(wavelets)
            spikeTimes = spike_struct.(wavelets{wav});
            for spikeIndex = 1:length(all_spikes)
                if ismember(all_spikes(spikeIndex), spikeTimes)
                    intersectMatrix(spikeIndex, wav) = 1;
                end
            end
        end
        
        for spike = 1:length(intersectMatrix)
            clear ff
            ff = find(intersectMatrix(spike, :) == 1);
            if length(ff) == 1 && ff ~=0
                F(spike) = ff;
            end
        end
        
        
        
        %% Create and save all the plots
        
        if plts == 1
            %% Plot filtered voltage trace with spike markers
            
            close all;
            
            %   Plot raw trace
            figure()
            plot(filtTrace,'k');
            hold on;
            yOffset = threshold*2;
            
            %   Plot all spikes
            y = repmat(yOffset - 0, ...
                length(all_spikes), 1);
            
            spikeCounts{1} = length(y);
            
            scatter((all_spikes)', ...
                y, 'v','filled');
            hold on;
            
            %   Plot unique spikes for each wavelet
            for wav = 1:length(wavelets)
                
                uqSpkIdx = find(F == wav);
                uniqueSpikes = all_spikes(uqSpkIdx);
                
                y = repmat(yOffset - wav, ...
                    length(uniqueSpikes), 1);
                spikeCounts{wav+1} = length(y);
                
                scatter((uniqueSpikes)', ...
                    y, 'v','filled');
                hold on;
            end
            
            
            %   Plot common spikes (detected by all wavelets)
            uqSpkIdx = find(F == 0);
            uniqueSpikes = all_spikes(uqSpkIdx);
            
            y = repmat(yOffset - (length(wavelets)+1), ...
                length(uniqueSpikes), 1);
            spikeCounts{6} = length(y);
            
            scatter((uniqueSpikes)', ...
                y, 'v','filled');
            hold on;
            
            %   Add labels, etc.
            legend_labels = [{'Filtered trace' ;['All spikes']}; strcat(wavelets, ' (unique)');'Common spikes'];
            l = legend(legend_labels);
            l.Location = 'northeastoutside';
            l.FontSize = 20;
            l.Box = 'off';
            title({[strrep(recording(1:end-4),'_',' ')],['Total no. of spikes = ' num2str(length(all_spikes))],['L = ', num2str(L)],['']},'FontSize',20,'Interpreter','none');
            % set(gca, 'Visible', 'off')
            ylim([-2*threshold 2*threshold+5])
            xlim([1 length(trace)])
            
            xticks([])
            yticks([])
            ylabel(['Voltage (\muV)']);
            set(gca,'XColor','w', 'YColor','k');
            box off;
            
            pngExt = ['L=', num2str(L),'_ch=', num2str(channel),'.png'];
            figName = [savePath, 'spikeMarkers_', pngExt];
            if ~exist(figName, 'file')
                saveas(gcf, figName);
            end
            
            %% Plot moving average
            
            close all;
            
            
            moving_average_dur_in_sec = 10;
            moving_average_window_frame = moving_average_dur_in_sec * fs;
            
            figure()
            ax1 = subplot(3, 1, 1);
            caxis([1 4])
            for wav = 1:numel(wavelets)
                spike_train = zeros(length(filtTrace), 1);
                spike_train(spike_struct.(wavelets{wav})) = 1;
                spike_count_moving_mean = movmean(spike_train, moving_average_window_frame);
                plot(spike_count_moving_mean, 'Linewidth', 2)
                hold on;
                box off;
            end
            
            legend(wavelets, 'Location','northeastoutside','Box','off');
            set(gca,'TickDir','out');
            ylabel('Moving average spike count')
            
            ax2 = subplot(3, 1, [2, 3]);
            % Plot the filtered trace
            plot(filtTrace,'k')
            hold on;
            
            
            yOffset = max(filtTrace);
            for wav = 1:numel(wavelets)
                scatter(spike_struct.(wavelets{wav}), ...
                    repmat(yOffset + wav, ...
                    length(spike_struct.(wavelets{wav})), 1), 'v','filled');
                hold on;
            end
            
            
            thr = threshold/multiplier;
            yline(-thr*multiplier, 'r--', ['\sigma = ' num2str(multiplier)])
            
            legend_labels = [{'Filtered data'}; wavelets; 'threshold'];
            l = legend(legend_labels);
            l.Location = 'northeastoutside';
            l.Box = 'off';
            ylabel('Voltage (\muV)')
            xlabel('Time (frames)')
            caxis([1 4])
            
            linkaxes([ax1, ax2], 'x');
            
            sgtitle({['Detected spikes from channel ', num2str(channel)],['']});
            box off;
            
            figName = [savePath, 'movingAverage_', pngExt];
            if ~exist(figName, 'file')
                saveas(gcf, figName);
            end
            
            %% Get spike detection heatmap
            
            close all;
            
            
            figure()
            imagesc(intersectMatrix')
            xlabel('Spike number')
            yticks(1:length(wavelets));
            yticklabels(wavelets)
            ylabel('Wavelet used')
            
            figName = [savePath, 'spikeHeatMap_', pngExt];
            if ~exist(figName, 'file')
                saveas(gcf, figName);
            end
            
            %% Plot spikes that are concordant for all wavelets
            
            close all;
            
            spTrain = zeros(length(data),1);
            spTrain(all_spikes(1:1000)) = 1;
            alignment_duration = 0.01;
            [spikeWaves, averageSpike] = spikeAlignment(filtTrace, spTrain, ...
                fs, alignment_duration);
            peak_alignment_duration = 0.002;
            spike_aligment_method = 'peakghost';
            figure()
            plotSpikeAlignment(spikeWaves, spike_aligment_method, ...
                fs, peak_alignment_duration)
            xlabel('Time bins')
            ylabel('Filtered amplitude')
            title('Waveform of spikes detected by all wavelets')
            
            box off;
            xlabel('Time bins')
            ylabel('Voltage (\muV)')
            title('Waveform of spikes concordant between all wavelets')
            set(gca,'XColor','w', 'YColor','k');
            
            figName = [savePath, 'averageWaveform_', pngExt];
            if ~exist(figName, 'file')
                saveas(gcf, figName);
            end
            
            %% Plot first N spikes detected by each method
            close all;
            
            spikes_to_plot = 1000;
            
            figure()
            for wav = 1:numel(wavelets)
                subplot(1, numel(wavelets), wav)
                
                spike_idx_given_wavelet = find((intersectMatrix(1:spikes_to_plot, wav) == 1));
                spike_times_given_wavelet = all_spikes(spike_idx_given_wavelet);
                spTrain = zeros(length(spike_times_given_wavelet),1);
                spTrain(spike_times_given_wavelet) = 1;
                
                grossTotal.(wavelets{wav}) = length(spike_struct.(wavelets{wav}));
                
                if length(spike_times_given_wavelet) >= 3
                    
                    [spikeWaves, averageSpike] = spikeAlignment(filtTrace, spTrain, ...
                        fs, alignment_duration);
                    plotSpikeAlignment(spikeWaves, spike_aligment_method, ...
                        fs, peak_alignment_duration)
                    box off;
                    xlabel('Time bins')
                    ylabel('Voltage (\muV)')
                    
                    title(wavelets{wav});
                end
                ax(wav) = gca;
            end
            linkaxes(ax, 'y');
            sgtitle([num2str(spikes_to_plot), ' spikes detected by each wavelet'])
            
            figName = [savePath, 'allSpikesByWavelet_', pngExt];
            if ~exist(figName, 'file')
                saveas(gcf, figName);
            end
            
            %% Plot all unique spikes detected by each wavelet
            
            close all;
            
            
            figure()
            uniqueTotal = struct;
            for wav = 1:numel(wavelets)
                subplot(1, numel(wavelets), wav)
                
                spike_idx_unique_to_wavelet = find(...
                    (sum(intersectMatrix, 2) == 1) & ...
                    (intersectMatrix(:, wav) == 1) ...
                    );
                
                
                uniqueTotal.(wavelets{wav}) = length(spike_idx_unique_to_wavelet);
                spike_times_unique_to_wavelet = all_spikes(spike_idx_unique_to_wavelet);
                spTrain = zeros(length(spike_times_unique_to_wavelet),1);
                spTrain(spike_times_unique_to_wavelet) = 1;
                
                if length(spike_times_unique_to_wavelet) >= 3
                    
                    [spikeWaves, averageSpike] = spikeAlignment(filtTrace, spTrain, ...
                        fs, alignment_duration);
                    plotSpikeAlignment(spikeWaves, spike_aligment_method, ...
                        fs, peak_alignment_duration)
                    xlabel('Time bins')
                    ylabel('Voltage (\muV)')
                    aesthetics
                    
                    title(wavelets{wav});
                end
                ax(wav) = gca;
            end
            linkaxes(ax, 'y');
            sgtitle('Unique spikes detected by each wavelet')
            
            
            figName = [savePath, 'uniqueSpikesByWavelet_', pngExt];
            if ~exist(figName, 'file')
                saveas(gcf, figName);
            end
            
            
            %% Plot adapted wavelet for given channel
            %  This is the custom wavelet used by the 'mea' method
            close all;
            
            load('mother.mat')
            plot(X, Y, 'k', 'LineWidth', 2);
            box off;
            xticks([])
            yticks([])
            set(gca, 'Color', 'w', 'XColor', 'w', 'YColor', 'w');
            title({['Adapted wavelet','']},'FontSize', 15)
            
            figName = [savePath, 'customWavelet_', pngExt];
            if ~exist(figName, 'file')
                saveas(gcf, figName);
            end
            
        end
    end
end
end

