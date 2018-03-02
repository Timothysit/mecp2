function drawHist(spikeMatrix)
%DRAWHIST Draw histogram of spike counts
%   Assumes input: numSamp x numElectrode
    eSpike = sum(spikeMatrix, 1);
    % Create a gramm object
    g=gramm('x',eSpike);
    g.stat_bin()
    g.set_title('Histogram of spike counts')
    % Do the actual drawing
    g.draw()
   
end

