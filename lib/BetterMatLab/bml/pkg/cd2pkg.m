function pkg = cd2pkg(varargin)
% Returns cd's package.
%
% pkg = cd2pkg(modifier='.*', goUp=0)
%
% See also package, dir2pkg, m2pkg, file2pkg

pkg = dir2pkg(cd, varargin{:});
end