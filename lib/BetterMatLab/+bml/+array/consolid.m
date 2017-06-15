function varargout = consolid(varargin)
% Wrapper for consolidate, with ycon as the first output.
[varargout{1:nargout}] = consolid(varargin{:});