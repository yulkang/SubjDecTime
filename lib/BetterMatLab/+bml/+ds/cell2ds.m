function varargout = cell2ds(varargin)
% function ds = cell2ds(C, get_colname=true, get_rowname=false)
%
% Give get_rowname == 2 to have a column of the rowname.
[varargout{1:nargout}] = cell2ds(varargin{:});