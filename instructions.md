# Instructions

Here you will find instructions for: 

- converting "raw" data obtained from MEA to format avilable for matlab analysis 
- overlaying heatmaps of spike statistic (count, rate, burst etc.) onto photo of MEA


## Workflow for matlab analysis 

This section describes how to convert raw `.mcd` files to `.mat` files so you can do some analysis of the electrode recordings on matlab. I use matlab for spectral analysis: power, coherence, and maybe some graph theory based analysis (See Schroeter et al). 

Requirements: 

- computer running Windows XP / 7 / 10 
- matlab 
- MC_DataTool: http://www.multichannelsystems.com/software/mc-datatool
- `Matlab_MEA`: https://github.com/nictera/Matlab_MEA

### Part I: Convert `.mcd` files to `.raw` files using `MC_DataTool`

1. open MC_DataTool 
2. File-Open Multiple 
3. Select files of interest 
4. Click "bin" (Convert Mcd to Binary)
5. Click "All" in the electrode array figure
6. Make sure "Write header" and "Signed 16bit" are checked in lower right
7. Click Save 
8. when done, click Close

### Part II: Convert `.raw` files to `.mat` files using `MEA_batchConvert`

After creating the raw files, get into the directory with the raw files in matlab and run

```matlab
MEA_batchConvert
```

This will create subfolders for each raw file. You can get into one of these folders and run, for example,

plot_MEA([15 41:45])
This will plot channels 15 and 41 through 45.

To combine the subfolders into one big file, do the following: 

- add folder contaning `combineMat.m` to path 
- add folder contaning your subfolders containing the mat files into your path 
- change to that folder (which contains subfolders contaning the mat files)
- run `combineMat.m`


## How to overlay heatmap onto cell culture 

Requirements: 

- gimp 
- heatmap photos (usually in png but other formats are okay)
- MEA culture photos (usually in TIF)

Steps: 

- Open Gimp 
- Go to open, select heatmap photo 
- Go to open again, select MEA photo, it should open in a new window 
- MEA photo may be dark, if so, go to colour --> contrast and brightness, usually a value of 120 for contrast and 120 for brightness will do the job, but play around with those values to make sure
- right click on the MEA photo --> edit --> copy (shorcut: `ctrl + c`)
- go to the heatmap window and paste on top (shorcut: `ctrl + v`)
- rotate -90 (make sure that electrode 15 is on the left mid area). Rotation can be done by using the rotate tool (shortcut: `shift + R`) 
- adjust opacity
- scale by using the scale tool (shortcut: `shift + T`)
    + move the picture around to ensure fit (shortcut: `m`)
- change the mode of the overaly, usually "soft light", "overlay", or "hard light" does the job quite well. "hard light" might be slightly better because it shows the cells more...)(but then the heatmap is more affected than in the case of soft light) but some cropping will have to be done... but I suppose at this stage we don't have to get into that yet (but for publishing we will have to)

Examples: 

![Using hard light](https://i.imgur.com/csANe7Q.png)

![Using soft light](https://i.imgur.com/DoKgfum.png)
