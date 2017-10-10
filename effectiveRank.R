library(entropy)
# based on the paper: 
# https://infoscience.epfl.ch/record/110188/files/RoyV07.pdf


# singular value decomposition tutorial: 
# https://www.r-bloggers.com/singular-value-decomposition-svd-tutorial-using-examples-in-r/


# currently don't know how to generate covM, let's do that with correlation matrix in the mean time: 

# covM <- t3 # note, currently this is correlation 
eigenV <- eigen(covSM)$values 
normEigenV <- eigenV / sum(eigenV) # "normalise" so they sum to 1 
# we do this to interpret the N eigenvalues as a distribution of N integers
plot(normEigenV)

# now we compute Shannon entropy of the vector 

# sEn <- entropy.plugin(normEigenV) # seems to give different results for some reason
sEn <- -sum(normEigenV * log2(normEigenV))

print(sEn)

# Todo: compute this myself to check

# finally, exp on that
effectiveRank = exp(sEn)
print(effectiveRank)
