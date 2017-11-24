function gridTrace(electrodeMatrix, downFactor)
    % WORK IN PROGRESS
    % plot the spike trace of the 60 electrodes 
    % exect electrode matrix to be of dimension samples x nChannels
    % specify 8 x 8 grid 
    % TODO: use same axes scale
    numRow = 8; 
    numColumn = 8; 
    trace = downsample(electrodeMatrix, downFactor);
    pL = 1:(size(electrodeMatrix, 2)+3);
    pL = pL(pL~=1); 
    pL = pL(pL~=8); 
    pL = pL(pL~=57);
   for plotN = 1:size(electrodeMatrix, 2)
       subplot(numRow, numColumn, pL(plotN))
       plot(trace(:, plotN))
       title(num2str(plotN))
       aesthetics()
       removeAxis()
       hold on
   end 
end 