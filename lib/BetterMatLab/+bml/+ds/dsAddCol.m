function varargout = dsAddCol(varargin)
% DSADDCOL Add column to dataset. Values defaults to nan if not provided.
%
% DS = dsAddCol(DS, NAME, [V = nan])
%
% NAME can be either char or cell.
% 
% If V is a scalar or a row vector, stretches to fill the column(s).
%
% See also JOIN.
[varargout{1:nargout}] = dsAddCol(varargin{:});