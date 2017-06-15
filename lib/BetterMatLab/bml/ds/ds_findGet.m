function [row, filt] = ds_findGet(ds, findS)
% [row, filt] = ds_findGet(ds, findS)
%
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.

n = length(ds);
filt = true(n,1);

findS = varargin2S(findS);
fs = fieldnames(findS);
nf = length(fs);
for ii = 1:nf
    f = fs{ii};
    
    assert(~(iscell(ds.(f)) && (size(ds.(f),2) > 1)));
    
    vs = row2cell(ds.(f), true);
    vs0 = row2cell(findS.(f), true);
    
    if size(vs0, 1) == 1
        filt = filt & arrayfun(@(v) isequal(vs0, v), ds.(f));
    else
        filt = filt & cellfun(@isequal, vs0, vs);
    end
end

if ~any(filt)
    row = ds([],:);
else
    row = ds(filt, :);
end