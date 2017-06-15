function [p, n, e] = baseCallerParts(f, varargin)
% Same as fileparts but returns name with package qualifiers.

if strcmp(f, 'base')
    p = '';
    n = 'base';
    e = '';
else
    [p, ~, e] = fileparts(f);
    n = file2pkg(f, varargin{:});
end