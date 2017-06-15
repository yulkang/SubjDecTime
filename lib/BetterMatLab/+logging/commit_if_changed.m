function D = commit_if_changed(base_caller, commit_opt, varargin)
% D = commit_if_changed(base_caller, commit_opt, varargin)
%
% {commit_opt}
%     'base_caller', '', ...
%     'repo',     '', ...
%     'datestr',  '', ...
%     'comment',  '', ...
%
% varargin
%     'verbose',                true, ...
%     'commit_changes',         'ask', ...
%     'confirm_commit_comment', true, ...

%% Parse options
if ~exist('commit_opt', 'var'), commit_opt = {}; end
D = varargin2S(commit_opt, { ...
    'base_caller', ''
    'repo',     ''
    'datestr',  ''
    'comment',  ''
    'hash',     ''
    'commit_message', ''
    });

S = varargin2S(varargin, { ...
    'verbose',                true, ...
    'commit_changes',         'ask', ...
    'confirm_commit_comment', true, ...
    });

%% Parse base_caller and determine repo
if ~exist('base_caller', 'var')
    base_caller = '';
end

D.base_caller = base_caller;

if isempty(D.repo)
    D.repo = logging.locate_repo(D.base_caller);
end

%% Parse datestr
if isempty(D.datestr)
    D.datestr = logging.datestr;
end

%% Commit if there's any change and asked to.
if isempty(D.hash)
    any_change = logging.get_status(D.repo, false);

    if any_change
        switch S.commit_changes
            case {'yes', 'ask'}
                to_commit = true;
            case 'no'
                to_commit = false;
                warning(sprintf(['You chose to ignore uncommitted changes. Log may be faulty.\n' ...
                         'Consider setting ''commit_changes'' option to ''yes'' or ''ask''.'])); %#ok<SPWRN>
        end
    else
        to_commit = false;
    end

    if to_commit
        committed = logging.commit(D.comment, ...
            'commit_in_dir', D.repo, ...
            'verbose',       S.verbose, ...
            'confirm',       strcmp(S.commit_changes, 'ask'), ...
            'confirm_comment', S.confirm_commit_comment);

        if ~committed
            warning(['You chose to ignore uncommitted changes. Log may be faulty.\n' ...
                     'It is recommended to always commit before logging for the log''s integrity.']);
        end
    end

    % Hash should be retrieved after a potential commit.
    D.hash = logging.get_hash(D.repo);
end

if isempty(D.commit_message)
    % Commit message can be different from comment for the file in general.
    D.commit_message = logging.get_commit_message; 
end
