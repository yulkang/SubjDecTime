function n = numIx(ix)
% Counts entries in ix for both logical and numeric indices.
%
% n = numIx(ix)

if islogical(ix)
    n = nnz(ix);
else
    n = numel(ix);
end