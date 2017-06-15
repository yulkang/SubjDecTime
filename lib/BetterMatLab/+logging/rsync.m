function cmd = rsync(op, local, varargin)
% cmd = rsync(op, local, ...)
%
% op   : 'push' or 'pull'.
% local: folder, file, function, or script.
%
% OPTIONS:
% 'remote',   'lena'
% 'opt',      '-avz -e ssh'
% 'cmd_only', false

S = varargin2S(varargin, {
    'remote',   'pat' % 'gpu'
    'opt',      sprintf('-avz -e ssh --exclude-from ''%s''', ...
                    DIR_('CODE', 'Bash/rsync_exclude.txt'));
    'cmd_only', false
    });

if nargin < 2
    local = pwd;
    
else
    which_local = which(local);
    
    if ~isempty(which_local)
        [loc_dir, loc_nam] = fileparts(which_local);
        local = fullfile(loc_dir, loc_nam);
    end
end

fmt.protocol = sprintf('yul@%s.shadlenlab.columbia.edu', S.remote);
cmd = {};

switch op
    case 'push'
        src = local;
        dst = S.remote;
        
        src_full = [local_full(src), filesep];
        dst_full = remote_full(dst, src_full);        
        
        % mkdir remote
        cmd = [cmd, {sprintf('ssh %s mkdir -pv %s', fmt.protocol, ...
            strrep(src_full, fullfile(userhome,'Dropbox'), '/home/yul'))}];

    case 'pull'
        src = S.remote;
        dst = local;
        
        dst_full = local_full(dst);        
        src_full = [remote_full(src, dst_full), filesep];
        
        % mkdir local
        if ~exist(local, 'dir')
            cmd = [cmd, {sprintf('mkdir -pv %s', dst_full)}];
        end

    otherwise
        error('op should be either push or pull!');
end

cmd  = [cmd, sprintf('rsync %s %s %s', S.opt, src_full, dst_full)];

system_prudent(cmd, 'cmd_only', S.cmd_only, 'confirm', true);
end

function f = local_full(d)
f = strrep(d, GET_DIR('CODE_BASE'), GET_DIR('DATA_BASE'));
end

function f = remote_full(d, local_full)
f = strrep(local_full, fullfile(userhome,'Dropbox'), sprintf('yul@%s.shadlenlab.columbia.edu:~', d));
end