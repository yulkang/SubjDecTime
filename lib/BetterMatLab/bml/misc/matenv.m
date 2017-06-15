function files_out = matenv(op, name, note, pth)
% MATLAB_ENV - Saves and loads the list of open documents
%
% matenv
% : save list of currently open files and load another set.
%
% matenv save NAME PATH
% matenv view NAME PATH
% matenv edit NAME PATH
% matenv load NAME PATH
% matenv Load NAME PATH
%
% PATH - Where the list files are located. By default, it is 
%        fullfile(GET_DIR('DATA_BASE'), 'doc_list')
%
% Give NAME = '*' to open GUI dialog box.

persistent cur_name
default_name = 'matlab_files_';

if ~exist('op', 'var')
    fprintf('Backing up currently opened files and loading new.\n');
    matenv save
    files = matenv('Load', '*');
    
    if nargout >= 1
        files_out = files;
    end
    return;
end

if ~exist('name', 'var')
    if ~isempty(cur_name) && ~strcmp(cur_name, '*') ...
        && inputYN_def('Do you want to use the last list %s', true, cur_name)
    
        name = cur_name; 
    else
        name = '*';
    end
    
elseif ~strcmp(name, '*')
    cur_name = name;
end

if ~exist('note', 'var')
    note = nan;
end

if ~exist('pth', 'var')
    if exist('startup', 'file') == 2
        pth = fullfile(GET_DIR('DATA_BASE'), 'doc_list'); 
    else
        pth = cd;
    end
end        
        
if strcmp(name, '*')

    filename = fullfile(pth, sprintf('%s.mat', name));
    def_file = fullfile(pth, sprintf('%s.mat', cur_name));
    filt = filename;
    
    switch op
        case 'open'
            try
                finder(pth);
            catch
                fprintf('Path to doc_list copied to clipboard: %s\n', pth);
                clipboard('copy', pth);
            end
            return;
        
        case 'save'
            ui_title = 'Where to back up the list of open files?';
            [filename, name] = list_file('put', filt, ...
                'PromptString', ui_title, 'InitialValue', def_file);
            
        case 'view'
            ui_title = 'Which list of files to view?';
            [filename, name] = list_file('get', filt, ...
                'PromptString', ui_title, 'InitialValue', def_file);
            
        case 'edit'
            ui_title = 'Which list of files to edit?';
            [filename, name] = list_file('get', filt, ...
                'PromptString', ui_title, 'InitialValue', def_file);
            
        case 'load'
            ui_title = 'Which list of files to open?';
            [filename, name] = list_file('get', filt, ...
                'PromptString', ui_title, 'InitialValue', def_file);
            
        case 'Load'
            ui_title = 'Which list of files to open and replace current ones?';
            [filename, name] = list_file('get', filt, ...
                'PromptString', ui_title, 'InitialValue', def_file);
    end
    
    if isequal(filename, 0), % If CANCEL button is pressed, nothing happens.
        fprintf('%s canceled by user.\n', op);
        
        if nargout >=1
            files_out = {}; 
        end
        return; 
    end
    
elseif isempty(name)
    name = default_name;    
    filename = fullfile(pth, sprintf('%s.mat', name));
    
else
    filename = fullfile(pth, sprintf('%s.mat', name));
end

[pth, nam, ~] = fileparts(filename);
     

switch op
    case 'save'
    %% Save
        % Confirm overwrite
        if exist(filename, 'file')
            fprintf('Current content of %s \n', name);
            matenv('view', nam);
        
            if ~inputYN_def('%s already exists! Overwrite', false, name)
                fprintf('%s canceled by user.\n', op);

                if nargout >=1
                    files_out = {}; 
                end
                return;
            end
        end
        
        % Get note
        if isnan(note)
            % Leave note to yourself
            commandwindow;
            note = input('Note to yourself when you load this: ', 's');
        end
        
        % Get info about open documents
        docs  = matlab.desktop.editor.getAll;
        files = {docs.Filename};
        sel   = {docs.Selection};
        active_file = matlab.desktop.editor.getActiveFilename;
        
        % Put the active file at the end, so that when it loads, it becomes active.
        i_active        = find(strcmp(active_file, files));
        if ~isempty(i_active)
            temp            = files{i_active};
            files{i_active} = files{end};
            files{end}      = temp;

            temp            = sel{i_active};
            sel{i_active}   = sel{end};
            sel{end}        = temp;
        end

        % Show the list of open editor documents
        fprintf('Currently open editor documents:\n');
        for ii = 1:length(files)
            if isempty(sel{ii})
                fprintf('  %s\n', files{ii});
            else
                fprintf('  (%d,%d) %s\n', sel{ii}(1), sel{ii}(2), files{ii});
            end
        end
        fprintf('(line,position) filename\n');
        fprintf('(Last one is active)\n');
        fprintf('\n');
        fprintf('Open editor documents are listed in\n  %s\n\n', filename);
        
        % Get and save figures
        hfig = findobj('Type', 'Figure');
        fprintf('Open figures:');
        if isempty(hfig)
            disp(' None');
        else
            nfig = length(hfig);
            for ii = 1:nfig
                fprintf(' %s', get(hfig(ii), 'Name'));
            end
            fprintf('\n');
            
            if inputYN_def('Save open figures', true)
                figfile = fullfile(pth, 'fig', [nam '.fig']);
                
                if ~exist(fullfile(pth, 'fig'), 'dir')
                    mkdir(fullfile(pth, 'fig'));
                end
                
                if exist(figfile, 'file')
                    mkdir2(fullfile(pth, 'bak/fig'));
                    copyfile(figfile, fullfile(pth, 'bak/fig', [nam '.fig']));
                end
                savefig(hfig, figfile);
                
                fprintf('Open figures are saved in %s\n', figfile);
            end
        end
        
        % Get git branch
        try
            br = logging.get_branch;
            fprintf('On git branch %s\n\n', br);
            
            logging.commit_if_changed;
        catch
            br = '';
            disp('Not under git version control');
        end
        
        % Back up existing.
        if exist(filename, 'file')
            mkdir2(fullfile(pth, 'bak/mat'));
            copyfile_msg(filename, fullfile(pth, 'bak/mat', [nam, '.mat']));
        end
        
        % Write to a mat file
        if ~exist(pth, 'dir')
            mkdir(pth);
        end
        
        % Retrieve history
        try
            history = last_history('verbose', false); %#ok<NASGU>
        catch
            history = '';
        end
        c_pwd = pwd; %#ok<NASGU>
        save(filename, 'c_pwd', 'note', 'files', 'sel', 'history', 'br');

        % Save base workspace
        fprintf('\n');
        fprintf('Current workspace:\n');
        whos;
        if inputYN_def('Save base workspace, too', true)
            filename_ws = f_filename_ws(pth, nam);
            ws_pth = fileparts(filename_ws);
            mkdir2(ws_pth);
            fprintf('Saving base workspace to\n  %s\n\n', filename_ws);
            
            vars = evalin('base', 'whos');
            vars = vars(~cellfun(@(v) isa(v, 'matlab.ui.Figure'), {vars.class}));
            
            evalin('base', ['save ' filename_ws, sprintf(' %s', vars.name)]);
        end
        
    case 'view'
    %% View    
        % Load file and print contents
        fprintf('\n');
        fprintf('Contents of\n  %s :\n\n', filename);
        S = load(filename);
        
        disp('==========');
        disp('pwd');
        disp('==========');
        disp(S.c_pwd);
        
        disp('==========');
        disp('files');
        disp('==========');
        cfprintf('%s\n', S.files);
        
        disp('==========');
        disp('sel');
        disp('==========');
        disp(cell2mat(S.sel'));
        
        disp('==========');
        disp('history');
        disp('==========');
        cfprintf('%s\n', S.history);
        
        disp('==========');
        fprintf('figures: ');
        figfile = fullfile(pth, 'fig', [nam '.fig']);
        if exist(figfile, 'file')
            fprintf('Saved.\n');
        else
            fprintf('Not saved.\n');
        end
        disp('==========');
        
        disp('==========');
        disp('git branch');
        disp('==========');
        try
            fprintf('%s\n', S.br);
        catch
            disp('(Not saved)');
        end
        
        disp('==========');
        disp('note');
        disp('==========');
        disp(S.note);
        fprintf('(Last document was active)\n');

        % append_history doesn't work.
%         D = dir(filename);
%         hist_comment = fprintf('%%-- %s, matenv %s --%%', ...
%             D.date, nam);
%         S.history = [hist_comment; S.history];
%         append_history(hist_comment);
%         
%         disp('History loaded and appended.');
        
%     case 'edit'
%         % Load file and print contents
%         edit(filename);
        
    case 'load'
    %% load
        % Load file
        
%         f = fopen(filename, 'r');
%         
%         c_pwd  = '';
%         c_note = '';
%         c_eof  = false;
%         c_ln   = 0;
%         c_file = 0;
%         
%         sel    = cell(1,10);
%         files  = cell(1,10);
%         
%         while ~c_eof
%             c_ln = c_ln + 1;
%             s    = fgetl(f);
%             
%             if s ~= -1
%                 if c_ln == 1 && strcmpFirst(s, 'pwd=')
%                     c_pwd  = userhome(s(5:end));
%                 elseif c_ln <= 2 && strcmpFirst(s, 'note=')
%                     c_note = s(6:end);
%                 elseif str
%                     c_file = c_file + 1;
%                     
%                     if ~isempty(s) && s(1) == '('
%                         c = textscan(s, '(%d,%d) %s');
%                         sel{c_file}(1) = c{1};
%                         sel{c_file}(2) = c{2};
%                         files{c_file}  = userhome(c{3}{1});
%                     else
%                         files{c_file}  = userhome(s);
%                     end
%                 end
%             else
%                 c_eof = true;
%             end
%         end
%         
%         sel   = sel(1:c_file);
%         files = files(1:c_file);

        load(filename, 'c_pwd', 'note', 'files', 'sel', 'history');
        
        c_note = note;
        
        % First, show what's in the log
        matenv('view', nam);
        
        % Change directory
        if exist('c_pwd', 'var')
            fprintf('\n');
            fprintf('Changing directory from\n  %s\n to the loaded working directory\n  %s\n', ...
                cd, c_pwd); %#ok<NODEF>
            
            try
                cd(c_pwd);
            catch err_cd
                warning(err_msg(err_cd));
                fprintf('Changing directory failed! Maybe moved or deleted?\n');
            end
        else
            fprintf('Working directory information not found in .log\n');
        end
        
        % Load base workspace
        fprintf('\n');
        commandwindow;
        
        filename_ws = f_filename_ws(pth, nam); 
        
        if exist(filename_ws, 'file')
            info_mat = dir(filename_ws);
            siz_mat  = info_mat.bytes;
            fprintf('Size of %s: %1.2fMB\n', filename_ws, siz_mat / 1e6);
            
            if inputYN_def('Display contents', true)
                try
                    m = matfile(filename_ws);
                    disp(m);

                catch
                    warning('Cannot show contents - matfile() is not supported!');
                end
            end
            
            if inputYN_def('Load base workspace', true)
                S_list = input('Load options (ENTER to load all): ');
                S_name = input('Struct name to load base workspace into (ENTER to load to base): ', 's');

                fprintf('\n');

                if isempty(S_name)
                    if inputYN_def('Clear workspace variables before loading new? Otherwise, they will accumulate', true)
                        vars = evalin('base', 'who');
                        cmd  = ['clear', sprintf(' %s', vars{:})];
                        disp(cmd);
                        evalin('base', cmd);
                    end
                    
                    fprintf('Loading base workspace from\n  %s\n into base workspace.\n', filename_ws);
                    try
                        evalin('base', ['load ' filename_ws, ' ' S_list]);
                    catch err_load
                        warning(err_msg(err_load));
                        warning('Error during loading!');
                    end
                    try
                        evalin('base', 'whos');
                    catch err_whos
                        warning(err_msg(err_whos));
                        warning('Error during whos!');
                    end                    
                else
                    fprintf('Loading base workspace from\n  %s\n into struct %s\n', filename_ws, S_name);
                    evalin('base', [S_name ' = load(''' filename_ws ''')']);
                end
            end
        else
            fprintf('Workspace was not saved for this project.\n\n');
        end
        
        % Open figures
        figfile = fullfile(pth, 'fig', [nam '.fig']);
        
        if exist(figfile, 'file')
            if inputYN_def('Open saved figures', true)
                if ~isempty(findobj('Type', 'Figure')) ...
                        && inputYN_def('Close current figures', true)
                    close all;
                end

                try
                    openfig(figfile);
                    fprintf('Opened saved figures.\n\n');
                catch err
                    warning(err_msg(err));
                    fprintf('Error occured opening figures.\n\n');
                end
            end
        else
            fprintf('No saved figures exist.\n\n');
        end
                
        % Checkout git branch
        try
            load(filename, 'br');
            if ~isempty(br) && ...
                    inputYN_def(sprintf('Do you want to checkout branch %s', br), true)
                logging.checkout(br);
            end
        catch
            disp('git branch information is not found.');
        end
        
        % Open file
        fprintf('\n');
        if inputYN_def('Open editor files', true);
            for ii = 1:length(files) %#ok<NODEF>
                fprintf('Opening\n  %s\n', files{ii});
                if exist(files{ii}, 'file')
                    c_doc = matlab.desktop.editor.openDocument(files{ii});

                    % Set cursor at remembered location
                    if ~isempty(sel{ii}) %#ok<NODEF>
                        c_doc.goToPositionInLine(sel{ii}(1), sel{ii}(2));

                        fprintf('    Setting cursor at line %d, position %d\n', ...
                            sel{ii}(1), sel{ii}(2));
                    end
                else
                    fprintf('  The above file is missing -- maybe moved or deleted?\n');
                end            
            end
        end
        
        % Show note
        if ~isempty(c_note)
            fprintf('\n');
            fprintf('Note: %s\n', c_note);
        end
        
    case 'Load' 
        %% Load
        % First load
        files = matenv('load', name, note, pth);
        
        % Then close others
        docs  = matlab.desktop.editor.getAll;
        for ii = 1:length(docs)
            if ~any(strcmp(docs(ii).Filename, files)) % if matches none
                fprintf('  Closing %s\n', docs(ii).Filename);
                close(docs(ii));
            end
        end
end

fprintf('\n');
cur_name = name;

if nargout >= 1
    files_out = files;
end
end

function f_mat = f_filename_ws(pth, nam)
    f_mat = fullfile(pth, 'ws', [nam '.mat']);       
end
