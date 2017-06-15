function [my, ey, mx, ex] = running_mean_constN(x_orig, y_orig, n_min, varargin)
% running mean with constant n
%
% [my, ey, mx, ex] = running_mean_constN(x_orig, y, n_min, varargin)
%
% INPUT:
% x_orig : A vector of sampling position.
% y      : A vector of data sampled at x_orig.
% n_min  : Number of data points to average. Give an odd number to be exact.
%
% OPTIONS:
% 'xbin', [] % If a nonempty vector, results are sampled at these x locations.
% 'interpOpt', {'linear', 'none'} % How to interpolate. Fed to griddedInterpolant.
%
% OUTPUT:
% mx, my : Running mean.
% ex, ey : Running standard error of the mean.
%
% EXAMPLE:
% >> [my, ey, mx, ex] = running_mean_constN(1:5, fliplr(1:5), 3)
% my =
%      4     3     2
% ey =
%     0.4714    0.4714    0.4714
% mx =
%      2     3     4
% ex =
%     0.4714    0.4714    0.4714
%
% See also: runningMean, running_mean_reg, hist, griddedInterpolant

S = varargin2S(varargin, {
    'xbin', []
    'interpOpt', {'linear', 'none'}
    });

% Filter out NaN
incl = ~isnan(x_orig) & ~isnan(y_orig);
x_orig = x_orig(incl);
y_orig = y_orig(incl);

% Sort
[x,ix] = sort(x_orig);
y = y_orig(ix);

n = length(x);

[mx, ex, nx] = running_mean_reg(x, round((n_min-1)/2) + zeros(1,2), ones(1,n));
[my, ey, ny] = running_mean_reg(y, round((n_min-1)/2) + zeros(1,2), ones(1,n));

mx = mx(nx >= n_min);
my = my(ny >= n_min);
ex = ex(nx >= n_min);
ey = ey(ny >= n_min);

% Interpolate x
if ~isempty(S.xbin)
    F  = griddedInterpolant(mx, my, S.interpOpt{:});
    my = F(S.xbin);
    
    F  = griddedInterpolant(mx, ex, S.interpOpt{:});
    ex = F(S.xbin);
    
    F  = griddedInterpolant(mx, ey, S.interpOpt{:});
    ey = F(S.xbin);
    
    F  = griddedInterpolant(mx, mx, S.interpOpt{:});
    mx = F(S.xbin);
end