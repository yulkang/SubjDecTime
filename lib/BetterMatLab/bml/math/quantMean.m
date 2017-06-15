function res = quantMean(src, nQuant)
% res = quantMean(src, nQuant)
%
% Replaces the values in SRC with the mean of each quantile.

q   = quantilize(src, nQuant);
m   = zeros(nQuant,1);
res = zeros(size(src));

for ii = 1:nQuant
    m(ii) = mean(src(q==ii));
    
    res(q==ii) = m(ii);
end