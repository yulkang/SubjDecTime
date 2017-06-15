function varargout = isequal_mat_nan(varargin)
% Returns a matrix like ==, but treating NaNs to be equal.
%
% c = isequal_mat_nan(a, b)
%
% c = (a == b) | (isnan(a) & isnan(b));
[varargout{1:nargout}] = isequal_mat_nan(varargin{:});