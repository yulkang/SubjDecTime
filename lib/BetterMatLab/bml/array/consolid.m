function varargout = consolid(varargin)
% Wrapper for consolidate, with ycon as the first output.

[varargout{2},varargout{1},varargout{3:nargout}] = consolidate(varargin{:});