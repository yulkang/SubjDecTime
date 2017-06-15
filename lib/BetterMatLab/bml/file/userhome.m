function res = userhome(src)
% USERHOME - Returns user home directory in UNIX system.
%
% userhome 
% : Returns user home directory
%
% res = userhome(src)
% : (1) Converts '~' in the beginning to user home directory, or
%   (2) Converts '/Users/poo' to the current user home directory.
%   (3) Otherwise, returns res = src.

persistent USER_HOME

if isempty(USER_HOME)
    if isunix
        pd  = cd('~');
        USER_HOME = pwd;
        cd(pd);
    else
        switch getComputerName
            case {'luke-HP', 'PLEXONRIG4'}
                USER_HOME = 'C:\Users\YulKang';
            case 'Susie-IdeaPad'
                USER_HOME = 'C:\Users\Susie';
            otherwise
                error('Not working on non-unix system!');
        end
    end
end    

USER_ROOT = '/Users/';
USER_ROOT_LENGTH = length(USER_ROOT);

f_userhome_ix = @(s) find(s=='/', 3, 'first');

if ~exist('src', 'var')
    res = USER_HOME;
    
elseif ischar(src)
    if any(strcmp(COMPUTER_SHORT_NAME, {'MBR_YK', 'Hudson', 'luke-HP'})) ...
            && strncmp(src, '/home/', 6)
        src = strrep(src, '/home/', USER_ROOT);
    end

    if ~isempty(src) && src(1) == '~'
        res = fullfile(USER_HOME, src(2:end));
        
    elseif length(src) >= USER_ROOT_LENGTH && strcmp(src(1:USER_ROOT_LENGTH), USER_ROOT)
        userhome_ix  = f_userhome_ix(src);
        
        if length(userhome_ix) == 2
            res = USER_HOME;
        elseif length(userhome_ix) >= 3
            if any(strcmp(COMPUTER_SHORT_NAME, {'Hudson', 'MBR_YK', 'Jonas'}))
                if any(strfind(src, '/Dropbox'))
                    res = src;
                else
                    res = strrep(src, src(1:(userhome_ix(3)-1)), fullfile(userhome, 'Dropbox'));
                end
            else
                res = src;
            end
            userhome_ix  = f_userhome_ix(res);
            
            res = fullfile(USER_HOME, res(userhome_ix(3):end));
        end
    else
        res = src;
    end
    
    if ~any(strcmp(COMPUTER_SHORT_NAME, {'Hudson', 'MBR_YK', 'Jonas'})) % Add back Dropbox
        res = strrep(res, 'Dropbox/', '');
        res = strrep(res, 'Dropbox\', '');
    end
    
elseif iscell(src)
    res = cellfun(@userhome, src, 'UniformOutput', false);
    
elseif isempty(src)
    res = [];
    
else
    error('userhome:src_bad_type', 'src should be string, cell, empty, or omitted!');
end