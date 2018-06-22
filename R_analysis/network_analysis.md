Network Analysis for the mecp2 project
================

# Loading some pre-requisites

## Packages

``` r
library(igraph) # main packge for network analysis
```

    ## 
    ## Attaching package: 'igraph'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     decompose, spectrum

    ## The following object is masked from 'package:base':
    ## 
    ##     union

``` r
library(brainGraph) # some additional functions for network analysis
library(qgraph) # even more functions for network analysis
library(ggplot2) # for good-looking plots 
library(R.matlab) # to read matlab files
```

    ## R.matlab v3.6.1 (2016-10-19) successfully loaded. See ?R.matlab for help.

    ## 
    ## Attaching package: 'R.matlab'

    ## The following objects are masked from 'package:base':
    ## 
    ##     getOption, isOpen

## Aesthetics

``` r
library(ggrepel) # for labelling outliers
library(ggthemes)
library(ggpubr)
```

    ## Loading required package: magrittr

``` r
library(ggsci)

th <- theme_tufte() + theme(legend.position="bottom") 
colors <- scale_color_npg()
```

## Read files

``` r
network <- readMat('/media/timothysit/Seagate Expansion Drive1/The_Organoid_Project/data/organoid_20180503_light/mat_files/organoid_20180503_slice1_record_2_adj.mat')

# convert from a list to a matrix 
network <- matrix(unlist(network), ncol = 60, byrow = TRUE)

# Convert adjacency matrix to network object 
network <- graph_from_adjacency_matrix(network, mode = "undirected", weighted = TRUE)
```

## Initial sanity check of some network values and very rough visualisation

``` r
# Edge atributes
# edge_attr(network)
print("Edge weight summary:")
```

    ## [1] "Edge weight summary:"

``` r
summary(E(network)$weight)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
    ## -0.0175  0.5714  0.6666  0.6368  0.7500  1.0000     702

``` r
# Vertex atttributes
```

``` r
plot(network)
```

![](mecp2_network_analysis_files/figure-gfm/unnamed-chunk-5-1.png)<!-- -->

Do some pre-processing and plot again:

  - remove self-loops
  - convert NA values to zeros
  - remove numbers
  - make grid layout

<!-- end list -->

``` r
# convert NA values ot zero 
E(network)$weight[is.na(E(network)$weight)] <- 0 

# remove self loops 
network <- simplify(network, remove.loops = TRUE)
```

Make grid layout (for MEA data specifically)

``` r
yTemp = 1:8; 
# yCoord = repmat(fliplr(yTemp), 1, 8); # matlab code to be translated
yCoord = rep(rev(yTemp), 8);

xTemp = 1:8;
xCoord = rep(xTemp, each = 8);

coord = matrix(c(xCoord, yCoord), nrow = 64, ncol = 2)

# remove the 4 corners 
coord <- coord[!((coord[, 1] == 1) & (coord[, 2] == 1)), ]
coord <- coord[!((coord[, 1] == 1) & (coord[, 2] == 8)), ]
coord <- coord[!((coord[, 1] == 8) & (coord[, 2] == 1)), ]
coord <- coord[!((coord[, 1] == 8) & (coord[, 2] == 8)), ]
```

Make polished plot

``` r
# Set node size according to node strength 
V(network)$size = 1 + strength(network) * 0.5

# Set node size according to node degree
# V(network.pruned)$size = 1 + igraph::degree(network.pruned) # it may be masked by the sna package

# remove vertex labels
V(network)$label <- NA

# Chane border colour 
V(network)$frame.color = "white" # white, black, or grey (or NA)

plot(network, layout = coord)
```

![](mecp2_network_analysis_files/figure-gfm/unnamed-chunk-8-1.png)<!-- -->

# Single network analysis

## Thresholding to make binary network

``` r
threshold <- 0.7
network.binary  <- network
network.binary <- delete_edges(network.binary, E(network.binary)[weight < threshold])
E(network.binary)$weight[E(network.binary)$weight >= threshold] <- 1 
```

Plot the binary
graph

``` r
plot(network.binary, layout = coord, size = 0.1 + strength(network) * 0.75)
```

![](mecp2_network_analysis_files/figure-gfm/unnamed-chunk-10-1.png)<!-- -->

## Thersholding to make pruned weighted network

## Degree distribution

For non-visualising-related analysis, it is necessary to remove nodes
without any
edges.

``` r
# get information about the number of degrees and put that in our binary network object 
V(network.binary)$degree <- degree(network.binary)

# remove vertices without edges in the binary network 
network.binary <- delete_vertices(network.binary, V(network.binary)[degree == 0])
```

We can have a look at the network again, but no longer using the grid
layout

``` r
plot(network.binary, vertex.size = 7.5) # note that default vertex size is 15
```

![](mecp2_network_analysis_files/figure-gfm/unnamed-chunk-12-1.png)<!-- -->

Look at degree distsribution of binary network

``` r
df_network.binary <- data.frame("degree" = V(network.binary)$degree ) 
ggplot(df_network.binary, aes(x = degree)) + geom_histogram() + th
```

    ## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.

![](mecp2_network_analysis_files/figure-gfm/unnamed-chunk-13-1.png)<!-- -->

## Weight distribution

## Network density

``` r
network.binary$density <- edge_density(network.binary, loops = FALSE)
```

## Functional segregation

### Clustering coefficient

Note that the function for calculating clustering coefficient is called
`transitivity` in `igraph`, and there are different options within this
function that either gives you the local clustering coefficient (which
you can then average for the whole graph) or the global transitivity
metric.

[See
here](https://stackoverflow.com/questions/48853610/average-clustering-coefficient-of-a-network-igraph)

  - the “average” method (clustering coefficient) places more weight on
    low-degree nodes
  - the transitivity method places more weight on high-degree
nodes

<!-- end list -->

``` r
network.binary$ave_cluster_coeff <- transitivity(network.binary, type = "average", weights = NULL)
```

### Transitivity

``` r
network.binary$transitivity <- transitivity(network.binary, type = "undirected", weights = NULL)
```

### Modularity

``` r
# network.binary$modularity <- modularity(network.binary, membership = ???, weights = NULL)
```

## Functional integration

### Characteristic path length and global efficiency

``` r
network.binary$charPathLen <- average.path.length(network.binary, directed = FALSE)
network.binary$globalEff <- efficiency(network.binary, type = "global", weights = NULL)
```

## Small-worldness

``` r
# requires qgraph 
network.binary$smallwordness <- smallworldness(network.binary, B = 1000, up = 0.995, lo = 0.005)[1]
```

## Hubs and authorities

``` r
hs <- hub_score(network.binary, weights=NA)$vector

as <- authority_score(network.binary, weights=NA)$vector

par(mfrow=c(1,2))

 plot(network.binary, vertex.size=hs*30, main="Hubs")

 plot(network.binary, vertex.size=as*30, main="Authorities")
```

![](mecp2_network_analysis_files/figure-gfm/unnamed-chunk-20-1.png)<!-- -->

### Rich-club coefficient

``` r
network.binary$rich <- rich_club_coeff(network.binary, k = 1, weighted = FALSE) #uses brainGraph 
```

## Community Detection

``` r
ceb <- cluster_edge_betweenness(network.binary) 
```

    ## Warning in cluster_edge_betweenness(network.binary): At community.c:
    ## 460 :Membership vector will be selected based on the lowest modularity
    ## score.

    ## Warning in cluster_edge_betweenness(network.binary): At community.c:
    ## 467 :Modularity calculation with weighted edge betweenness community
    ## detection might not make sense -- modularity treats edge weights as
    ## similarities while edge betwenness treats them as distances

``` r
dendPlot(ceb, mode="hclust")
```

![](mecp2_network_analysis_files/figure-gfm/unnamed-chunk-22-1.png)<!-- -->

``` r
plot(ceb, network.binary) 
```

![](mecp2_network_analysis_files/figure-gfm/unnamed-chunk-22-2.png)<!-- -->

### Clique detection

Cliques are fully connected sub-graphs within a graph

  - my interpretatoin from a functional perspective is that they may
    have very similar or essentially almost the same roles

<!-- end list -->

``` r
vcol <- rep("grey80", vcount(network.binary))

vcol[unlist(largest_cliques(network.binary))] <- "gold"

plot(as.undirected(network.binary), vertex.label= NA, vertex.color=vcol)
```

![](mecp2_network_analysis_files/figure-gfm/unnamed-chunk-23-1.png)<!-- -->

## Centrality

### Closeness centrality

### Betwenness centrality

### Participation coefficient

## Modularty

# Summary of single network characteristics

## Radar-plot visualisations

``` r
library(fmsb)
# for this to work, the first row of the data fram is the ymax, the second row is the ymin 
# and the third row is the final value
network_density <- c(1, 0, network.binary$density)
transitivity <- c(1, 0, network.binary$transitivity) 
global_efficiency <- c(1, 0, network.binary$globalEff)
rich_club_coefficient <- c(1, 0, network.binary$rich$phi)
small_worldness <- c(3, 0, network.binary$smallwordness)

df_network.binary <- data.frame(network_density, transitivity, global_efficiency, rich_club_coefficient, small_worldness)


 
# The default radar chart proposed by the library:
radarchart(df_network.binary)
```

![](mecp2_network_analysis_files/figure-gfm/unnamed-chunk-25-1.png)<!-- -->

``` r
# Custom the radarChart !
radarchart( df_network.binary  , axistype=1 ,
 
    #custom polygon
    pcol=rgb(0.2,0.5,0.5,0.9) , pfcol=rgb(0.2,0.5,0.5,0.5) , plwd=4 ,
 
    #custom the grid
    cglcol="grey", cglty=1, axislabcol="grey", caxislabels=seq(0,1,5), cglwd=0.8,
 
    #custom labels
    vlcex=0.8
    )
```

![](mecp2_network_analysis_files/figure-gfm/unnamed-chunk-25-2.png)<!-- -->

# Batch Analysis

The main idea is this:

  - go to directory containing the .mat files with the adjacnecy
    matrices
  - put them in R and convert them to igraph objects
  - do thresholding / convert them to a binary graph
  - calculate the network metrics and append them to a data frame
  - also extract genotype and DIV data and put them to the data frame
  - ideally also include the culture batch, and the ID

# Comparison of network statistics
