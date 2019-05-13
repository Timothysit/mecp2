# Some notes on MEA Data Analysis 

Author: Tim Sit 
Last Update: 20180621 

## Overview of analysis

To recapitulate the workflow diagram in the main README, the main workflow for MEA data analysis is: 

0. (Data conversion and perhaps some pre-procecessing) 
1. Spike Detection (Note that there is currently no code here for LFP anlaysis)
2. Inference of connectivity via some form of correlation-based metric 
3. Higher-level analysis based on this connectivity data 
  - effective rank (MATLAB) 
  - graph theory metric; degree distribution, centrality, hubs, small-worlds, etc. (R code under development)
  - controllability (MATLAB)
4. Machine Learning Classification (under development)

## Spike Detection 

All the code required for spike detection is within the `spikeDetection`. It is likely to be dependent on the Signal Processing Tooolbox in Matlab. 
The core algorithm for spike detection is `detectSpikes.m`, and within that I described some detection algorithms to use.
`getSpikeMatrix.m` runs the spike detection code over all electrodes for a given MEA, and so is often the function to use when extracting spikes. 

For visualisations, the main functions to use are `spikeAligment.m` and `plotSpikeAlignment.m`. 

There are also some scripts within the folder to think about how to better tune parameters for spike detectinon.

## Spike Processing 

Note that spikes are currently stored as a *sparse*  matrix with zeros and ones. 
Subsequent anlaysis usually converts it to full matrices before doing calculations, with a few that will also work directly with a sparse matrix. 
Note that code based on using spike times may be more efficient, and so this may be one direction to think about if processing time is an issue.

## Batch Analysis 

Other types of analysis - effective rank and control theory - are in their corresponding folders and so this will hopefully be straightfoward. 
To run the analysis of multiple MEAs, I suggest that one perform a first run through the files to extract spikes (assuming that your subsequent calculations will be based on spikes). 
This can be done with the script `batchGetSpike.m`

But before that, it may be helpfult to verify the quality of the signal in the MEAs, you can do that via `batchGridTrace.m`, which saves the raw voltage traces of each MEA. 
You can then look through the traces to check for abnormal electrodes. (It may useful here to develop automatic ways of doing this, for example, using a hard threshold of 50uV for filtered traces). 

You can then run the analysis over all spike files using `batchAnalyse.m`, it currently supports 

- some basic statistics 
- burst detection and burst statistics
- effective rank
- controllability metrics based on Gu et al 2015

but it should be striaghtfoward to develop your own functions, and add that to the batch analysis. 

This will then be saved in a matlab structure or cell file, allowing you to do statistical analysis. 



