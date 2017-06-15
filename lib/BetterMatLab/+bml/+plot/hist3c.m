function varargout = hist3c(varargin)
% hist3c  draws hist3 as a imagesc plot.
%
% [n, c, h] = hist3c(X, hist3_opt, imagesc_opt, varargin)
%
% Options       Default values
% 'scale',      1
[varargout{1:nargout}] = hist3c(varargin{:});