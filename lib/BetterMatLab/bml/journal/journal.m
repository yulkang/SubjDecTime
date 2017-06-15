function journal(msg, sprintf_args, varargin)
% JOURNAL - Appends text messages to timestamped file with baseCaller info.
%
% journal
% : Opens journal file on editor (desktop mode) or displays journal file's full path.
%
% journal(MESSAGE)
% : Records MESSAGE to the journal file.
% 
% journal(FORMAT, {ARG1, ARG2, ...})
% : Records sprintf(FORMAT, ARG1, ARG2, ...) to the journal file.
%
% journal(... 'opt1', opt1, ...)
% : Specifies options
%
% Options:
% verbose  : Defaults to false.
%
% See also: PsyGit, baseCaller.

persistent prev_bCaller prev_day

% Options
S = varargin2S(varargin, {...
    'verbose', false ...
    });

% Open file
j_file = fullfile(GET_DIR('DATA_BASE'), 'journal', getComputerName, ...
                  [datestr(now, 'yyyy-mm'), '_' getComputerName, '.txt']);      
if ~exist(fileparts(j_file), 'dir'), mkdir(fileparts(j_file)); end

f = fopen(j_file, 'a');

% No argument: open for editing
if ~exist('msg', 'var')
    fclose(f);
    try
        edit(j_file); 
    catch % e.g. in nodesktop mode
        disp(j_file); % Just provide file name
    end
    return;
end

% Day
curr_day = datestr(now, '\n===== yyyy-mm-dd\n');
if ~strcmp(prev_day, curr_day)
    prev_day = curr_day;
    fprintf(f, curr_day);
end

% Time
hms = datestr(now, 'HH:MM:SS');

% BaseCaller
[~, ~, ~, ~, curr_bCaller, short_bCaller] = ...
    baseCaller({'journal', 'jprintf', 'jdisp', 'PsyGit'}, ...
    'base_fallback', 'guess');

if ~strcmp(prev_bCaller, curr_bCaller)
    fprintf(f, '%s -----baseCaller: %s  (%s)\n', hms, short_bCaller, curr_bCaller);
    prev_bCaller = curr_bCaller;
end

% Message
if ~exist('sprintf_args', 'var'), 
    sprintf_args = {}; 
end

msg = sprintf(msg, sprintf_args{:});

fprintf(f, '%s - %s', hms, msg);
if S.verbose,
    fprintf('%s', msg);
end

% Closing
fclose(f);
end