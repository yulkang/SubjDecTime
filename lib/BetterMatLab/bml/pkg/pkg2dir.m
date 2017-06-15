function pth = pkg2dir(pkg)
% pth = pkg2dir(pkg)

% 2015 (c) Yul Kang. hk2699 at columbia dot edu.

if isempty(pkg)
    pth = '';
else
    top_pkg = strsep(pkg, '.', 1);
    info_top = unique_general(what(top_pkg));
    
    if numel(info_top) > 1
        n = numel(info_top);
        is_pkg = false(1, n);
        for ii = 1:n
            c = strsplit(info_top(ii).path, filesep);
            is_pkg(ii) = ~isempty(c{end}) && strcmp(c{end}(1), '+');
        end
        if nnz(is_pkg) > 1
            error('pkg2dir:NOTUNIQUE', ...
                '''%s'' is not unique!\n', pkg);
        else
            info_top = info_top(is_pkg);
        end
    end
    if isempty(info_top)
        error('pkg2dir:NOTFOUND', ...
            ['''%s'' is not found in the MATLAB path ' ...
               'or in the current directory!\n'], ...
            pkg);
    end
    
    pth_rel = ['+', strrep(pkg, '.', [filesep, '+'])];
    
    pth = fullfile(fileparts(info_top.path), pth_rel);
end
