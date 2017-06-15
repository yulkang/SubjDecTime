function s = C2s(C, fields, to_excl)
% s = C2s(C, [fields, to_excl = false])

if nargin < 2, fields = {}; end
if nargin < 3, to_excl = false; end

s = S2s(varargin2S(C), fields, to_excl);
end