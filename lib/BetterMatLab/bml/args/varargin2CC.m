function C = varargin2CC(C, def, nested, restrict_input)
% Nested defaults.
%
% >> C = varargin2CC({'a', 1, 'b', {'A', 1}}, {'a', 100, 'b', {'A', 10, 'B', 20}, 'c', 300}, {'b'})
% C = 
%     'a'    [1]    'b'    {1x4 cell}    'c'    [300]
% 
% >> C{4}
% ans = 
%     'A'    [1]    'B'    [20]
%
% See also varargin2SS.

if nargin < 4, restrict_input = false; end

S = varargin2S(C, def, restrict_input);
if iscell(def), def = varargin2S({}, def); end

for cc = nested
    S.(cc{1}) = varargin2C(S.(cc{1}), def.(cc{1}));
end

C = S2C(S);
end