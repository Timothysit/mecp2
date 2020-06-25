% Grouping wavelet families


%% Generate each wavelet from a dirac function (Signal)

Wid = [0.5, 1.0];
Ns = 5; % Ns - (scalar): the number of scales to use in detection (Ns >= 2);

SFr = 25;  % in kHz
dt = 1/SFr;  %[msec]

%signal sampled @ 1 KHz
Signal = zeros(1,1000);
%create Dirac function
Signal(500) = 1;


Width = linspace(Wid(1),Wid(2),Ns);

%infinitesimally small number
Eps = 10^(-15);

ScaleMax = 3;
ScaleMax = ScaleMax*SFr;



Scales = 1:75;
wname_list = {'bior1.5', 'bior1.3', 'bior2.2', 'bior2.4', ...
              'db2', 'db3', 'db4', 'db5', ...
              'cmor1.5-1', 'cgau3', 'mexh'...
              'haar'};
          
wavelet_tensor = zeros(length(Scales), 1000, length(wname_list));

for wavelet_index = 1:length(wname_list)
    wname = wname_list{wavelet_index};
    c = real(cwt(Signal,Scales,wname));
    wavelet_tensor(:, :, wavelet_index) = c;
end 


%% Select a particular scale and plot each wavelet

scale_to_plot = 25;

figure()

for wavelet_index = 1:length(wname_list)
    plot(wavelet_tensor(scale_to_plot, :, wavelet_index))
    hold on
end 


%% Save results 
wavelet_two_PCA = score(:, 1:2);
save('wavelet_tensor', 'wavelet_tensor')
save('wavelet_matrix', 'wavelet_matrix');
save('wavelet_two_PCA', 'wavelet_two_PCA');

%% Compute similarity between each wavelet

wavelet_matrix = reshape(wavelet_tensor, ...
    [size(wavelet_tensor, 1) * size(wavelet_tensor, 2), ...
    size(wavelet_tensor,3)]);

figure
for wavelet_index = 1:length(wname_list)
    plot(wavelet_matrix(:, wavelet_index))
    hold on
end 

figure 

wavelet_corr = corr(wavelet_matrix);
imagesc(wavelet_corr)


%% Do PCA to two components and plot each matrix

[wavelet_coeff, score, latent] = pca(wavelet_matrix');
top_two_wavelet_coeff = wavelet_coeff(:, 1:2);

figure()
scatter(score(:, 1), score(:, 2))

xlabel('Principal Component 1')
ylabel('Principal Component 2')


%% Save results to plot it elsewhere





