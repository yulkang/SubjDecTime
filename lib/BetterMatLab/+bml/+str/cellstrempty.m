function varargout = cellstrempty(varargin)
% Make empty entries ([]) have char class ('').
%
% c = cellstrempty(c)
[varargout{1:nargout}] = cellstrempty(varargin{:});