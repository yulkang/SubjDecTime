function [res, log_data] = name(subdir, kind, ext, comment, data_files, varargin)
% LOGGING.NAME  Suggests a name & path for a data file following the code's.
%
% [res, log_data] = name(subdir, kind, ext, [comment, data_files, 'opt1', opt1, ...])
%
% INPUT:
%   SUBDIR, KIND, EXT, COMMENT:
%       String that determines the data file's name and location.
%       If your code is */CodeNData/Code/Proj/fun.m,
%       your data is saved to
%           */CodeNData/Data/Proj/fun/subdir/fun_kind_yymmddTHHMMSS.FFF_comment.ext 
%       ('parallel' scheme, the default), or
%           */CodeNData/Code/Proj/Data/fun/subdir/fun_kind_yymmddTHHMMSS.FFF_comment.ext 
%       ('subdir' scheme).
%
%       Note that this comment can be different from the commit message.
%       That is, if you commit via logging.name, you will be asked for
%       the commit message separately.
%
%   DATA_FILES:
%       Cell array of full path to data file names that are necessary 
%       to generate the file that is currently being named.
%       For example, give .mat file's full path when you name a figure file.
%       data_files is saved in .json file that is automatically generated.%
%
% OPTIONS:
%
% 'scheme'
% : 'parallel'(default)|'subdir'.
%   See above for examples.
%     - 'parallel' requires that your code's path contains '/CodeNData/Code/'
%       or the pattern specified by 'code_base' option.
%       It replaces 'code_base' by 'data_base' to produce data file's path.
%                 
% 'add_datestr'
% : Adds the value of logging.datestr to the file name. Defaults to true.
%
% 'bCaller'
% : If empty or unspecified, defaults to the basecaller.
%   The basecaller is the 'root' of the program(s) that you run
%   to invoke logging.name. For example, if you run test1.m,
%   which calls test2.m, which in turn calls logging.name,
%   the basecaller is test1.m
%   When you use cell mode, which is NOT recommended but is convenient,
%   the path to the basecaller is assumed to be the present working directory,
%   and the name of the basecaller is set to 'base'.
%
% 'code_base'
% : Pattern in the code's path that is replaced in 'parallel' scheme.
%   Defaults to '/CodeNData/Code/'
% 
% 'data_base'
% : Pattern that replaces 'code_base' in 'parallel' scheme.
%   Defaults to '/CodeNData/Data/'
%
% 'verbose'
% : Defaults to true.
%
% 'journal'
% : Not available yet.
%
% 'create_dir'
% : Create data folder when absent. Default to true.
%
% 'ask_comment'
% : Asks for comment if empty or unspecified.
% 
% 'to_log'
% : Saves metadata to a .json text file. Defaults to true.
%
% 'commit_changes'
% : Whether to commit uncommitted changes.
%   'ask': (Default) Asks if to commit.
%   'yes': Commits without asking. Still asks for commit message.
%   'no' : (Not recommended) Never commits. Can harm integrity of log.
%
% 'add_info'
% : Additional information to add to the .json log file.
%   Don't give too huge information or double data that needs precision.
%
% OUTPUT:
%   RES: 
%       A full path that suggests the data file's location and name.
%       Use like the following:
%           save(logging.name(...), 'data');
%       or
%           print(gcf, logging.name(...), '-depsc2');
%
%       logging.name only returns the suggested name and path,
%       rather than actually saving the data, 
%       to accomodate for any means of saving.
%
%   LOG_DATA:
%       A struct that contains metadata for the data file being named.
%
% EXAMPLE: Type logging.test and press enter for tutorial.
%
% See also logging.test, logging, PsyLib
%
% 2013 (c) Yul Kang. See help PsyLib for the license.

% Defaults
S = varargin2S(varargin, { ...
        'bCaller',      '', ...
        'pth_code',     '', ...
        'nam',          '', ...
        ...
        'code_base',    '/CodeNData/Code/', ...
        'data_base',    '/CodeNData/Data/', ...
        'data_subdir',  'Data', ...
        ...
        'add_datestr',  true, ...
        'datestr',      '', ...
        ...
        'scheme',       'parallel', ...
        'verbose',      true, ...
        'verbose_log',  false, ...
        'journal',      true, ...
        'create_dir',   true, ...
        'ask_comment',  false, ...
        ...
        'to_log',       true, ...
        'commit_changes',  'ask', ... % 'yes', 'no', 'ask'
        'add_info',     {}, ...
        });

if ~exist('ext', 'var'), ext = ''; end
if ~exist('data_files', 'var'), data_files = {}; end

% Ask comment
if ~exist('comment', 'var') || isempty(comment)
    if S.ask_comment 
        comment = input('Comment: ', 's');
    else
        comment = '';
    end
end

% Check input
assert(ischar(subdir) && ischar(kind) && ischar(ext) && ischar(comment), ...
    'Each of subdir, kind, ext, and comment should be a string!');
assert(iscell(data_files), ...
    'data_files should be a cell array of file paths!');
assert(any(strcmp(S.scheme, {'parallel', 'subdir'})), ...
    'scheme should be either ''parallel'' or ''subdir''');
assert(isNameValuePair(S.add_info), ...
    'Give name-value pair for ''add_info'', like {''name1'', value1, ...} !');

% Initialize output
log_data = struct;

if isempty(S.bCaller) || isempty(S.pth_code) || isempty(S.nam)
    [bCaller, pth_code, nam] = logging.base_caller(S.bCaller, {mfilename('fullpath')});
else
    [bCaller, pth_code, nam] = unpackStruct(S, 'bCaller', 'pth_code', 'nam');
end
log_data.base_caller = bCaller;

% Check if pth_code is under Git version control.
assert(logging.is_versioned(pth_code), ...
    '%s should be under Git version control!', pth_code);

% Get pth_data from pth_code.
if strcmp(S.scheme, 'parallel')
    % Replace code_base in the pth with data_base
    occurence = strfind(pth_code, S.code_base);
    if ~any(occurence)
        warning(['Cannot use ''parallel'' scheme because\n', ...
                 'the path to the program %s \n', ...
                 'does not contain the pattern ''%s''. \n\n', ...
                 'Switching to ''subdir'' scheme.\n', ...
                 'Try setting ''code_base'' referring to help logging.name.\n'], ...
            bCaller, S.code_base);
        S.scheme = 'subdir';

    elseif nnz(occurence) > 1
        warning(['Cannot use ''parallel'' scheme because\n', ...
                 'the path to the program %s\n' ....
                 'has multiple occurences of the pattern ''%s''.\n\n', ...
                 'Switching to ''subdir'' scheme.\n', ...
                 'Try setting ''code_base'' referring to help logging.name.\n'], ...
            S.code_base);
        S.scheme = 'subdir';

    else
        pth_data = add_filesep(strrep(pth_code, S.code_base, S.data_base));
    end
end
if strcmp(S.scheme, 'subdir')
    % Put data under pth_code/(S.data_subdir).
    pth_data = fullfile(pth_code, S.data_subdir);
end
        
% Make full name
pth_full = add_filesep(fullfile(pth_data, nam, subdir));
nam_full = str_bridge('_', nam, kind);

if S.add_datestr
    if isempty(S.datestr)
        c_datestr = logging.datestr;
    else
        c_datestr = S.datestr;
    end    
else
    c_datestr = '';
end
nam_full = str_bridge('_', nam_full, c_datestr, comment);
    
% Output
res = fullfile(pth_full, [nam_full, ext]);

% Create folder if absent
if ~exist(pth_full, 'dir') && S.create_dir
    mkdir(pth_full);
end

% Log
if S.to_log || nargout >= 2
    try
        log_data = logging.keep_log(res, bCaller, ...
            {'verbose',                     S.verbose_log, ...
             'exclude_from_base_caller',    {'name'}, ...
             'commit_changes',              S.commit_changes}, ...
             ...
            'repo',         logging.locate_repo(pth_code), ...
            'datestr',      c_datestr, ...
            'comment',      comment, ...
            'data_files',   data_files, ...
            'add_info',     varargin2S(S.add_info));
    catch err_log
        warning(err_msg(err_log));
    end
end

% Prompt or journal
fprintf('Named     %s (click to copy path to clipboard).\n', ...
    cmd2link(sprintf('clipboard(''copy'', ''%s'')', res), [nam_full, ext]));

% msg = sprintf('Named     %s\n', fullfile(pth_full, [nam_full, ext]));
if S.journal,
%     try
%         journal(msg, {}, 'verbose', S.verbose);
%     catch err_journal
        % Journaling will be released later.
%     end
end