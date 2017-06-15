function [m, e, x_unique, d] = mean_binned(x, y, nan_below)
% [m, e, x_unique, d] = mean_binned(x, y, [nan_below=1])
%
% Mean and standard error among non-NaN y, binned by x.
% When the number of data in a bin is smaller than nan_below,
% the corresponding m, e, and d are NaN.
%
% m: mean; e: standard error of mean; d: standard deviation

if ~exist('nan_below', 'var'), nan_below = 1; end

valid_y  = ~isnan(y);

x_unique = unique(x);

n        = length(x_unique);
m        = zeros(1,n);
e        = zeros(1,n);

if nargout >= 4
    d    = zeros(1,n); % stdev
end

for ii = 1:length(x_unique)
    c_x = x_unique(ii);
    
    filt = (x == c_x) & valid_y;
    
    if nnz(filt) < nan_below
        m(ii) = nan;
        e(ii) = nan;
        d(ii) = nan;
    else
        m(ii) = mean(y(filt));
        e(ii) = sem( y(filt));

        if nargout >= 4
            d(ii) = std(y(filt));
        end
    end
end
end