function spikeTrain = lookAtHfile(fileName)
% things to improved 
% ( ) add the actual electrode index to the matrix
% or use struct 
% select h5 file
spikeTimes = h5read(fileName, '/spikes'); 
% extract spmatlke time series 

%% we first need to convert it to a matrix by separating out the electrodes
spikes = [];
electrode = 1;
jj = 1;
for ii = 1:length(spikeTimes)
    spikes(jj, electrode) = spikeTimes(ii);
    if ii == length(spikeTimes) 
        break % reached the last measurement of last electrode
    elseif spikeTimes(ii) < spikeTimes(ii + 1)
        jj = jj + 1; % continue counter
    else 
        jj = 1; % reset counter
        electrode = electrode + 1; % move on to next electrode
    end 
        
end 
% yeah this works, not the most effieicnt way, but it works 

%% now we count the number of spikes within each time frame 
spikes(spikes == 0)  = nan; % 
% for example, number of spikes each second 
recordTime = 12 * 60; % time of recording in seconds
window = 0:1:recordTime;
spikeTrain = histc(spikes, window); 
% checked that it works columnwise for matrices
%% check that we counted the correct number of spikes
if sum(sum(spikeTrain)) == length(spikeTimes)
    fprintf('Function executed correctly \n')
else 
    fprinf('There is something wrong with the function \n') 
end 

end
