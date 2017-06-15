function res = DIR_(kind, varargin)
% Shorthand for GET_DIR
%
% res = DIR_(kind, [subdir1, ...])
% res = DIR_(':kind/subdir1...')
%
% See also: GET_DIR

if nargin < 1, kind = ''; end
if nargin < 2, varargin = {}; end

if ~isempty(kind) && kind(1) == ':'
    pth  = kind;
    ix   = find(kind == '/', 1, 'first');
    kind = pth(2:(ix - 1));
    varargin = [{pth((ix+1):end)}, varargin];
end
    
res = GET_DIR(kind, [], varargin);
end