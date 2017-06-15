function varargout = gampdf_deriv(varargin)
% [dp_dk, dp_dth] = gampdf_deriv(x, k, th)
%
% k: shape
% th: scale
%
% See also: gampdf_ms_deriv, gampdf
[varargout{1:nargout}] = gampdf_deriv(varargin{:});