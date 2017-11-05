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
% now just need to remove the zeros, and also prevent using ii+1
% and simplify the code so there's not repeats. 
%% now we count the number of spikes within each time frame 
spikes(spikes == 0)  = nan; % 
recordTime = 12 * 60 + 1; % time of recording in seconds
spikes(spikes > recordTime) = nan; 
% seomtimes there are reported spikes over 720 seconds, remove those
% for example, number of spikes each second 
window = 0:1:recordTime; % look at spike every 1 second
spikeTrain = histc(spikes, window); 
% checked that it works columnwise for matrices
%% check that we counted the correct number of spikes
if sum(sum(spikeTrain)) == length(spikeTimes)
    fprintf('Function executed correctly \n')
else 
    error('There is something wrong with the function \n') 
end 

end

