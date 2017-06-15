function [res, bak, S, D] = diary(op, file, archive_opt)
% Keep the diary with archiving.
%
% USAGE 1: Sets the file name when 'on'
% [res, bak, S, D] = diary('on',  file, archive_opt)
% diary2('off')
%
% USAGE 2: Sets the file name when 'off'
% diary2('on')
% [res, bak, S, D] = diary('off', file, archive_opt)
%
% USAGE 3: Sets one file name when 'on' and change it when 'off'
% [res, bak, S, D] = diary('on',  file, archive_opt)
% [res, bak, S, D] = diary('off', file, archive_opt)

persistent p_bak p_res

if nargin < 2 || isempty(file), file = 'diary.txt'; end
if nargin < 3, archive_opt = {}; end

switch op
    case 'on'  
        % Starts a diary in '_bak', so that even if it is accidentally
        % closed and another diary2('on', ...) ensues, the old one is 
        % not affected.
        if nargin >= 2
            [res, bak, S, D] = logging.archive(file, archive_opt{:});
            p_res = res;
            p_bak = bak;
            diary(bak);
        else
            p_res = '';
            p_bak = '';
            diary(file);
        end
        
    case 'off' 
        % Closes the diary in '_bak' and copies to the representative location.
        % Overwrites the representative one if exists.  But that is safe
        % because the one in the representative location is already
        % in the '_bak'.
        
        if nargin >= 2 || isempty(p_bak)
            [res, bak, S, D] = logging.archive(file, archive_opt{:});
            
            diary('off');
            diary_file = get(0, 'DiaryFile');
            
            if ~isempty(p_bak) && ~strcmp(p_bak, diary_file)
                warning(['Diary file is at a different location than expected!\m' ...
                         'Expected at %s but found at %s\n'], p_bak, diary_file);
            elseif ~exist(diary_file, 'file')
                warning('Diary file not found!');
            else
                if strcmp(diary_file, bak)
                    copyfile2(diary_file, p_res);
                else
                    % Archive in the new location.
                    movefile2(diary_file, bak);
                    copyfile2(bak,   res);
                end
            end
        else
            diary('off');
            bak = get(0, 'DiaryFile');
            
            if strcmp(p_bak, bak)
                bak = p_bak;
                res = p_res;
                copyfile2(p_bak, p_res);                
            else
                res = bak; % Not used logging.diary2('on', file). No archiving.
            end
        end
        
        p_res = '';
        p_bak = '';
end