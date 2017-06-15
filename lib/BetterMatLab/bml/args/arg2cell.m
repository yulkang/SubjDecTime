function [v, varargout] = arg2cell(v)
% ARG2CELL - Makes v a cell {v} if it is not already a cell.
%
% v = arg2cell(v)
% [v, cell1, cell2, ...] = arg2cell(v)
%
% cell1, 2, ... are cell(size(v))
%
% See also cell2arg, arg, PsyLib
%
% 2013 (c) Yul Kang. See help PsyLib for the license.

if ~iscell(v)
    v = {v};
end

if nargout > 1
    varargout = cell(1,(nargout-1));
    for ii = 1:length(varargout)
        varargout{ii} = cell(size(v));
    end
end