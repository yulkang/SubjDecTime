function [conflicts, moved, skipped] = pkg2alias(src, varargin)
% Move *.m files inside package into a regular folder, leaving aliases.
% Allows using both tab completion (benefit of package)
% and short names and balloon help of the input arguments (benefit of
% functions directly on path).
%
% [moved, skipped] = pkg2alias(src, varargin)
% moved: cell array of original .m files/class folders that are moved.
% skipped cell array of original .m files/class folders that are skipped.
%
% OPTIONS:
% 'root', 'lib/BetterMatLab'
% 
% % If true, ask if to use the original name, to rename, or to skip.
% % Even if false, confirms if the name conflicts with names on path.
% 'confirm', true
% 
% % Update the help text of the alias if the m-file already exists 
% % in the root folder.
% 'to_update_alias_of_existing', true
% 
% Note: not tested with class folders yet.
%
% See also: make_alias_in_pkg

% 2016 (c) Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'root', 'lib/BetterMatLab' % pwd % 

    % If true, ask if to use the original name, to rename, or to skip.
    % Even if false, confirms if the name conflicts with names on path.
    'confirm', false
    
    % Update the help text of the alias if the m-file already exists 
    % in the root folder.
    'update_alias', true
    
    'copyright_line', ''
    'copyright_name', ''
    
    % use_subfolder
    % : Move +pkg1/+pkg2/name.m to pkg1/pkg2/name.m and leave alias
    %   to allow both tab completion (through package)
    %   and easy navigation of the actual code (through subfolders)
    %   The downsides are that subfolders are duplicated
    %   and that the subfolders need to be added to the path.
    'use_subfolder', true
    
    'move_class', false
    'mfiles', []
    
    'verbose', 1
    });

%% Initialize output
moved = {};
skipped = {};
conflicts = {};

%% Find root.
[root, nam] = fileparts(GetFullPath(S.root));
S.root = fullfile(root, nam); % To remove filesep at the end.
pth_filesep = [S.root, filesep];

%% First move all class folders
if S.move_class
    classdirs = rdir(fullfile(S.root, '**/@*'), 'isdir==true', pth_filesep);

    n = numel(classdirs);
    for ii = 1:n
        classdir_rel = classdirs{ii};
        classdir_full = fullfile(S.root, classdir_rel);

        % If already directly under root, skip.
        if classdir_rel(1) == '@'
            continue;
        end

        % Get the class name
        c = strsplit(classdir_rel, filesep);
        ix_class = find(cellfun(@(v) v(1) == '@', c));
        if ~isscalar(ix_class)
            error('Multiple class designators @ in the path string!');
        end

        % If the class is not in a package, skip.
        ix_pkg = find(cellfun(@(v) v(1) == '+', c));
        if isempty(ix_pkg) || (ix_pkg(1) > ix_class)
            continue;
        end

        % Parse the class name
        name = c{ix_class}(2:end);

        % If the name already exists, confirm.
        kind = exist(name); %#ok<EXIST>
        kind_str = {'variable', 'file', 'mex', 'simulink', ...
                    'builtin', 'pfile', 'dir', 'class'};
        if S.confirm || kind ~= 0
            if kind ~= 0
                warning('%s already exists as a %s at %s\n\n', ...
                    name, ...
                    kind_str{kind}, ...
                    which(name));

                conflicts = [conflicts; {which(name)}]; %#ok<AGROW>
            end
            if ~inputYN_def(sprintf('Move %s\n', classdir), true)
                skipped = [skipped; {classdir_full}]; %#ok<AGROW>
                continue;
            end 
        end

        % Determine dst
        dst = fullfile(S.root, ['@', name]);
        exist_dst_dir = exist(dst, 'dir');

        if exist_dst_dir
            % If the destination class directory exists already, 
            % there's something wrong.
            error('Both %s and %s exist already!\n\n', classdir_full, dst);
    %         skipped = [skipped; {classdir_full}]; %#ok<AGROW>
    %         
    %         % Should not make a new alias
    %         continue;
        else
            % Move only if dst does not exist already.
            movefile(classdir_full, dst);
            moved = [moved; {classdir_full}]; %#ok<AGROW>
            if S.verbose
                fprintf('Moved\n  %s\nto\n  %s.\n\n', classdir_full, dst);
            end
        end

        % Always make an alias here. If classdir was already moved,
        % there wouldn't have been classdir in its original place.
        pkg = bml.pkg.class2pkg(bml.pkg.file2pkg(classdir_rel));
        C = varargin2C({
                'overwrite_existing', true
            }, copyFields(struct, S, {
                'verbose'
                'copyright_line'
                'copyright_name'
            }));

        % Since S.root is the current folder, name is always the moved class.
        bml.pkg.make_alias_in_pkg(name, pkg, C{:});
    end
end

%% Then move individual m files that are not inside class folders
if isequal(src, [])
    mfiles = rdir(fullfile(S.root, '**/*.m'));
    mfiles = {mfiles.name};
else
    if ~iscell(src)
        src = {src};
    end
    assert(iscell(src));
    mfiles = src;
end
n = numel(mfiles);

for ii = 1:n
    % Parse name
    mfile = mfiles{ii};
    if isa(mfile, 'function_handle')
        mfile = func2str(mfile);
    end
    if isempty(dir(mfile))
        mfile0 = mfile;
        mfile = which(mfile0);
        if isempty(mfile)
            error('%s does not exist!\n\n', mfile0);
        end
    end
    
    [pth, name] = fileparts(mfile);
    
    % Skip files inside class folders, 
    % since we have already dealt with them.
    if any(pth == '@')
        continue;
    end
    
    % If the name already exists, confirm.
    kind = exist(name); %#ok<EXIST>
    kind_str = {'variable', 'file', 'mex', 'simulink', ...
                'builtin', 'pfile', 'dir', 'class'};
    if S.confirm || ((kind ~= 0) && (S.confirm >= 2))
        if kind ~= 0
            warning('Already exists:\n  %s\nas \n  %s\nat \n  %s\n\n', ...
                name, ...
                kind_str{kind}, ...
                which(name));
            
            conflicts = [conflicts; {which(name)}]; %#ok<AGROW>
        end
        to_confirm = true;
    else
        to_confirm = false;
    end
    
    % Determine dst
    if S.use_subfolder
        dst_dirs = strsplit(dir2pkg(fileparts(mfile), ''), '.');
        dst = fullfile(S.root, dst_dirs{:}, [name, '.m']);
    else
        dst = fullfile(S.root, [name, '.m']);
    end
    exist_dst = exist(dst, 'file');
    
    to_skip = false;
    if exist_dst && ~S.update_alias
        to_skip = true;
    else
        if S.confirm
            if ~inputYN_def( ...
                    sprintf('Move\n  %s\nto\n  %s\n\n', mfile, dst), ...
                    true)
                to_skip = true;
            end
        end
    end
    
    if to_skip
        % If dst exists, then mfile is already the alias, 
        % and dst is the original file, so dst must not be overwritten.
        skipped = [skipped; {mfile}]; %#ok<AGROW>
        continue;
    elseif ~exist_dst
        % Move only if dst does not exist already.
        mkdir2(fileparts(dst));
        movefile(mfile, dst);
        moved = [moved; {mfile}]; %#ok<AGROW>
        if S.verbose
            fprintf('Moved\n  %s\nto\n  %s.\n\n', mfile, dst);
        end
    end
    
    % If dst was made anew, alias needs to be made.
    % If update_alias = true, force updating exsiting alias.
    if ~exist_dst || S.update_alias
        pkg = bml.pkg.class2pkg(bml.pkg.file2pkg(mfile));
        C = varargin2C({
                'root', S.root
                'overwrite_existing', true
            }, copyFields(struct, S, {
                'verbose'
                'copyright_line'
                'copyright_name'
            }));
        bml.pkg.make_alias_in_pkg(dst, pkg, C{:});
        
        if ~exist_dst
            fprintf('Alias created in\n  %s.%s\n\n', pkg, dst);
        else
            fprintf('Alias updated in\n  %s.%s\n\n', pkg, name);
        end
    end
end
