%The script calculate the entropy point estimation from 1D histogram.
%input - empiric data
%E - entropy point estimation
function E = EntropyEstimationHist(input)   
[h x] = hist(input,min([max([0.1*length(input),10]),50]));

zero = find(h == 0);
for k = 1:length(zero)
    h(zero(k)) = 1;
end

h = h/sum(h);
step = x(2)-x(1);
E = log(step)-sum(h.*log(h));
end 