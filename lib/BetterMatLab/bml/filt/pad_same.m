function M = pad_same(M, n)
% M = pad_same(M, n)

if ~isempty(M)
    M = [repmat(M(:,1), [1, n]), M, repmat(M(:,end), [1, n])];
else
    M = [];
end