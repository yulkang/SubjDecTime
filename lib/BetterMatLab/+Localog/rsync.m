function cmd = rsync(op, local, varargin)
% cmd = rsync(op, local, ...)
%
% op   : 'push' or 'pull'.
% local: relative path. Defaults to 'Data'.
%
% OPTIONS:
% 'remote',   'pat' % 'gpu'
% 'opt',      '-avz -e ssh'
% 'exclude',  '' % default, bak, code
% 'cmd_only', false
% 'confirm',  true
% 'mkdir',    true
% 'filt_mode', []
% 'verbose',  true

S = varargin2S(varargin, {
    'remote',   'lena' % 'pat' % 'gpu'
    'opt',      '-avz -e ssh'
    'exclude',  '' % default, bak, code
    'cmd_only', false
    'confirm',  true
    'mkdir',    true
    'filt_mode', []
    'verbose',  true
    });

if isempty(S.exclude)
    S.exclude = 'default';
end
exclude_file = fullfile(fileparts(mfilename('fullpath')), ...
    sprintf('rsync_exclude_%s.txt', S.exclude));

S.opt = [S.opt, ' ', sprintf('--exclude-from "%s"', ...
    exclude_file)];
%     DIR_('CODE', sprintf('Bash/rsync_exclude/%s.txt', S.exclude)))];

if nargin < 2 
    local = 'Data';
% else
%     which_local = which(local);
%     
%     if ~isempty(which_local)
%         [loc_dir, loc_nam] = fileparts(which_local);
%         local = fullfile(loc_dir, loc_nam, 'Data');
%     end
end

[pth, nam, ext] = fileparts(local);
if isempty(S.filt_mode)
    S.filt_mode = strcmp(nam, '*') && ~isempty(ext);
end
if S.filt_mode
    local = pth;
end

fmt.protocol = sprintf('yul@%s.shadlenlab.columbia.edu', S.remote);
cmd = {};

switch op
    case 'push'
        src = local;
        dst = S.remote;
        
        src_full = local_full(src);
        src_full = [src_full, filesep];
        dst_full = remote_full(dst, src_full);        
        
        % mkdir remote
        if S.mkdir
            cmd = [cmd, {sprintf('ssh %s mkdir -pv "%s"', fmt.protocol, ...
                strrep(src_full, fullfile(userhome,'Dropbox'), '/home/yul'))}];
        end
        
        % Filter mode
        if S.filt_mode
            src_full = fullfile(src_full, [nam, ext]);
        end
        
    case 'pull'
        src = S.remote;
        dst = local;
        
        dst_full = local_full(dst);        
        src_full = remote_full(src, dst_full);
        src_full = [src_full, filesep];
        
        % mkdir local
        if S.mkdir
            if ~exist(local, 'dir')
                cmd = [cmd, {sprintf('mkdir -pv "%s"', dst_full)}];
            end
        end
        
        % Filter mode
        if S.filt_mode
            src_full = fullfile(src_full, [nam, ext]);
        end
        
    otherwise
        error('op should be either push or pull!');
end

cmd  = [cmd, sprintf('rsync %s "%s" "%s"', S.opt, src_full, dst_full)];

system_prudent(cmd, ...
    'cmd_only', S.cmd_only, ...
    'confirm', S.confirm, ...
    'echo', S.verbose);
end

function f = local_full(d)
% Localog prepends pwd if relative
if isempty(d) || (d(1) ~= '~') && (d(1) ~= filesep)
    f = fullfile(pwd, d); % strrep(d, GET_DIR('CODE_BASE'), GET_DIR('DATA_BASE'));
else
    f = d;
end
end

function f = remote_full(d, local_full)
f = strrep(local_full, fullfile(userhome,'Dropbox'), sprintf('yul@%s.shadlenlab.columbia.edu:~', d));
end