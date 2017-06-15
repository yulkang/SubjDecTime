function varargout = is_integer(varargin)
% Checks if v == round(v) (Can be true for double/single variables).
%
% 2015 Yul Kang.
[varargout{1:nargout}] = is_integer(varargin{:});