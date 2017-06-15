function wgm= wgeomean(x, w, dim)
% Calculates the geometric mean of a vector X (first argument) weighted by the values of
% another vector W (second argument)
%
% wgm = wgeomean(x, w, dim)

% 2015-10 Modified by Yul Kang

if nargin < 2
    w = ones(size(x));
end
assert(all(w(:) >= 0), 'Weights must be nonzero!');
if nargin < 3
    dimArg = {};
else
    dimArg = {dim};
end

wgm = exp(sum(w.*log(x), dimArg{:}) ./ sum(w, dimArg{:}));
return
