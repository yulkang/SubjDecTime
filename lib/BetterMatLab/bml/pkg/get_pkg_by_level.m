function pkg = get_pkg_by_level(cl, level, from)
    % pkg = get_pkg_by_level(cl, level, from=['none']|'first'|'last')
    if nargin < 2, level = ':'; end
    if nargin < 3, from = 'none'; end
    assert(isscalar(level));
    pkgs = strsep_cell(cl, '.');
    n = length(pkgs);
    
    assert(level > -n, ...
        'Maximally negative (backward) level is %d, received %d\n', ...
            -n+1, level);
    assert(level <= n, ...
        'Maximum level (forward) is %d, received %d\n', ...
            n, level);
    level = ix2py(level, n);
    
    switch from
        case 'first'
            level = 1:level;
        case 'last'
            level = level:n;
        case 'none'
            % Leave as is
        otherwise
            error('Unknown input!');
    end
    
    pkgs = pkgs(level);
    pkg = str_bridge('.', pkgs);
end
