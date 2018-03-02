% Plot Controllability metrics 

%% Get the structural connectivity adjacency matrix 
spikes = sparseDownSample(mSpikes, 720 * 1000, 'sum');

tic 
adjM = getAdjM(spikes, 'partialcorr'); 
toc
%% Compute controllability metrics 

aveControl = ave_control(adjM); 
modalControl = modal_control(adjM);


%% Plot them 

figure 
yyaxis left 
plot(aveControl) 
ylabel('Average controllability')
hold on 

yyaxis right
plot(modalControl) 
ylabel('Modal controllability')
xlabel('Electrode')

legend
aesthetics 
lineWidth(2)




