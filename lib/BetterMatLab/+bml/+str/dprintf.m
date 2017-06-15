function varargout = dprintf(varargin)
% DPRINTF - Print to multiple fids. Includes 1 by default.
%
% Include 1 for standard output, and 2 for standard error.
%
% See also fprintf
[varargout{1:nargout}] = dprintf(varargin{:});