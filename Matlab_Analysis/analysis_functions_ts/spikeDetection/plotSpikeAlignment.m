function plotSpikeAlignment(spikeMatrix)

for i = 1:size(spikeMatrix, 1)
    plot(spikeMatrix(i, :))
    hold on
end 
aesthetics() 
end 