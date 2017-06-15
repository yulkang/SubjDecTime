function obj = create_nearest_existing(cl, varargin)
% create_nearest_existing(cl, root_pkg, create_args)
%
% Starting from root...st_pkg, root...Common, up to root_pkg.Common, create cl if exists.

error('Not implemented yet!');

S = varargin2S(varargin, {
    'root_pkg', get_pkg_by_level(cl, 1)
    });

if nargin < 2, root_pkg = strsep(cl, '.', 1); end
if nargin < 3, create_args = {}; end



c_cl = cl;
while length(c_cl == '.') >= 1
    if exist(c_cl, 'class')
        obj = feval(c_cl, create_args{:});
        return;
    end
    
    cl_name = get_pkg_by_level(c_cl, 0);
    pkg_above = get_pkg_by_level(c_cl, -2, 'first');
end
