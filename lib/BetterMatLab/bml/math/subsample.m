function res = subsample(v, fac, d)
% subsample  subsample V by FAC along DIM.
%
% res = subsample(v, fac, [dim=1])

if exist('d', 'var')
    perm = [d, setdiff(1:ndims(v), d)];
    
    v = permute(v, perm);
end

siz = size(v);
siz(1) = siz(1) / fac;

if floor(siz(1)) < siz(1)
    siz(1) = floor(siz(1));
    v = reshape(v(1:(siz(1)*fac),:), [fac, siz]);
else
    v = reshape(v, [fac, siz]);
end

res = reshape(mean_rows(v, 1), siz);

if exist('d', 'var')
    res = ipermute(res, perm);
end