function [m, e, n_averaged] = running_mean_reg(y, w, n)
% RUNNING_MEAN_REG - Fast running mean on data with a fixed interval.
%
% [m, e, n_averaged] = running_mean_reg(y, w, n)
%
% INPUT:
% y      : A vector of data sampled at a fixed interval.
% w      : A two-vector of [w_prev, w_next].
% w_prev : Number of data points preceding the current point to average.
% w_next : Number of data points following the current point to average.
% n      : Number of data points in each bin.
%
% OUTPUT:
% m      : Running mean. m(k) = mean(y(max(1, k - w_prev):min(end, k + w_next)).
% e      : Running standard error of the mean.
% n_averaged(k) : Number of samples considered in m(k)
%
% See also runningMean.
%
% 2013 (c) Yul Kang, hk2699 at columbia dot edu.

% Inputs
if isempty(y)
    m = [];
    e = [];
    return;
end

if ~exist('n', 'var'), n = ones(1, numel(y)); end

% Remember size to recover later.
siz = size(y);
y = y(:)'; % enforce row vector. Size is recovered later.
w = w(:)';
n = n(:)';

L = length(y);

% Exclude invalid points
incl = ~isnan(y) & ~isnan(n);
n(~incl) = 0;
y(~incl) = 0;

% Use cumsum on shifted and weighted vectors.
c_y      = cumsum(y .* n);
c_y_prev = shift_pad(c_y,  w(1)+1, 0);
c_y_next = shift_pad(c_y, -w(2),   c_y(end));

% Use cumsum of n.
c_n      = cumsum(n);
c_n_prev = shift_pad(c_n,  w(1)+1, 0);
c_n_next = shift_pad(c_n, -w(2),   c_n(end));
n_averaged = c_n_next - c_n_prev;

% Calculate average using the differences of the cumsum.
m = (c_y_next - c_y_prev) ./ n_averaged;

if nargout >= 2
    expected_mean_sq = running_mean_reg(y.^2, w, n); % E[y.^2]
    e      = sqrt((expected_mean_sq - m.^2) ./ n_averaged); % E[y.^2] - E[y]^2
    e      = reshape(e, siz);
end

if nargout >= 3
    n_averaged = reshape(n_averaged, siz);
end

m = reshape(m, siz);
