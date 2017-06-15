function varargout = binned_mean(varargin)
% [y, e, x_unique] = binned_mean(x, resp)
%
% Mean and standard error among non-NaN y, binned by x.
%
% Replaced by mean_binned.
%
% See also mean_binned.

[varargout{1:nargout}] = mean_binned(varargin{:});
end