function S = str2S(s, sep)
% Parse a name-value pair in string into a struct.
%
% S = str2S(s, [sep='__'])
%
% S = str2S('a__2__b__D')
% S = 
%     a: '2'
%     b: 'D'
%
% See also: varagin2S, strsep2C

C = strsep2C(s, sep);
S = varargin2S(C);