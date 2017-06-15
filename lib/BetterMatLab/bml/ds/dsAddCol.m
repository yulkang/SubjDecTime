function ds = dsAddCol(ds, nameOrig, v)
% DSADDCOL Add column to dataset. Values defaults to nan if not provided.
%
% DS = dsAddCol(DS, NAME, [V = nan])
%
% NAME can be either char or cell.
% 
% If V is a scalar or a row vector, stretches to fill the column(s).
%
% See also JOIN.

if ~iscell(nameOrig), name = {nameOrig}; else name = nameOrig; end

if ~exist('v', 'var')
    v = nan(length(ds), length(name));

elseif size(v,1) == 1 && length(ds) > 1
    v = repmat(v, [length(ds), length(name) / size(v,2)]);
end

ds = horzcat(ds, dataset([{v}, name]));
