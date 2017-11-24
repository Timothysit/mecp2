%% Animate the 3D PCA plot 

% this works for any 3D plot you have, as long as it is the current figure
OptionZ.FrameRate=15;OptionZ.Duration=10;OptionZ.Periodic=true; 
CaptureFigVid([-20,10;-110,10;-190,80;-290,10;-380,10], 'WellMadeVid', OptionZ)

%% Animate the spike detection and raw data

[spikeTrain, finalData, threshold] = detectSpikes(data, 'Manuel', 5); 
% spikeTrain = downsample(spikeTrain, 10000);
% spikes
spikePos = find(spikeTrain == 1); 


h = figure;
subplot(10, 1, [1 2])
singleRastPlot(spikeTrain);

% attempt to plot spikes in real time
% for j = 1:length(spikePos) 
%     plot([spikePos(j) spikePos(j)], [0 1], 'k')
%     hold on
% end 


% downsample to speed things up 
data = downsample(data, 25000);
subplot(10, 1, [3 10])
h = animatedline;
x = 1:length(data);
xlim([0 length(data)]);
removeYAxis();
aesthetics()
axis tight manual % this ensures that getframe() returns a consistent size
filename = 'testAnimated.gif';
for k = 1:length(x) 
    y = data(k);
    addpoints(h, x(k), y); 
    drawnow
    % Capture the plot as an image 
    frame = getframe(h); 
    im = frame2im(frame); 
    [imind,cm] = rgb2ind(im,256); 
    % Write to the GIF File 
    if k == 1 
       imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
    else 
       imwrite(imind,cm,filename,'gif','WriteMode','append'); 
    end 
end 

% ideally also animate the spikes in real time, but may be more
% difficult...

%% Second attempt to make a gif

h = figure;
axis tight manual % this ensures that getframe() returns a consistent size
filename = 'testAnimated.gif';
for n = 1:length(data)
    % Draw plot for y = x.^n
    x = 1:length(data); 
    y = data;
    plot(x(1:n),y(1:n))
    xlim([1 length(data)])
    ylim([min(data) max(data)])
    removeAxis 
    aesthetics
    drawnow 

      % Capture the plot as an image 
      frame = getframe(h); 
      im = frame2im(frame); 
      [imind,cm] = rgb2ind(im,256); 

      % Write to the GIF File 
      if n == 1 
          imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
      else 
          imwrite(imind,cm,filename,'gif','WriteMode','append'); 
      end 
 end


%% Animate but by shifting xlim 

