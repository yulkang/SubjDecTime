function s = nansestd(v)
% After Ahn & Fessler 2003
% at http://ai.eecs.umich.edu/~fessler/papers/files/tr/stderr.pdf

if isvector(v)
    n = nnz(~isnan(v));
    s = nanstd(v) / sqrt(2 * (n - 1));
else
    n = sum(~isnan(v),1);
    s = bsxfun(@rdivide, nanstd(v), sqrt(2 * (n - 1)));
end


