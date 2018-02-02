# Things to talk about

- progress 
    + spike detection: 3 methods. Question: any other good methods? 
        * 1. (Manuel) Butterworth, threshold = mean - multiplier * stdev
        * 2. (Wave_clus) Elliptical, threshold = median - multiplier * stdev
        * 3. (Tim) Non-linear energy operator, threshold = mean * multiplier
    + looking at effective rank within burst only. Question: any good? / valid? 
    + effective rank: values still quite high; basically either poor connection, or a lot of noise in the data; just spontaneous random firing
    + factor analysis. Question: how to make it a feature? 
    + controllability: average and modal controllability. Question: is it any good, can it be used as a feature? 
        * particularly: assumption 1. partial correlation = structural connectivity 
        * assumption 2. linear dynamics 
    + if controllability metric okay, then controllability distribution
        * skewness: valid metric? 
        * methods for looking at skewness 
- upcoming tasks 
    + any new features? 
    + what to do with factor analysis? 
        * GPFA? does it work? will it give any insight? 
    + any methods of looking at sparse spikes? 


# List of featuers that we currently have

(averaged over 60 electrodes)


1. Average firing rate 
2. Total burst count 
3. Average burst count 
4. Regularity 
    - based on calculation by Mochizuki et al / Eglen / Prez 
    - fit ISI to gamma distirbution and look at the log shape 
    - logshape = 0 : Poisson disitributed spikes 
    - logshape < 0 : bursting 
    - logshape > 0 : sporadic firing 
    - the greater the absolute value of logshape, the more regular the spikes
5. Effective Rank 
    - used covariance
6. Average controllability 
    - based on calculations by Gu et al 2015
    - assume structural connectivity (made from partial correlation)
    - assume linear dynamics
7. Modal controllability 
8. Skewness of average and modal controllability 
    - directly use `skewness` function on matlab 
    - corrected for bias (flag = 0)
9. Eveness of average and modal controllability 
    - used Kologorov Smirnov test (KS-test)
    - assumption 1: make a unifrom distribution using the min and max of the data 
    - then do a ks test, then take the p value as a quantificaiton of the eveness

Other possible features?

- network burst (from Eglen, basically burst but requiriing a minimum of 6 electrodes or so)


# Current challenges: 

- low SNR / spike detection 
    + spike detection should actually be okay... but because of SNR, may need to make spike detection more robust 
    + tried out non-linear energy operator
    + currently using mean * fixed paramter as threshold for NEO 
    + and mean (or median) + fixed parameter * std as threshold 
    + included refractory period (2.0ms)
    + parameter setting is key, tried out gradient method, but the spike-count vs. threshold plot doens't have a sudden drop as I would have expected, therefore not sure to what extent that will be effective; I am worried that this approach may just lead to random thresholds

# Results

## Spike detection parameter tuning 

Currently, the value of the multipliers are set based on previous papers. I am thinking about how to set it in a principled manner. One way is to look at the how the spike count changes as we vary the threhsold, as use the gradient to set the threshold.


Electrode with low spike count according to current spike detection methods (and low fluctuation just by looking at raw trace): 

![1209 6A DIV22 E11](https://i.imgur.com/QGTpM1C.png)


Electrode with high spike count according to current spike detection methods (and high fluctuation just by looking at raw trace):

![1209 6A DIV22 E37](https://i.imgur.com/Aya1QG0.png)

so in this case, shoudl the thresold be 3? (using Prez's or Manuel's method)




## Sample of raw data


1209-6A DIV22

![1209 6A DIV22 grid trace](https://i.imgur.com/Ru8i5jK.png)



## Some sample Raster plots 

1209-6A DIV22

![Wave_clus, multiplier = 4](https://i.imgur.com/Gb9LR0I.png)

![sNEO, 1209 6A DIV 22, multiplier = 8](https://i.imgur.com/tjRFs9i.png)



## Some sample of spike counts 

1209-6A DIV22

![Spike count heat map 1209 6A DIV22](https://i.imgur.com/KTtfR4p.png)


## Effective rank and other summary stats (See R document)

![1209-6A DIV22](https://i.imgur.com/F8RQF01.png)



But I think this was done by using quite a generous spike detection algorithm. The more conservative spike detection method (Manuel's method, multiplier of 5, with refractory period) return near full rank values.


## Controllability; average and modal 

Based on calculations and code by Gu et al 2015 (Bassett group)

1209-6A DIV22

![Average and modal controllability of ](https://i.imgur.com/Zni5GTZ.png)

Gu et al (2015) noted anticorrelation between average and modal controllability, so this is expected.
 
## Controllability distribution (1209-6A DIV22)

![Average controllability heatmap](https://i.imgur.com/hWzTyc9.png)

My current thinking is that we can quantify the distribution of this; 

1. Skewness 
2. Uniformity


## Factor analysis 

![Factor loading for 1209-6A DIV22](https://i.imgur.com/13Ph7X4.png)

Not too sure how to look at factor anlaysis...

- how to interpret it 
- how to make a feature for classification


# Some documents

[Some summary stats for 1209 batch](https://www.dropbox.com/s/rzd1smaf12kx2e4/summaryStats20171215.pdf?dl=0)

[Gu 2015 paper on controllability metrics](https://www.dropbox.com/s/kv09arrefoyoyej/Gu%20et%20al.%20-%202015%20-%20Controllability%20of%20structural%20brain%20networks.pdf?dl=0)

[Supplementary material for Gu 2015](https://www.dropbox.com/s/7h0m9iicvrpm56q/Gu%202015%20Supp.pdf?dl=0)

