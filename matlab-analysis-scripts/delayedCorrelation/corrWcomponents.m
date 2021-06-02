%% Simulate multiple latent process, then calculate correlation of each component 


t = 0:0.01:100;
sine_freq = 0.1;
cos_freq = 0.1;
component_1 = 3 * sin(2*pi*sine_freq*t);
component_2 = 10 * linspace(0, 1, length(t));
component_3 = cos(2*pi*cos_freq*t);


neural_component_weights = [0, 1; ...
                            0.75, 1; ...
                            0.5, 1];
                        
figure; 
imagesc(neural_component_weights, [0, 1])
xlabel('Components')
ylabel('Neurons')
yticks([1, 2, 3])
xticks([1, 2])
colorbar
set(gcf, 'color', 'white')
                        
neural_frs = neural_component_weights * [component_1; component_2];


figure; 
plot(t, component_1, 'linewidth', 2)
hold on 
plot(t, component_2, 'linewidth', 2);
ylabel('Latent variable value')
legend('Latent 1', 'Latent 2')
set(gcf, 'color', 'white')
ylabel('Time (seconds)')

figure; 
imagesc(neural_frs);
xlabel('Time')
yticks([1, 2, 3])
ylabel('Neurons')
set(gcf, 'color', 'white')


figure;
plot(t, neural_frs(1, :), 'linewidth', 2);
hold on 
plot(t, neural_frs(2, :), 'linewidth', 2);
hold on
plot(t, neural_frs(3, :), 'linewidth', 2);
legend('Neuron 1', 'Neuron 2', 'Neuron 3')
set(gcf, 'color', 'white')
xlabel('Time')
ylabel('Firing rate (spikes/s)') 


corr_matrix_all_components = corr(neural_frs');
figure; 
imagesc(corr_matrix_all_components, [0, 1])
xticks([1, 2, 3]);
yticks([1, 2, 3]);
cbar = colorbar;
cbar.Title.String = "Pearson's correlation";

xlabel('Neuron')
ylabel('Neuron')
set(gcf, 'color', 'white')


%% NMF
num_nnmf_components = 2;
[W, H] = nnmf(neural_frs, num_nnmf_components);

figure; 
imagesc(W);
cbar = colorbar;
cbar.Title.String = "NMF component weight";
xticks([1, 2])
yticks([1, 2, 3])
ylabel('Neurons')
xlabel('NMF components')
set(gcf, 'color', 'white')

component_1_projection = W(:, 1) * H(1, :);

figure;
% subplot(1, 2, 1)
imagesc(component_1_projection)
set(gcf, 'color', 'white')
xlabel('Time')
yticks([1, 2, 3])
ylabel('Neurons')
% subplot(1, 2, 2)
% component_1_corr = corr(component_1_projection');
% imagesc(component_1_corr, [0, 1])


figure;
component_2_projection = W(:, 2) * H(2, :);
imagesc(component_2_projection)
xlabel('Time')
yticks([1, 2, 3])
ylabel('Neurons')
set(gcf, 'color', 'white')

% component_2_corr = corr(component_2_projection');

W_corr = corr(W');

figure; 
imagesc(W_corr, [-1, 1])

%% Subtract out components, then calculate correlation

component_subtracted_fr = neural_frs - component_2_projection;
subtracted_corr = corr(component_subtracted_fr');
figure;
imagesc(subtracted_corr, [0, 1])
xticks([1, 2, 3])
xlabel('Neurons')
yticks([1, 2, 3])
ylabel('Neurons')
set(gcf, 'color', 'white')


component_subtracted_fr = neural_frs - component_1_projection;
subtracted_corr = corr(component_subtracted_fr');
figure;
imagesc(subtracted_corr, [0, 1])
xticks([1, 2, 3])
xlabel('Neurons')
yticks([1, 2, 3])
ylabel('Neurons')
set(gcf, 'color', 'white')

%% cosine simliarty matrix 

dist_mat = pdist(component_subtracted_fr, 'cosine');
figure; 
imagesc(dist_mat);
xticks([0, 1, 2])
yticks([0, 1, 2]);

