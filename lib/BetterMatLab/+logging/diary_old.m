function [res, log_data] = diary_old(op, varargin)
% [res, log_data] = diary_old(op, [subdir, kind, ext, comment, data_files, ...])
%
% 'op': 'on', 'off', 'move'
%
% 'move': Turns off diary and moves, if on.
%
% See also: logging, PsyLib
%
% 2014 (c) Yul Kang. See help PsyLib for the license.

switch op
    case 'on'
        if ~exist('subdir', 'var')
            % Logs in data folder to avoid invoking change in Git controlled folder
            res = logging.name('', 'diary', '.txt', '', {});
            log_data = struct;
        else
            [res, log_data] = logging.name(varargin{:});
        end
        diary(res);
        
    case 'off'
        diary off;
        res = get(0, 'DiaryFile');
        fprintf('%s saved & closed (click to copy path to clipboard).\n', ...
            cmd2link(sprintf('clipboard(''copy'', ''%s'')', res), 'Diary'));
        
    case 'move'
        if strcmp(get(0, 'Diary'), 'on')
            diary_src = get(0, 'DiaryFile');
            diary off;

            [res, log_data] = logging.name(varargin{:});
            
            if ~exist(fileparts(res), 'dir')
                mkdir(fileparts(res));
            end
            
            movefile(diary_src, res);
        end
end