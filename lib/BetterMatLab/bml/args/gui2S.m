function [sv, cpreset, S, s] = gui2S(varargin)
% [sv, cpreset, S, s] = gui2S(S, varargin)
%
% Inspired by Ted MetCalfe's suggestion.
% Written by Yul Kang.

opt = varargin2S(varargin, {
    'hfig',    []
    'default', ''
    'popup',   {}
    'table',   {}
    'S',       struct('preset', struct('field', '[]'))
    'file',    'gui2S/gui2S.json.txt' % Save as a text file, to track with a versioning system.
    });

%% Figure
if isempty(opt.hfig)
    hfig = fig_tag('gui2S'); % dialog('Resize', 'on', 'WindowStyle', 'normal');
end
set(hfig, 'CloseRequestFcn', @close_dlg);
setpop('reset');

%% File
if ~isempty(opt.file) && exist(opt.file, 'file')
    S = loadjson(opt.file);
    S_orig = S.S;
    S = S_orig;
end

%% Struct of struct
if ~exist('S', 'var')
    S_orig = opt.S;
    S = S_orig;
end

%% Convenience functions
% To use in other nested functions.
f_dat = @gettab; 
f_tab2S = @tab2S;
f_S2dat = @S2dat;
f_S2tab = @S2tab;
f_getpop = @getpop;
f_setpopval = @setpopval;
f_saveS  = @saveS;
f_validvalue = @validvalue;
f_set_preset = @set_preset;
f_show_preset = @show_preset;
f_duplicate_preset = @duplicate_preset;

%% Presets - Popup
presets_act = {
    '[Duplicate Preset]'
    '[Delete Preset]'
    '[Add field]'
    '[Delete field]'};
presets  = fieldnames(S);
% npresets_act = length(presets_act);
% npresets     = length(presets);

if ~any(strcmp(opt.default, presets))
    if ~isempty(opt.default)
        warning('Preset %s not found!\n', opt.default);
    end
    opt.default = presets{1};
end
cpreset = opt.default;
s   = S.(cpreset);

opt.popup = varargin2C(opt.popup, {
    'Style',    'popup'
    'String',   [presets; presets_act]
    'Value',    find(strcmp(opt.default, presets))
    'Units',    'normalized'
    'Position', [0.05 0.85 0.9 0.1]
    'Callback', @setpop
    });
hpop = uicontrol(hfig, opt.popup{:});

%% Fields - Table
opt.table = varargin2C(opt.table, {
    'ColumnName',       {'Edited',  'Value'}
    'ColumnEditable',   [false, true]
    'ColumnFormat',     {'logical', 'char'}
    'ColumnWidth',      {'auto', 200}
    'CellEditCallback', @settab
    'Units',            'normalized'
    'Position',         [0.05 0.05 0.9 0.8]
    });
    
htab = uitable(hfig, opt.table{:});
setpop(hpop, []);

%% Wait until closed
try
    uiwait(hfig);
catch err_uiwait
    warning(err_msg(err_uiwait));
    delete(hfig);
end

%% Return evaluated struct
s  = S.(cpreset);
sv = struct;
for cf = fieldnames(s)'
    if isempty(s.(cf{1}))
        warning('Replacing empty field %s with ''[]''\n', cf{1});
        s.(cf{1}) = '[]';
    end
    
    try
        sv.(cf{1}) = eval(s.(cf{1}));
    catch err
        fprintf('Error evaluating field %s: ''%s''\n', cf{1}, s.(cf{1}));
        fprintf('Leaving it empty.\n');
        warning(err_msg(err));
    end
end

%% Nested functions
    function setpop(src, dat)
        persistent prev_preset
        
        if ischar(src) && strcmp(src, 'reset')
            prev_preset = '';
            return;
        end
        
        cpop = f_getpop();
        
        switch cpop
            case '[Duplicate Preset]'
                %% Duplicate preset
                f_duplicate_preset();
                
            case '[Delete Preset]'
                %% Delete preset
                if length(presets) <= 1
                    warning('Cannot remove the last preset!');
                else
                    if strcmp(questdlg('Do you really want to delete the current preset?', 'Confirm Delete', ...
                            'Yes', 'No', 'No'), 'Yes')
                        S = rmfield(S, cpreset);
                        ix_preset = find(strcmp(cpreset, presets));
                        presets   = setdiff(presets, cpreset);
                        n_presets = length(presets);
                        cpreset   = presets{min(ix_preset, n_presets)};
                        f_show_preset(cpreset);
                    end
                end
                
            case '[Add field]'
                %% Add field
                cfld = get(htab, 'RowName');
                
                good_default = false;
                ii = 1;
                while ~good_default
                    new_fld_default = sprintf('field_%d', ii);
                    good_default = ~any(strcmp(new_fld_default, cfld));
                    ii = ii + 1;
                end
                cinp = inputdlg({'Name', 'Value'}, 'Add field', 1, ...
                    {new_fld_default, '[]'});
                [new_fld, new_val] = deal(cinp{:});
                
                if isempty(new_fld) || any(strcmp(new_fld, cfld))
                    fprintf('Empty or existing field name %s!\n', new_fld);
                else
                    cdat = get(htab, 'Data');
                    ndat = size(cdat, 1);
                    
                    cfld{ndat+1,1} = new_fld;
                    cdat{ndat+1,1} = true;
                    cdat{ndat+1,2} = f_validvalue(new_val);
                    
                    set(htab, 'RowName', cfld, 'Data', cdat);
                end
                
            case '[Delete field]'
                %% Delete field
                cfld  = inputdlg('Field to delete');
                cfld  = cfld{1};
                cflds = get(htab, 'RowName');
                ix   = find(strcmp(cfld, cflds));

                if isempty(ix)
                    if ~isempty(cfld)
                        fprintf('The field %s does not exist. Ignoring.\n', cfld);
                    end
                else
                    if ~isempty(ix)
                        nfld  = length(cflds);
                        ix_incl = setdiff(1:nfld, ix);

                        cdat = get(htab, 'Data');
                        
                        set(htab, ...
                            'RowName',  cflds(ix_incl), ...
                            'Data',     cdat(ix_incl,:));
                    end
                end
                set(hpop, 'Value', find(strcmp(cpreset, presets)));
                
            otherwise
                %% Regular preset
                if ~isempty(prev_preset) && ...
                        (prev_preset(1) ~= '[') && ...
                        ~strcmp(prev_preset, cpop)
                    f_saveS();
                end
                cpreset = cpop;
                f_show_preset(cpreset);
        end
        
        cpop = f_getpop();
        if ~isempty(cpop) && cpop(1) == '['
            f_setpopval(cpreset);
        end
        
        if isempty(prev_preset) || ~strcmp(prev_preset, cpreset)
            prev_preset = cpreset;
        end
    end

    function cnam = getpop
        v    = get(hpop, 'Value');
        cnam = get(hpop, 'String');
        cnam = cnam{v};
    end

    function setpopval(cnam)
        v    = get(hpop, 'String');
        ix   = find(strcmp(cnam, v));
        set(hpop, 'Value', ix);
    end

    function settab(src, dat)
        % Check if the edited value is different from the saved value.
        % Only respond to edits in the Value column.
        if dat.Indices(2) ~= 2, return; end
        
        crow = dat.Indices(1);
        
        f = get(src, 'RowName');
        f = f{crow};
        
        ctab = get(htab, 'Data');
        newdata = dat.NewData;
        olddata = dat.PreviousData;
        
        newdata = f_validvalue(newdata, olddata);

        ctab{crow,1} = ~isfield(S.(cpreset), f) || ~strcmp(newdata, S.(cpreset).(f));
        ctab{crow,2} = newdata;
        set(htab, 'Data', ctab);
    end

    function newdata = validvalue(newdata, olddata)
        if nargin < 2, olddata = '[]'; end
        
        try
            tval = eval(newdata);             %#ok<NASGU>
        catch err_validvalue
            fprintf('Error evaluating ''%s'':\n', newdata);
            warning(err_msg(err_validvalue));
            
            try
                tval = eval(olddata); %#ok<NASGU>
                fprintf('Entries should be a valid MATLAB expression. Ignoring change.\n');
                newdata = olddata;
            catch err_validvalue
                warning(err_msg(err_validvalue));
                fprintf('Old entry %s was an invalid MATLAB expression. Setting to [].\n', olddata);
                newdata = '[]';
            end
        end
    end

    function d = gettab(ix)
        % Value column of the table.
        %
        % d = gettab(ix)
        d = get(htab, 'Data');
        
        if nargin < 1
            d = d(:,2);
        else
            d = d(ix,2);
        end
    end

    function cS = tab2S
        f  = get(htab, 'RowName');
        d  = get(htab, 'Data');
        cS = cell2struct(d(:,2), f, 1);
    end

    function cdat = S2dat(cS)
        f = fieldnames(cS);
        d = struct2cell(cS);
        
        cdat = [f, d];
    end

    function S2tab(cS)
        d  = f_S2dat(cS);
        ix = cellfun(@isempty, d(:,2));
        
        if any(ix)
            warning('Empty entries are replaced with ''[]'' !');
            cfprintf(' %s', d(ix,1));
            fprintf(' = ''[]''\n');
            d(ix) = {'[]'};
        end
        
        set(htab, 'Data', d);
    end

    function saveS(src, dat)
        cS = f_tab2S();
        
        if ~isequal(cS, S.(cpreset))
            q = questdlg('Where to keep the change?', 'Preset changed', ...
                'Save as..', 'Overwrite current preset', 'Discard', ...
                'Save as..');
            switch q
                case 'Save as..'
                    f_duplicate_preset();
                    
                case 'Overwrite current preset'
                    f_set_preset(cpreset);
                    
                case 'Discard'
                    f_show_preset(f_getpop());
            end
        end
    end

    function duplicate_preset
        new_nam = inputdlg('New preset name:');
        new_nam = new_nam{1};
        if isempty(new_nam) || any(strcmp(new_nam, presets))
            disp('Give nonempty name that is not used already!');
        else
            f_set_preset(new_nam);
        end
    end

    function set_preset(new_nam)
        % Add a new preset new_nam with current table values.
        % Can be used to modify an existing preset.
        S.(new_nam) = f_tab2S(); % cell2struct(get, presets, 1);
        
        cpreset = new_nam;
        presets = vVec(union(presets, cpreset));
        ix      = find(strcmp(cpreset, presets));
        set(hpop, 'String', [presets; presets_act], 'Value', ix);
    end

    function show_preset(new_nam)
        % Show the preset in the popup and table.
        cpreset = new_nam;

        presets = setdiff(get(hpop, 'String'), presets_act, 'Stable');
        ix = find(strcmp(cpreset, presets));
        set(hpop, 'Value', ix);
        
        cdat = vVec(struct2cell(S.(cpreset)));
        set(htab, ...
            'RowName', fieldnames(S.(cpreset)), ...
            'Data', [num2cell(false(size(cdat))), cdat]);
    end

    function close_dlg(src, dat)
        f_saveS();
        
        if ~isequal(S_orig, S)
            q = questdlg(sprintf('Preset changed. Save to %s?', opt.file), '', ...
                    'Save', 'Save as..', 'Discard', 'Save');
            
            if strcmp(q, 'Save as..')
                new_name = inputdlg('File name:', '', 1, opt.file);
                opt.file = new_name{1};
            end
                
            if ~strcmp(q, 'Discard')
                for prst = fieldnames(S)'
                    cs = S.(prst{1});
                    for cfld = fieldnames(cs)'
                        if isnumeric(cs.(cfld{1}))
                            cv = ['[', evalc('disp(cs.(cfld{1}))'), ']'];
                            cv(find(cv == sprintf('\n'), 2, 'last')) = '';
                            cs.(cfld{1}) = cv;
                        end
                    end
                    S.(prst{1}) = cs;
                end
                
                savejson('S', S, opt.file);
                fprintf('Saved presets to %s\n', opt.file);
            end
        end
        
        delete(src);
    end
end