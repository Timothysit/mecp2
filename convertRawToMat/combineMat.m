% select folder containing the files to combine
% or better, loop through each folder in the root directory 

% things to improve with this code:
% [] automatically add folders to directory
% to do

folderWithMatFolders = uigetdir; 
% addpath(folderWtihMatFolders);
cd(folderWithMatFolders);  
mainDir = dir; 
% https://www.mathworks.com/matlabcentral/answers/121033-how-to-loop-through-a-folder
directoryNames = {mainDir([mainDir.isdir]).name}; 
directoryNames = directoryNames(~ismember(directoryNames,{'.','..'})); 
% remove '.' and '..' from our list 

electrodeMatrix = []; 
electrodeIndex = []; 
% electrodeIndex stores the order in which the time series are store 
% eg. if the first element of electrodeIndex is 12, then the first column
% is the time series for electrode 12 
for folder = 1:length(directoryNames) 
    fileNames = dir(directoryNames{folder}); 
    fileNames = fileNames(3:end); % remove first two columns, which are empty
    for file = 1:length(fileNames) 
        load(fileNames(file).name)
        % use filename to set electrode numbering
        % or generate a vector with the list of correct numbering
        electrodeMatrix(:, file) = dat;  
        indexString = fileNames(file).name(end-5:end-4); 
        electrodeIndex(file) = str2double(indexString); %name last 5 and 6 character;  
    end 
    save(directoryNames{folder}, 'electrodeMatrix', 'electrodeIndex', ... 
        'ADCz', 'channels', 'fs', 'uV', '-v7.3')
    % note that MAT-file version 7.3 or later is requried for > 2GB
    clear electrodeMatrix electrodeIndex
end 

% put them in one big matrix (using dat) 

% IGNORE below, this is from pre-20171027 version 
% NOTE: we will do this in the order of channels, note that the order goes
% horizontally: [x 21 31 41 51 ...]
%               [12 22 32 ........] will be the electrode layout 
% list of things to keep: channels, fs, uV AdCz
