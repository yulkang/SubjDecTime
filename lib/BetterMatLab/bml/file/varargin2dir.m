function d = varargin2dir(args)
% d = varargin2dir(args)
%
% EXAMPLE:
% >> d = varargin2dir({'a', 1, 'b', 'abc', 'c', 1.1, 'd', false, 'f', ''})
% d =
% a_1/b_abc/c_1.1/d_0/f
%
% See also: varargin2name
%
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.

C = varargin2C(args);
n = length(C) / 2;
ds = cell(1, n);
for ii = 1:n
    ds{ii} = str_con(C{ii * 2 - 1}, C{ii * 2});
end
if isempty(ds)
    d = '';
else
    d = fullfile(ds{:});
end
end