function  plotBurst(burstCell, plotNumber)
% plotBurst Plots the burst using a raster plot. 
%   INPUT 
    % burstCell:  a n x 1 cell, where n is the number of bursts 
    % each cell contain a t x e matrix, where t is the frames of the
    % recording and e is the number of electrodes 
    % expect the t x e matrix to be binary, where 0 = no spike, 1 = spike 
    
    % plotNumber: single or vector integers saying how many and which plots
    % to make 
    
    
    for plotN = plotNumber
        rastPlot(full(burstCell{plotN}))
    end 
    

end

