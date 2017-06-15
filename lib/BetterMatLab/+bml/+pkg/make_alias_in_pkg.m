function file = make_alias_in_pkg(file0, pkg, varargin)
% file = make_alias_in_pkg(file0, pkg, varargin)
%
% See also bml.pkg.pkg2alias

% 2016 (c) Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'root', 'lib/BetterMatLab' % pwd
    'overwrite_existing', false
    'copyright_line', ''
    'copyright_name', ''
    'verbose', 1
    });

if nargin < 2
    pkg = '';
end
if iscell(file0) || iscell(pkg)
    if ~iscell(file0)
        file0 = {file0};
    end
    if ~iscell(pkg)
        pkg = {pkg};
    end
    
    [file0, pkg] = rep2match(file0, pkg);
    
    file = cellfun(@(f,p) make_alias_in_pkg(f, p, varargin{:}), ...
        file0, pkg, 'UniformOutput', false);
    return;
end

% Get file0_full and make sure it exists as an .m file.
if isa(file0, 'function_handle')
    file0 = func2str(file0);
end
assert(ischar(file0));
file0_full = which(file0);
if isempty(file0_full) ...
        && exist(file0, 'file') ...
        && exist(fileparts(file0), 'dir')
    file0_full = file0;
end
if isempty(file0_full)
    warning('%s not found!\n', file0);
    file = '';
    return;
end
[pth, nam, ext] = fileparts(file0_full);
if isempty(ext)
    ext = '.m';
    file0_full = fullfile(pth, [nam, ext]);
    assert(exist(file0_full, 'file') ~= 0, ...
        '%s does not exist!', file0_full);
else
    assert(strcmp(ext, '.m'), 'Give an .m file only!');
end

% Test if it is a class file
cl = file2class(file0);
is_class = exist(cl, 'class') == 8;
if ~is_class
    fid = fopen(file0_full, 'r');
    str = textscan(fid, '%s');
    is_class = ~isempty(str) && ~isempty(str{1}) && ...
        ~isempty(regexp(str{1}{1}, ...
            '^[\s]*classdef[\s]*', 'once'));
    fclose(fid);
end

% Make the pkg inside the root folder, if absent.
assert(ischar(pkg));
if isempty(pkg)
    pkg = input(sprintf('Enter package in which to put an alias for %s: ', ...
        file0_full), 's');
end
pkg_dir = pkg2dir(pkg);
mkdir2(pkg_dir);

% Check if the target file exists already. If so, skip.
file = fullfile(pkg_dir, [nam, ext]);
if exist(file, 'file') && ~S.overwrite_existing
    warning('Target file %s already exists! Skipping..\n', file);
    return;
end

% Write an alias file
fid = fopen(file, 'w');
if is_class
    fprintf(fid, 'classdef %s < %s\n', nam, nam);
else
    fprintf(fid, 'function varargout = %s(varargin)\n', nam);
end

% Copy the help section.
[pth0,name0] = fileparts(file0);
if ~exist(name0, 'file')
    addpath(pth0);
    warning('Added %s to path\n', pth0);
%     error('%s is not on path! help section will not be copied!');
end
c = strsplit(help(name0), sprintf('\n'));
% help() inserts a blank line at the end. Cancel it.
if isempty(c{end}), c = c(1:(end-1)); end 
for ii = 1:numel(c)
    % help() inserts a space at the beginning of each line. Cancel it.
    if strcmp(c{ii}(1), ' '), c{ii} = c{ii}(2:end); end
    fprintf(fid, '%%%s\n', c{ii});
end

% Copyright line is often separate from the help section.
% Insert it separated by a blank line, if given.
if ~isempty(S.copyright_name) && isempty(S.copyright_line)
    d = datevec(now);
    S.copyright_line = sprintf(' %d (c) %s', d(1), S.copyright_name);
end
if ~isempty(S.copyright_line)
    fprintf(fid, '\n%%%s\n\n', S.copyright_line);
end
if is_class
    fprintf(fid, 'end');
else
    fprintf(fid, '[varargout{1:nargout}] = %s(varargin{:});', nam);
end
fclose(fid);

% Print results.
if S.verbose >= 1
    fprintf('Made an alias of\n  %s\nat\n  %s\n\n', file0_full, file);
end
end