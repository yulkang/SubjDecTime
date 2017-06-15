function varargout = isdscolumn(varargin)
% True if COL is a column of DS. 
% COL can be either a string or a cell array of strings.
%
% tf = isdscolumn(ds, col)
[varargout{1:nargout}] = isdscolumn(varargin{:});