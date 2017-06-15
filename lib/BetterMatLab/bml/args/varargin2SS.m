function S = varargin2SS(C, def, nested, restrict_input)
% Nested defaults.
%
% S = varargin2SS(C, def, nested, restrict_input=false)
%
% EXAMPLE:
% >> S = varargin2SS({'a', 1, 'b', {'A', 1}}, {'a', 100, 'b', {'A', 10, 'B', 20}, 'c', 300}, {'b'})
% S = 
%     a: 1
%     b: [1x1 struct]
%     c: 300
% 
% >> S.b
% ans = 
%     A: 1
%     B: 20
%
% See also varargin2CC.
%
% 2014 (c) Yul Kang.

if nargin < 4, restrict_input = false; end

S = varargin2S(C, def, restrict_input);
if iscell(def), def = varargin2S({}, def); end

for cc = nested
    S.(cc{1}) = varargin2S(S.(cc{1}), def.(cc{1}));
end
end