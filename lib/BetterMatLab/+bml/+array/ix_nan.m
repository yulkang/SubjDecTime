function dst = ix_nan(src, ix)
% dst = ix_nan(src, ix)
%
% dst = src(ix) where ix is not NaN
% dst = NaN where ix is NaN.

siz = size(ix);
dst = zeros(siz);

incl = ~isnan(ix);
dst(incl) = src(ix(incl));
dst(~incl) = nan;

dst = reshape(dst, siz);
end