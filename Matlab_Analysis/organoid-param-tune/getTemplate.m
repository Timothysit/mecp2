function ave_trace = getTemplate(data, multiplier, refPeriod_ms, n_spikes_to_plot)

[spikeTrain, finalData, threshold] = detectSpikes(data, multiplier, refPeriod_ms);

sp_times = find(spikeTrain == 1);

if  sum(spikeTrain) < n_spikes_to_plot
    
    % If fewer spikes than specified - use the maximum possible number
    n_spikes_to_plot = sum(spikeTrain);
    disp('Not enough spikes detected with specified threshold, using ',num2str(n_spikes_to_plot),'instead');
end

for i = 1:n_spikes_to_plot

    sp_peak_time=find(finalData(sp_times(i):sp_times(i)+25)==min(finalData(sp_times(i):sp_times(i)+25)));
    
    if (sp_times(i))+sp_peak_time-25 < 1 | ...
            ~isempty(find(...
            finalData((sp_times(i))+sp_peak_time-25:(sp_times(i))+sp_peak_time+25) > 50)) | ...
            ~isempty(find(...
            finalData((sp_times(i))+sp_peak_time-25:(sp_times(i))+sp_peak_time+25) < -50))
        
    else
        all_trace(:,i) = finalData((sp_times(i))+sp_peak_time-25:(sp_times(i))+sp_peak_time+25);
    end
end

try
    for i = 1:size(all_trace, 1)
    ave_trace(i) = median(all_trace(i,:));
    end
catch
    disp('Problem with ave trace');
end
end