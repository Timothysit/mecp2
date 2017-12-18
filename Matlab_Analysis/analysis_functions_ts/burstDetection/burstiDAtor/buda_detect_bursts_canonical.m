function bursts=buda_detect_bursts_canonical(spikes,start_ISI,continue_ISI,min_nspikes)
% 'canonical' DA burst detection

% 20171213 TS: I think there is something wrong with the min_nspikes of thie code
% Seem to show the same number of brust even if I set a different 
% min_nspikes
%
% bursts=buda_detect_bursts_canonical(spikes,start_ISI,continue_ISI,min_nspikes)
%
% Inputs:
%   onsets       Nx1 vector with onsets of spikes. This can be from
%                read_wavemark_onsets
%   start_ISI    maximum ISI (inter-spike interval) to start a burst
%                default: .08 (80 ms)
%   stop_ISI     maximum ISI (inter-spike interval) to continue a burst
%                default: .16 (160 ms)
%   min_nspikes  minimum number of spikes to form a burst
%                default: 2
%
% Output:
%   burst        struct with the following fields:
%     .BuNr      the vector (1:B)', if B bursts were found
%     .nSp       Bx1 number of spikes in each burst
%     .firstSp   Bx1 burst onsets
%     .lastSp    Bx1 burst offsets
%     .center    Bx1 element-wise mean of .firstSp and .lastSp
%     .BuDur     Bx1 burst durations
%     .SpFreq    Bx1 spiking frequencies
%     .interSp   Bx1 average inter-spike interval
% 
% Example:
%  >> fn='bursts.pr.txt'
%  >> spikes=read_wavemark_onsets(fn);
%  >> bursts=detect_bursts_canonical(spikes);
%
% See also: read_wavemark_onsets
%
% NNO Oct 2013; ported from Java version of "Burstidator" (NNO Jan 2012)

% set defaults
if nargin<2, start_ISI=.08; end
if nargin<3, continue_ISI=.16; end
if nargin<4, min_nspikes=2; end

nspikes=numel(spikes);

in_burst=false;

burst_count=0;

% assume at most 1000 bursts - otherwise the program becomes slow
max_nbursts=1000;
burst_onsets=zeros(max_nbursts,1);
burst_durs=zeros(max_nbursts,1);
burst_spikecounts=zeros(max_nbursts,1);

for spikepos=1:nspikes
    in_last_spike=spikepos==nspikes;
    
    if ~in_burst && ~in_last_spike && ...
            spikes(spikepos+1)-spikes(spikepos)<start_ISI
        % currently not in burst, and less than start_ISI to previous spike
        % so a new potential birst is started
        in_burst=true;
        
        % tentatively add one to burst_count
        % if later on the burst turns out to be too short one is subtracted
        % from burst_count
        burst_count=burst_count+1;
        
        % store the onset of this burst
        first_spike=spikes(spikepos);
        burst_onsets(burst_count)=first_spike;
        
        % previous and current burst
        cur_burst_nspikes=2; 
    elseif in_burst && ~in_last_spike && ...
            spikes(spikepos+1)-spikes(spikepos)<continue_ISI
        % in a burst and the next spike has than continue_ISI time 
        % difference with the current spike, so continue the burst
        cur_burst_nspikes=cur_burst_nspikes+1;
    else
        % time difference more than continue_ISI - store current spike
        if in_burst 
            % check to see if enough spikes were in the current burst
            if cur_burst_nspikes>=min_nspikes
                last_spike=spikes(spikepos);
                
                % store the current spike
                burst_durs(burst_count)=last_spike-first_spike;
                burst_spikecounts(burst_count)=cur_burst_nspikes;
            end
        end
        
        % be ready to detect next burst
        in_burst=false;
    end
end

% cut off unused space
burst_onsets=burst_onsets(1:burst_count);
burst_durs=burst_durs(1:burst_count);
burst_spikecounts=burst_spikecounts(1:burst_count);

% set the output
bursts=struct();
bursts.BuNr=(1:burst_count)';
bursts.nSp=burst_spikecounts;
bursts.firstSp=burst_onsets;
bursts.lastSp=burst_onsets+burst_durs;
bursts.center=.5*(bursts.lastSp+bursts.firstSp);
bursts.BuDur=burst_durs;
bursts.SpFreq=bursts.nSp ./ bursts.BuDur;
bursts.interSp=bursts.BuDur ./ (bursts.nSp-1);