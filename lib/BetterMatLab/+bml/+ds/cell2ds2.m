function varargout = cell2ds2(varargin)
% Similar to cell2ds but accepts name-pair arguments.
%
% function ds = cell2ds2(C, ...)
%
% OPTIONS
% -------
% 'get_colname', true
% 'get_rowname', false
% 'matcols', {}
%
% Give get_rowname == 2 to have a column of the rowname.
[varargout{1:nargout}] = cell2ds2(varargin{:});