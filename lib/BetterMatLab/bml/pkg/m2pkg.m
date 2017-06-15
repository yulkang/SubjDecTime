function pkg = m2pkg(varargin)
% Returns caller function's package.
%
% pkg = m2pkg(modifier='.*', goUp=0)
%
% See also package, dir2pkg, cd2pkg, file2pkg

st = dbstack('-completenames');
if length(st)==1
    warning(['Called from base or from cell mode.\n' ...
             'Returning current directory''s package.\n' ...
             '(may differ from caller''s package).%s\n'], ' ');
    pkg = dir2pkg(cd, varargin{:});
else
    pkg = dir2pkg(fileparts(st(2).file), varargin{:});
end