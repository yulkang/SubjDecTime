function res = tabRef(tab, ix, fields)
if nargin < 3, fields = fieldnames(tab)'; end

res = struct;

for cField = fields
    res.(cField{1}) = tab.(cField{1})(ix);
end