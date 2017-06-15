function res = tabNew(fields, n, initVal)
if nargin < 3, initVal = nan; end

res = struct;

for cField = fields
    res.(cField{1}) = ones(n,1) * initVal;
end