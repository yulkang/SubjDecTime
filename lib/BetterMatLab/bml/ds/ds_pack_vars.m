function ds = ds_pack_vars(ds, ix, varargin)
% DS_PACK_VARS  Set dataset values using workspace variable name & values.
%
% ds = ds_pack_vars(ds, ix, varargin)
%
% See also ds_set

n = length(varargin);

inputnames = cell(1, n);

for ii = 1:n
    inputnames{ii} = inputname(2 + ii);
end

C = [inputnames; varargin];
    
ds = ds_set(ds, ix, C{:});