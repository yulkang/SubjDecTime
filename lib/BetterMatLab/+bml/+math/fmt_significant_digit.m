function varargout = fmt_significant_digit(varargin)
% fmt = fmt_significant_digit(sc)
%
% EXAMPLE:
% >> fmt_significant_digit(10)
% ans =
% %1.0f
% 
% >> fmt_significant_digit(0.01)
% ans =
% %1.2f
[varargout{1:nargout}] = fmt_significant_digit(varargin{:});