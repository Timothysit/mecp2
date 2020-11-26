%% Dependencies 

% stationarity test using Augmented Dickey-Fuller Test 
addpath('/home/timsit/mfe-toolbox/timeseries/')

%% Set up some example sequences to test 


% random stationary noise 
num_neurons = 10;
num_time_bins = 1000;
shared_baseline = 1;

% Define noise 
mu = 0; 
sigma = 1;

neuron_activity_matrix = zeros(num_time_bins, num_neurons); % T x N

for neuron = 1:num_neurons 
    neuron_activity_matrix(:, neuron) = normrnd(mu, sigma, num_time_bins, 1) + shared_baseline;
        
end 

figure;
imagesc(neuron_activity_matrix);


%% Naive approach Calculate C
% mean center each neuron 
X_centered = neuron_activity_matrix - mean(neuron_activity_matrix, 1); % T x N matrix
vec_X = X_centered(:);
C = vec_X * vec_X';

figure;
subplot(1, 2, 1)
plot(vec_X(1:num_time_bins));
subplot(1, 2, 2);
plot(X_centered(:, 1));

figure;
imagesc(C);

%% Decompose C to symmetric and skew-symmetric component 

% C_sym = (C + C') / 2;
% C_anti = (C - C') / 2;

% figure;
% imagesc(C_anti, [-1, 1]);

%% Decompose C to symmetric and anti-symmetric copmonent according to paper 
sigma_C = nan(size(C));

num_row = size(C, 1) / num_time_bins;
num_column = size(C, 1) / num_time_bins;

for row = 1:num_row
    
    row_start = (row-1) * num_time_bins + 1;
    row_end = row * num_time_bins;
    
    for column = 1:num_column
        
        column_start = (column-1) * num_time_bins + 1;
        column_end = column * num_time_bins;
        
        block= C(row_start:row_end, column_start:column_end);
        block_transposed = block';
        sigma_C(row_start:row_end, column_start:column_end) = block_transposed;
        
    end 
end 

C_plus = C + sigma_C;
C_minus = C - sigma_C;

% check one of the matrices to make sure this works 
figure; 
subplot(1, 2, 1)
C_subset = C(1:100, 301:400);
C_subset_anti = C_subset - C_subset';
imagesc(C_subset_anti)
subplot(1, 2, 2)
imagesc(C_minus(1:100, 301:400));

equality_holds = isequal(C_minus(1:100, 301:400), C_subset_anti);

%% Write the above as a function 

[C_minus, C_plus] = decomposeSymAndAntiSym(C, num_time_bins);

figure;
imagesc(C_minus, [-1, 1]);

result_equal = isequal(C_anti, C_minus);

%% Define sequentiality as 
s = sum(C_minus(:).^2) / sum(C_plus(:).^2); 

% s = sum(C_anti(:).^2) / sum(C_sym(:).^2); 

%% Just independent random noise between neurons 

num_neurons = 50;
num_time_bins = 300;
mu = 0;
sigma = 0.3;
baseline_fr = 1;
neuron_activity_matrix = zeros(num_time_bins, num_neurons); % T x N


for neuron = 1:num_neurons 
    neuron_activity_matrix(:, neuron) = normrnd(mu, sigma, num_time_bins, 1) + baseline_fr;
    % only positive firing rates
    neuron_activity_matrix = max(neuron_activity_matrix, 0);
end 

s = calSeq(neuron_activity_matrix, num_time_bins);

figure;
imagesc(neuron_activity_matrix')
xlabel('Time bins')
ylabel('Neuorns')
title_text = sprintf('Sequentiality: %.2f', s); 
title(title_text)



%% Independent noise multiple times to get a null distribution 
num_sim = 100;
num_neurons = 10;
num_time_bins = 100;
mu = 0;
sigma = 1;
baseline_fr = 0;

s = zeros(num_sim, 1); 

for sim = 1:num_sim
    neuron_activity_matrix = zeros(num_time_bins, num_neurons); % T x N
    for neuron = 1:num_neurons 
        neuron_activity_matrix(:, neuron) = normrnd(mu, sigma, num_time_bins, 1) + baseline_fr;
    end 
    s(sim) = calSeq(neuron_activity_matrix, num_time_bins);
end 

figure;
hist(s)
title_text = sprintf('Mean sequentiality: %.2f', mean(s)); 
title(title_text)

%% Increasing function with strong correlation between all neurons 

num_neurons = 50;
num_time_bins = 300;
mu = 0;
sigma = 0.3;
increasing_trend = linspace(0, 3, num_time_bins);

neuron_activity_matrix = zeros(num_time_bins, num_neurons); % T x N

for neuron = 1:num_neurons 
    neuron_activity_matrix(:, neuron) = normrnd(mu, sigma, num_time_bins, 1) + increasing_trend';
end 

figure;
imagesc(neuron_activity_matrix')
xlabel('Time bins')
ylabel('Neuorns')

s = calSeq(neuron_activity_matrix, num_time_bins);
title_text = sprintf('Sequentiality: %.2f', s); 
title(title_text)

%% Traveling wave without gaps 
num_neurons = 60;
num_time_bins = 100;
shared_baseline = 1;

neuron_activity_matrix = zeros(num_time_bins, num_neurons); 
sub_pattern = [0.5, 1, 0.5];

for nT = 1:2:num_time_bins
    neuron_idx = mod(nT, num_neurons);
    if neuron_idx == 0
        neuron_idx = num_neurons;
    end 
    neuron_activity_matrix(nT, neuron_idx) = 1;
end 


s = calSeq(neuron_activity_matrix, num_time_bins);

figure;
imagesc(neuron_activity_matrix')
xlabel('Time bins')
ylabel('Neuorns')
title_text = sprintf('Sequentiality: %.2f', s); 
title(title_text)

set(gcf, 'color', 'white')


%% Traveling wave with gaps
num_neurons = 10;
num_time_bins = 100;
shared_baseline = 1;

neuron_activity_matrix = zeros(num_time_bins, num_neurons); 
sub_pattern = [0.5, 1, 0.5];

for nT = 1:2:num_time_bins
    neuron_idx = mod(nT, num_neurons);
    if neuron_idx == 0
        neuron_idx = num_neurons;
    end 
    neuron_activity_matrix(nT, neuron_idx) = 1;
end 

neuron_activity_matrix(10:20, :) = 0;
neuron_activity_matrix(50:60, :) = 0;


% subset to units with activity 
unit_w_activity = find(sum(neuron_activity_matrix, 1) >= 1);
neuron_activity_matrix = neuron_activity_matrix(:, unit_w_activity); 

s = calSeq(neuron_activity_matrix, num_time_bins);

figure;
imagesc(neuron_activity_matrix')
xlabel('Time bins')
ylabel('Neuorns')
title_text = sprintf('Sequentiality: %.2f', s); 
title(title_text)



%% Diagonal matrix 
num_neurons = 10;
num_time_bins = 10;
shared_baseline = 1;

neuron_activity_matrix = eye(50);

s = calSeq(neuron_activity_matrix, num_time_bins);


figure;
imagesc(neuron_activity_matrix')
xlabel('Time bins')
ylabel('Neuorns')

title_text = sprintf('Sequentiality: %.2f', s); 
title(title_text)


all_neuron_idx = 1;

figure
% Look at xcorr 
for neuron_x = 1:neuron 
    for neuron_y = 1:num_neurons
        [c, lags] = xcorr(neuron_activity_matrix(:, neuron_x), neuron_activity_matrix(:, neuron_y));

        subplot(num_neurons, num_neurons, all_neuron_idx)
        stem(lags,c)
        all_neuron_idx = all_neuron_idx + 1;
        
    end 
end
    

%% Traveling wave without gaps + control with circ shift

num_neurons = 60;
num_time_bins = 100;
shared_baseline = 1;

neuron_activity_matrix = zeros(num_time_bins, num_neurons); 
sub_pattern = [0.5, 1, 0.5];

for nT = 1:2:num_time_bins
    neuron_idx = mod(nT, num_neurons);
    if neuron_idx == 0
        neuron_idx = num_neurons;
    end 
    neuron_activity_matrix(nT, neuron_idx) = 1;
end 


s = calSeq(neuron_activity_matrix);

figure;
imagesc(neuron_activity_matrix')
xlabel('Time bins')
ylabel('Neuorns')
title_text = sprintf('Sequentiality: %.2f', s); 
title(title_text)

set(gcf, 'color', 'white')

figure
num_circ_shift = 10;
circ_shifted_seq = zeros(num_circ_shift, 1);
for shift_idx = 1:num_circ_shift
    circ_shifted_tn = circshiftmat(neuron_activity_matrix')'; % need to do tranpose because 
    % circshiftmat shifs row, 
    circ_shifted_seq(shift_idx) = calSeq(circ_shifted_tn);
    subplot(2, 5, shift_idx)
    imagesc(circ_shifted_tn')
    title_text = sprintf('Sequentiality: %.2f', circ_shifted_seq(shift_idx)); 
    title(title_text)
end 

set(gcf, 'color', 'white')

% more shuffles 
num_circ_shift = 200;
circ_shifted_seq = zeros(num_circ_shift, 1);
for shift_idx = 1:num_circ_shift
    circ_shifted_tn = circshiftmat(neuron_activity_matrix')'; % need to do tranpose because 
    % circshiftmat shifs row, 
    circ_shifted_seq(shift_idx) = calSeq(circ_shifted_tn);
end 


figure;
histogram(circ_shifted_seq)
hold on
xline(s, '-r', 'LineWidth', 2)
set(gcf, 'color', 'white')
legend('Circ-shifted s', 'Original s', 'Location', 'bestoutside')
legend boxoff

xlabel('Sequentiality measure $s$', 'Interpreter', 'Latex')
ylabel('Count')

%% Independent poisson events 

neuron_fr = 1;
neuron_activity_matrix = zeros(num_time_bins, num_neurons); 

for neuron = 1:num_neurons 
    neuron_activity_matrix(:, neuron) = poissrnd(neuron_fr, num_time_bins, 1);
end 
s = calSeq(neuron_activity_matrix);
figure;
imagesc(neuron_activity_matrix')
xlabel('Time bins')
ylabel('Neuorns')
title_text = sprintf('Sequentiality: %.2f', s); 
title(title_text)
set(gcf, 'color', 'white')

num_circ_shift = 200;
circ_shifted_seq = zeros(num_circ_shift, 1);
for shift_idx = 1:num_circ_shift
    circ_shifted_tn = circshiftmat(neuron_activity_matrix')'; % need to do tranpose because 
    % circshiftmat shifs row, 
    circ_shifted_seq(shift_idx) = calSeq(circ_shifted_tn);
end 

figure;
histogram(circ_shifted_seq)
hold on
xline(s, '-r', 'LineWidth', 2)
set(gcf, 'color', 'white')
legend('Circ-shifted s', 'Original s', 'Location', 'bestoutside')
legend boxoff

xlabel('Sequentiality measure $s$', 'Interpreter', 'Latex')
ylabel('Count')


%% Compare python code and matlab code (just as a doubel check)

addpath(genpath('~/npy-matlab'))
nt = readNPY('/home/timsit/mecp2/python/notebooks/nt.npy');
tn = nt';



%% Make a vectorised version like Ginny's code 

[n, t] = size(nt); 
nt_vec = reshape(nt', 1, n*t);
c1 = nt_vec' * nt_vec;
c2 = reshape(c1, [t, n, t, n]);
c2 = permute(c2, [4, 3, 2, 1]);
c3 = permute(c2, [2, 3, 4, 1]);
c3 = reshape(c3, [n*t, n*t])';
cdiff = (c1-c3);
cplus = (c1+c3);
s = sum(cdiff(:).^2) / sum(cplus(:).^2); 

%% Test 
nt = [1, 2, 3; 4, 5, 6; 7, 8, 9; 10, 11, 12];
[n, t] = size(nt); 
nt_vec = reshape(nt', 1, n*t);
c1 = nt_vec' * nt_vec;
c2 = reshape(c1, [t, n, t, n]);
c2 = permute(c2, [4, 3, 2, 1]);
c3 = permute(c2, [2, 3, 4, 1]);
c3 = reshape(c3, [n*t, n*t])';
cdiff = (c1-c3);
cplus = (c1+c3);
s = sum(cdiff(:).^2) / sum(cplus(:).^2); 

%% Compared speed of loop vs. vectorised 
tn = rand(400, 60);

tic; 
s1 = calSeq(tn, size(tn, 1)); 
toc

tic; 
s2 = calSeqVec(tn); 
toc

fprintf('s1: %.4f \n', s1)
fprintf('s2: %.4f \n', s2)
