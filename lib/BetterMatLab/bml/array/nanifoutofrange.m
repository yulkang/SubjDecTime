function v = nanifoutofrange(vec, ix)
% Return NaN if out of range
%
% v = nanifoutofrange(vec, ix)
%
% EXAMPLE:
% >> nanifoutofrange(1:3, 1:5)
% ans =
%      1     2     3   NaN   NaN

try
    v = vec(ix);
catch
    l  = length(vec);
    wi = ix <= l;
    
    v(wi)  = vec(ix(wi));
    v(~wi) = nan;
end