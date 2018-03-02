# grid layout graph 

# This is an example of a grid-layout connectivity graph 
# The adjacency marix - adjM - is generated from a probability distribution 

library(qgraph)
library(pracma)

# specify coordinates to plot 
Xcord = rep(1:8, each = 8)
Ycord = rep(1:8, 8)

gridLayout = cbind(Xcord, Ycord)

# remove any points in the grid you want to exclude 
newGrid = gridLayout[c(-1, -8, -57, -64), ]

# specify the adjacency matrix
adjM = matrix(rexp(64, rate=.1), ncol=60, nrow = 60)

qgraph(adjM, diag = FALSE, layout = newGrid, theme = "colorblind", minimum = 1.5)
