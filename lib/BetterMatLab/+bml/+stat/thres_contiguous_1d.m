function tf = thres_contiguous_1d(tf0, n_thres)
% tf = thres_contiguous_1d(tf0, n_thres)
%
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.
assert(islogical(tf0));
assert(isvector(tf0));
assert(isnumeric(n_thres));
assert(isscalar(n_thres));

tf = false(size(tf0));
st = nan;
n_contiguous = 0;
n = length(tf0);
tf0(n + 1) = false;
for ii = 1:(n + 1)
    if tf0(ii)
        if n_contiguous == 0
            st = ii;
        end
        n_contiguous = n_contiguous + 1;
    else
        if n_contiguous > 0
            if n_contiguous >= n_thres
                tf(st:(ii - 1)) = true;
            end
            n_contiguous = 0;
        end
    end
end
