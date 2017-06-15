function res = tabMat(tab, ix, fields)
if nargin < 3, fields = fieldnames(tab)'; end

res = zeros(length(ix), length(fields));

for iField = 1:length(fields)
    res(:,iField) = tab.fields(iField);
end