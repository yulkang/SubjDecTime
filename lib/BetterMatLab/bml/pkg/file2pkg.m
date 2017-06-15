function pkg = file2pkg(f, goUp)
% Returns a function/script name with package modifiers given a file name.
%
% pkg = dir2pkg(d, goUp=0)
%
% See also m2pkg, cd2pkg, dir2pkg, package, PsyLib
%
% 2013 (c) Yul Kang. See help PsyLib for the license.

if nargin<2, goUp = 0; end

if iscell(f)
    pkg = cellfun(@(s) file2pkg(s, goUp), f, 'UniformOutput', false);
    return;
end

[pth nam] = fileparts(f);
pkg = dir2pkg(pth, '', goUp);
pkg = funPrintfBridge('.', pkg, nam);
end