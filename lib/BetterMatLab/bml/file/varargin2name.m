function nam = varargin2name(args, connecting_str)
% nam = varargin2name(args, connecting_str = '__')
%
% EXAMPLE:
% >> nam = varargin2name({'a', 1, 'b', 'abc', 'c', 1.1, 'd', false, 'f', ''})
% nam =
% a_1__b_abc__c_1.1__d_0__f
%
% See also: varargin2dir
%
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.

if ~exist('connecting_str', 'var'), connecting_str = '__'; end

C = varargin2C(args);
n = length(C) / 2;
ds = cell(1, n);
for ii = 1:n
    ds{ii} = str_con(C{ii * 2 - 1}, C{ii * 2});
end
nam = str_bridge(connecting_str, ds{:});
end