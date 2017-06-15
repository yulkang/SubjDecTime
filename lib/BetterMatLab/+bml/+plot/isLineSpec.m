function varargout = isLineSpec(varargin)
% ISLINESPEC    Sees if a string is linespec, and converts it to properties.
%
% [tf, propCell] = isLineSpec(str)
%
% set(gca, propCell{:}) will do similar things as plot(..., str).
% Useful for functions that doesn't support the latter syntax, like cdfplot.
%
% Example:
% [tf, propCell] = isLineSpec('r-')
%
% tf        = 1
% propCell  = {'Color', 'r', 'LineStyle', '-'}
%
% See also: CDFPLOTSPEC
[varargout{1:nargout}] = isLineSpec(varargin{:});