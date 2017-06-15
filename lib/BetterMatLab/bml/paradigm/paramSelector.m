function [Ps, nam, params] = paramSelector(params, varargin)
% [Ps, nam, params] = paramSelector(params)
%
% params : (a) a struct with fields in order of selection, or
%          (b) a .json file containing the struct. 
%              If specified as (b), will save changes back to the file.
% params.selection1 : one of:
%     (a) a struct with fields of choices
%     (b) a cell array of choices
%     (c) an evaluable string
% params.selection1.choice1 : either
% 	  (a) a struct that has fields of evaluable strings.
%     (b) an evaluable string.
%
% Ps        : struct with fields of evaluable strings.  
% Ps.choice_.selection = 'choice' : choice_ is a summary field in the preset.
%
% nam       : name of the preset for Ps
% choice    : choice.selection1 == name of the choice chosen for that selection
%
% See also paramSelectorExample, presetSelector
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'name',         'ask' % 'ask', 'long', 'short', or 'custom'
    });

if ischar(params)
    file   = params;
    params = loadjson(file);
    fprintf('Loaded params from %s\n', file);
    params_orig = params;
else
    file   = '';
end

sels    = fieldnames(params);
nsel    = length(sels);
choice  = struct;

long_name  = '';
short_name = '';

Ps = struct;

for isel = 1:nsel
    selname = sels{isel};
    
    sel     = params.(selname);
    
    fprintf('\n----- Decide on %s\n', selname);
    fprintf('%s', savejson(selname, params.(selname))));
    fprintf('----------\n');

    if isstruct(sel)
        %% Choose among sets of fields
        cchoices = fieldnames(sel)';

%         % Allow adding a value if fields are strings.
%         if ischar(sel.(cchoices{1}))
%             cchoices = [cchoices, {'_new'}]; %#ok<AGROW>
%         end

        cch = ...
            input_def(sprintf('Choose %s', selname), ...
            'choices',  cchoices, ...
            'vertical', 'always');

%         if strcmp(cch, '_new')
%             [cch, cstr] = input_str_value(selname);
%             goodstr = false;
%             while ~goodstr
%                 cstr  = input_def(sprintf('Enter a new value for %s', selname));
%                 try
%                     cval = eval(cstr); %#ok<NASGU>
%                 catch err
%                     disp(err_msg(err));
%                     fprintf('Enter a valid MATLAB expression! Try again.\n');
%                     goodstr = false;
%                 end
%             end 
%             cch   = input_def(sprintf('Name the new value for %s', selname));
% 
%             % Add the value to the choices
%             params.(selname).(cch) = cstr;
% 
%             % Fill in Ps
%             Ps.(selname) = cstr;
% 
%         elseif ischar(sel.(cch))
%             Ps.(selname) = sel.(cch);
% 
%         elseif isstruct(sel.(cch))
            assert(isstruct(sel.(cch)), 'Only struct choices are allowed if a selection is a struct!');
            for cf = fieldnames(sel.(cch))'
                Ps.(cf{1}) = sel.(cch).(cf{1});
            end

%         else
%             error('A selection''s fields must be structs or evaluable strings!');
%         end
        
    elseif ischar(sel)
        %% Enter a value
        cch = input_def(selname, 'default', sel);
        Ps.(selname) = cch;
        
    elseif iscell(sel)
        %% Choose among values
        cch = input_def(selname, 'choices', sel, 'default', sel{1});
        Ps.(selname) = cch;
    end
    
    choice.(selname) = cch;
    
    long_name  = fullstr('_', long_name,  sels{isel}, choice.(selname));
    short_name = fullstr('_', short_name, choice.(selname));
end
Ps.choice_ = choice;

switch S.name
    case 'ask'
        fprintf('\n-----\n');
        nam = input_def('Choose name', ...
            'choices',  {long_name, short_name, 'custom_'}, ...
            'vertical', 'always');
        if strcmp(nam, 'custom_')
            nam = input('Enter a custom name: ', 's');
        end
        
    case 'long'
        nam = long_name;
    case 'short'
        nam = short_name;
    case 'custom'
        nam = input('Enter a custom name: ', 's');
end

% Save changes if any.
if ~isempty(file) && ~isequal(params_orig, params)
    savejson('', params, file);
    fprintf('Changes in params are saved to %s\n', file);
end
end