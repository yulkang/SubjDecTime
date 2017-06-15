function [committed, msg, arg, res] = commit(comment, varargin)
% commit  Minimal commit utility.
%
% [msg, arg, res] = commit(comment, varargin)
%
% OPTIONS:
% 'commit_in_dir', GET_DIR('CODE_BASE'), ...
% ...
% 'show_status',   true, ...
% 'confirm',       true, ...
% ...
% 'to_add',        true, ...
% 'add_opt',       {'-A'}, ...
% ...
% 'to_commit',     true, ...
% 'commit_opt',    {'-a', '-m'}, ...
% ...
% 'verbose',       true, ...
%
% OUTPUT:
% msg: status, add, commit
% arg: add, commit
% res: repo, branch, hash, comment
%
% See also logging, PsyLib
%
% 2013 (c) Yul Kang. See help PsyLib for the license.

import Ext.git

S = varargin2S(varargin, {...
    'commit_in_dir', '', ...
    ...
    'confirm',       true, ...
    ...
    'to_add',        true, ...
    'add_opt',       {'-A :/'}, ...
    ...
    'confirm_comment', true, ...
    ...
    'to_commit',     true, ...
    'commit_opt',    {'-a', '-m'}, ...
    ...
    'verbose',       true, ...
    });

if isempty(S.commit_in_dir)
%     try
%         % GET_DIR will be released later.
%         S.commit_in_dir = GET_DIR('CODE_BASE');
%         
%     catch err_GET_DIR
%         err_msg(err_GET_DIR);
%         disp('Assuming that the current directory is within the working directory.');
        S.commit_in_dir = pwd;
%     end
end

% pd = cd(S.commit_in_dir);
% if S.verbose
%     fprintf('cd %s\n', cd);
% end

msg.status = git('status');
if S.verbose || S.confirm
    fprintf('git status\n');
    disp(msg.status);
end

if S.confirm
    fprintf('commit setting:\n');
    disp(S);
    yn = inputYN('Do you want to proceed to commit? (y/n) ');
    if ~yn
        committed = false;
        return; 
    end
end
committed = true;

if S.to_add
    arg.add = ['add', sprintf(' %s', S.add_opt{:})];
    msg.add = git(arg.add);
    
    if S.verbose
        fprintf('git %s\n', arg.add);
        fprintf('%s\n', msg.add);
    end
end

if S.to_commit
    if (~exist('comment', 'var') || isempty(comment))
        comment = input('comment: ', 's');
    elseif S.confirm_comment
        comment = input_def('comment: ', 'default', comment);
    end
    
    if any(strcmp('-m', S.commit_opt))
        arg_comment = sprintf(' "%s"', comment);
    else
        arg_comment = '';
    end
    
    arg.commit = ['commit', sprintf(' %s', S.commit_opt{:}), arg_comment];
    msg.commit = git(arg.commit);
    
    if S.verbose
        fprintf('git %s\n', arg.commit);
        fprintf('%s\n', msg.commit);
    end
end

if nargout >= 3
    res.repo    = logging.locate_repo;
    res.branch  = logging.get_branch;
    res.hash    = logging.get_hash;
    res.comment = comment;
end

% cd(pd);
