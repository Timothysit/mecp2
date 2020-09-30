function [newWaveletIntegral, newWaveletSqN] = customWavelet(ave_trace)

template = ave_trace;

% Interpolation
template = spline(1:length(template), template, linspace(1, length(template), 100));

% Gaussian smoothing
w = gausswin(8);
y = filter(w,1,template);
y = rescale(y);
y = y - mean(y);

% Pre-allocate
signal = zeros(1, 250);

% Center the template
signal(76:175) = y;

% Adapt the wavelet
[Y,X,nc] = pat2cwav(y, 'orthconst', 0, 'none') ;

% Test if a legitmate wavelet
dxval = max(diff(X));
newWaveletIntegral = dxval*sum(Y); %    Should be 1.0
newWaveletSqN = dxval*sum(Y.^2);
newWaveletSqN = round(newWaveletSqN,10); % Should be zero

% Save the wavelet
if newWaveletSqN == 1.0000
    
    % Using built-in cwt method requires saving the custom wavelet each
    % time - currently overwriting as there is no reason to retrieve the
    % wavelet
    
    save('mother.mat', 'X', 'Y');
    wavemngr('del', 'meaCustom');
    
    % All wavelets cunstructed with wavemngr are type 4 wavelets
    % without a scaling function
    wavemngr('add', 'meaCustom','mea', 4, '', 'mother.mat', [-100 100]);
    wname = 'mea';
else
    disp('ERROR: Not a proper wavelet');
    disp(['Integral = ', num2str(newWaveletIntegral)]);
    disp(['L^2 norm = ', num2str(newWaveletSqN)]);
end
end
