function y = random_walk(N, X, start_loc)
%{
Performs a random walk with N discrete steps in X dimensions.
Code from: https://uk.mathworks.com/matlabcentral/answers/395312-how-to-create-a-random-walk-in-1d-array
%}

% positions, starting at (0,0,...,0)
y = cumsum(full(sparse(1:N, randi(X,1,N), [start_loc 2*randi([0 1],1,N-1)-1], N, X))) ; 


end 