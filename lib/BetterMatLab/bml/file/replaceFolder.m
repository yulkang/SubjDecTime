function [res lastFolder] = replaceFolder(src, withFol)
% REPLACEFOLDER Replaces the last folder in a path with the specified one.
%
% res = replaceFolder(src, withFol)
%
% EXAMPLE
% >> replaceFolder('ab/cdef/g.h', 'i')
% ans = 'ab/i/g.h'
%
% >> replaceFolder('ab/cdef', 'i')
% ans = 'ab/i'
%
% >> replaceFolder('ab/cdef/g.h', '')
% ans = 'ab/g.h'
%
% >> replaceFolder('ab/cdef', '')
% ans = 'ab'
%
% See also STRCMPLAST

if any(src=='.')
    [pth nam ext] = fileparts(src);
else
    pth = src;
    nam = '';
    ext = '';
end

lastSep = find(pth == filesep, 1, 'last');
if ~isempty(lastSep)
    if isempty(withFol) && isempty(nam) && isempty(ext)
        res = pth(1:(lastSep-1));
    else
        res = fullfile(pth(1:lastSep), withFol, [nam ext]);
    end
    lastFolder = pth((lastSep+1):end);
else
    lastFolder = pth;
    res = fullfile(withFol, [nam ext]);
end