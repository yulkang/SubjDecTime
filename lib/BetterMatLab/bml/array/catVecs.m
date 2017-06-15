function m = catVecs(c, fillWith)
% mat = catVecs(cellVec, fillWith = nan)
%
% Concatenate cell array of vectors of different lengths

if ~exist('fillWith', 'var'), fillWith = nan; end

maxLen = max(cellfun(@length, c));
n      = length(c);

m      = zeros(n,maxLen) + fillWith;

for ii = 1:n
    m(ii,1:length(c{ii})) = c{ii};
end