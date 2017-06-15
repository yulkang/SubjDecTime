function [m, e, n_averaged, x_binned] = running_mean_binned(x_orig, y, w, bins, varargin)
% running mean after binning.
%
% [m, e, n_averaged, x_binned] = running_mean_binned(x_orig, y, w, bins)
%
% INPUT:
% x_orig : A vector of sampling position.
% y      : A vector of data sampled at x_orig.
% w      : A two-vector of [w_prev, w_next].
% w_prev : Number of data points preceding the current point to average.
% w_next : Number of data points following the current point to average.
% bins   : If a scalar, number of bins. 
%          If a vector, position of bin centers.
%
% OUTPUT:
% m      : Running mean.
% e      : Running standard error of the mean.
% n_averaged(k) : Number of samples considered in m(k)
% x_binned      : Position of the bin centers.
%
% EXAMPLE:
% >> running_mean_binned([1 2 6], [10 100 1000], [1 1], 1:6)
% ans =
%           55          55         100         NaN        1000        1000
%
% See also: runningMean, running_mean_reg, hist

S = varargin2S(varargin, {
    'thres_n', 1
    });

% Bin x_orig
[n_x, x_binned] = hist(x_orig, bins);

% Bin y_orig
ix = bsxClosest(x_orig, x_binned);

y_binned = zeros(size(x_binned));

for ii = 1:length(x_binned)
    c_x = x_binned(ii);
    tf  = ix == ii;
    
    if any(tf)
        y_binned(ii) = mean(y(tf));
    end
end
    
% Average with weight n_x
[m, e, n_averaged] = running_mean_reg(y_binned, w, n_x);

% Threshold n
if S.thres_n > 1
    incl = n_averaged >= S.thres_n;
    
    m(~incl) = nan;
    e(~incl) = nan;
end