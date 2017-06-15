function dst = empty2nanCell(src)
% EMPTY2NANCELL     Replaces empty cell with {nan}.
%
% dst = empty2nanCell(src)
%
% src: cell array.
% dst: cell array of same size.

dst = cell(size(src));

isE = cellfun(@isempty, src);

dst(isE)  = {nan};
dst(~isE) = src(~isE);