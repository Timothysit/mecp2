function plot_MEA(channels)
%form:  plot_MEA(channels)
%
%example:  plot_MEA([1 2 7 82])
%example:  plot_MEA(82:85)
%
%Run in directory created by MEA_load_bin (called by MEA_batchConvert.m)
%


%% get files
d=dir;
files=[];
chs=[];
for i=1:length(d)
    if ~isempty(findstr(d(i).name,'.mat')) && length(d(i).name)>2 
        for j=1:length(channels)
            if ~isempty(findstr(d(i).name,['_' num2str(channels(j)) '.mat']))
                files=[files; i];
                chs=[chs; channels(j)];
            end;
        end;
    end;
end;

files=d(files);

%% get data and plot
figure

for i=1:length(chs)
    subplot(length(chs),1,i)
    load(files(i).name)
    plot(dat,'k')
    axis tight
    box off
end;
    
    figname=['Chs: ' num2str(chs') ' Duration: ' num2str(length(dat)/fs) ' sec'];
    set(gcf,'name',figname);





end

