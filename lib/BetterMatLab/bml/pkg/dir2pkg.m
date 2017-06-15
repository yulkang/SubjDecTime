function pkg = dir2pkg(d, modifier, goUp)
% Returns a package name given dir.
%
% pkg = dir2pkg(d, modifier='.*', goUp=0)
%
% See also m2pkg, cd2pkg, file2pkg, package, PsyLib
%
% 2013 (c) Yul Kang. See help PsyLib for the license.

if nargin<2, modifier = '.*'; end
if nargin<3, goUp = 0; end

if isempty(d)
    pkg = '';
    return;
    
elseif d(end)~=filesep, 
    d = [d, filesep]; 
end

dirs = filepartsCell(d);

isPkg = cellfun(@(s) (s(1) == '+'), dirs);

ix_pkg = find(isPkg);
ix_pkg = ix_pkg(1:(end - goUp));

if isempty(ix_pkg)
    pkg = '';
else
    pkgDirs = dirs(isPkg);
    pkgDirs = cellfun(@(s) s(2:end), pkgDirs, 'UniformOutput', false);
    pkg = pkgDirs{1};

    if length(ix_pkg) > 1
        pkg = [pkg, sprintf('.%s', pkgDirs{2:end})];
    end

    pkg = [pkg, modifier];
end
