function S = ds_getS(ds, ix, fields)
% S = ds_getS(ds, ix, fields)

if nargin < 2, ix = ':'; end
ix = ix2py(ix, length(ds));

if nargin < 3 || isequal(fields, ':'), fields = ds.Properties.VarNames; end

S = struct;

for f = fields(:)'
    S.(f{1}) = ds.(f{1}){ix};
end