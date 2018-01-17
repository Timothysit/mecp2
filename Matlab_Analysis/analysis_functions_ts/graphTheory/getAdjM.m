function adjM = getAdjM(spikes, method)
% getAdjM computes the weighted adjacency matrix of given spike counts 

% INPUT 
    % spikes: spike counts, expect dimensions to be numSample x numChannel
    % method: string argument for the method used to compute adjacency 
        % correlation (OKAY)
        % partial correlation (WORKING)
        % xcorr : correlation with lag (TODO)
        % mutual information (TODO)

% unsparse the matrix if it is sparse

if issparse(spikes) 
    spikes = full(spikes); 
end 

% calculate weighted adjacency matrix 
        
if strcmp(method, 'correlation') 
    adjM = corr(spikes); 
elseif strcmp(method, 'partialcorr')
    adjM = partialcorr(spikes);
    % [Pxcorr] = Plagged(spikes); 
elseif strcmp(method, 'xcorr')
    
elseif strcmp(method, 'mutInfo')
    
end 
        


end 