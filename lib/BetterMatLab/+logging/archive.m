function [res, bak, S, D] = archive(src, varargin)
% [res, bak, S, D] = archive(src, varargin)
%
% res = 'DATA_BASE/BASECALLER_PATH/BASECALLER_NAME/SRC_PATH/SRC_NAME.EXT'
% bak = 'DATA_BASE/BASECALLER_PATH/BASECALLER_NAME/SRC_PATH/_bak/SRC_NAME_DATESTR_COMMENT.EXT'
% header: 'DATA_BASE/BASECALLER_PATH/BASECALLER_NAME/SRC_PATH/_bak/_header/SRC_NAME_DATESTR_COMMENT.EXT.log.json'
% S : Struct containing options. Can be fed back like archive(src, S) to 
%     keep the same setting for the next call to archive.
% D : Struct containing header info
%
% OPTIONS:
% ----------------------------------------------------------------------
% 'bCaller',      ''              % If empty, use baseCaller.
% 'pth',          ''              % If empty, use path paralleling baseCaller.
% 'comment',      ''              % Used in the header and the archive, not in res.
% 'CODE_BASE',    DIR_('CODE')
% 'DATA_BASE',    DIR_('DATA')
% 'archive_dir',  '_bak'
% 'header_opt',   {}
% 'header_info',  {}
% 'datestr',      ''
% 'keep_log',     true
% ----------------------------------------------------------------------
%
% See logging.keep_log for header_opt and header_info.
%
% See also: logging, logging.keep_log, PsyLib

S = varargin2S(varargin, {
    'bCaller',      ''              % If empty, use baseCaller.
    'pth',          ''              % If empty, use path paralleling baseCaller.
    'comment',      ''              % Used in the header and the archive, not in res.
    'CODE_BASE',    DIR_('CODE')
    'DATA_BASE',    DIR_('DATA')
    'archive_dir',  '_bak'
    'header_opt',   {}
    'header_info',  {}
    'datestr',      ''
    'keep_log',     true
    });

%% Detect bCaller from src
if ~isempty(src) && src(1) == ':'
    ix_filesep = find(bsxEq(src, '/\'), 1, 'first');
    if isempty(ix_filesep), ix_filesep = length(src)+1; end
    
    S.bCaller = src(2:(ix_filesep-1));
    src = src((ix_filesep+1):end);
end

%% Set S.pth to DATA_BASE/path_to_bCaller/bCallerName/ if unspecified
% Detect bCaller if unspecified
if isempty(S.bCaller)
    S.bCaller = baseCaller;
end

% If path is not given
if isempty(fileparts(S.bCaller))
    S.bCaller = which(S.bCaller);
end

if isempty(S.pth)
    [pth, nam] = fileparts(S.bCaller);
    S.pth = strrep(fullfile(pth, nam), S.CODE_BASE, S.DATA_BASE);
end

%% Get res and bak
% Parse src
[pth_src, nam_src, ext_src] = fileparts(src);

% Get datestr
if isempty(S.datestr)
    S.datestr = logging.datestr;
end

% Combine
res = fullfile(S.pth, pth_src, [nam_src, ext_src]);
bak = trunc_filename( ...
    fullfile(S.pth, pth_src, '_bak', [nam_src '_' S.datestr '_' S.comment, ext_src]));

%% Log to header
S.header_opt  = varargin2C(S.header_opt, {
    'postfix',      '.json.txt'
    'verbose',      false
    });

% New info to header_opt overrides old info in S.header_info
S.header_info = varargin2C({
    'orig_file',    res
    'bak_file',     bak
    'comment',      S.comment
    'base_caller',  S.bCaller
    'datestr',      S.datestr
    }, S.header_info);

if S.keep_log
    [S.header_info, ~, log_file] = logging.keep_log(bak, which(S.bCaller), S.header_opt, S.header_info{:});
else
    log_file = ''; 
end
D = S.header_info;

%% Print clickable links
fprintf('Named     %s (link to %s, %s, %s, %s).\n', res, ...
    cmd2link(sprintf('clipboard(''copy'', ''%s'')', fileparts(res)), 'dir'), ...
    cmd2link(sprintf('clipboard(''copy'', ''%s'')', res),            'file'), ...
    cmd2link(sprintf('clipboard(''copy'', ''%s'')', bak),            'backup'), ...
    cmd2link(sprintf('clipboard(''copy'', ''%s'')', log_file),       'header'));
