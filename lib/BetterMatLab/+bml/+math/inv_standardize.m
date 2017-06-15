function src = inv_standardize(res, avg, stdev)
% src = inv_standardize(res, avg, stdev)
% 
% Inverse of standardize().

src = bsxfun(@plus, bsxfun(@times, res, stdev), avg);
