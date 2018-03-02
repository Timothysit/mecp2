function batchGetSpike 
    % read all .mat files in directory, look for spikeMatrix or dat 
    % then extract spikes, save as SPARSE MATRIX 
    
    
    % note that this overwrites rather than append to the info file
    
    % I initially wanted to do this together with batch processing, 
    % but since I am still experimenting on the results that are obtained
    % from the various spike detection algorithms, I want to save them as 
    % sparse spike file first, so that in the future I can play around with
    % them without having to load the raw data again (unless I want to try
    % out another spike detection parameter / method)
    
    
    
    %% some parameters 

    files = dir('*.mat');  % where your .mat files are 
    % variable name containing MEA voltage recording should be either of 
    % these two:
    voltageVar = 'electrodeMatrix'; 
    voltageVar2 = 'dat';
    % assume it takes the form numSamp x numChannels
    % samplingRate = 25000; 
    progressbar
    for file = 1:length(files)
        try 
            data = load(files(file).name, voltageVar); 
            data = data.(voltageVar);
        catch 
            data = load(files(file).name, voltageVar2);
            data = data.(voltageVar2)'; 
            fprintf('Data loaded successfully \n') 
        end 
        % data = data.(voltageVar); % since matlab load struct 
        % data = electrodeMatrix
        % detect spikes
        tic;
        % mSpikes = sparse(getSpikeMatrix(data, 'Manuel', 5));
        tSpikes = sparse(getSpikeMatrix(data, 'Tim', 8));
        % pSpikes = sparse(getSpikeMatrix(data, 'Prez', 4));
        toc
    
        %% save 
        fileName = strcat(files(file).name(1:end-4), '_info', '.mat'); 
        % save(fileName, 'mSpikes', 'tSpikes', 'pSpikes');
        save(fileName, 'tSpikes');
        progressbar(file/length(files));
    end 
    
end 