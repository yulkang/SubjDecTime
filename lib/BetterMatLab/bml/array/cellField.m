function res = cellField(c, fieldName, uniformOutput)
% res = cellField(c, fieldName, uniformOutput)

if ~exist('uniformOutput', 'var'), uniformOutput = true; end

res = cellfun(@(a) a.(fieldName), c, 'UniformOutput', uniformOutput);