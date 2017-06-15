function [res, bak, S, D, cmd] = save(file, save_args, archive_opt)
% [res, bak, S, D, cmd] = save(file, save_args={}, archive_opt={})
%
% archive_opt : Can be {S} with S from another call to logging.archive.
%
% See also save, logging.archive

if nargin < 1, file = 'matlab.mat'; end
if nargin < 2, save_args = {}; end
if nargin < 3, archive_opt = {}; end

[res, bak, S, D] = logging.archive(file, archive_opt{:});

% Save
cmd = ['save(', ...
    str_bridge(',', csprintf('''%s''', [res, save_args])), ')'];
% disp(cmd); % DEBUG
evalin('caller', cmd);

% Backup saved file
copyfile2(res, bak);