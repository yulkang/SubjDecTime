function res = input_defNum(querry, varargin)
% input_defNum  Input with default values set to the previous input.
% 
% res = input_def(querry, 'opt1', opt1, ...)
% 
% querry: string. Used to identify the previous input.
%
% opt         default     explanation
% ----------------------------------------------------------------------
% 'str',      true ...    % True if the input is string
% 'fmt',      '' ...      % Format of the choice. Defaults to %s if str=true, to %d if str=false.
% 'choices',  {} ...      % Allowed choices. Leave empty to allow everything.
% 'default',  [] ...      % Default choice. Overrided by previous response if default_to_prev=true. Leave empty to force response.
% 'default_to_prev', true ... % Automatically set default choice to previous response.
% 'vertical', 'auto' ...
%
%
% input_def('_reset', varargin)
% : Clears saved information.
%
% See also: inputYN, inputYN_def, misc, PsyLib
%
% 2013 (c) Yul Kang. See help PsyLib for the license.

persistent querries p_res opt
if isempty(querries), querries = {}; end
if isempty(p_res),    p_res = {}; end
if isempty(opt),      opt = {}; end

% Special querries
switch querry
    case '_reset'
        querries = {};
        p_res = {};
        opt = {};
        
        res = [];
        return;
end

% Find if previously given
i_q   = find(strcmp(querry, querries));
new_q = isempty(i_q);

% If new,
if new_q
    % Add new querry
    i_q = length(querries) + 1;    
    
    % Add new opt
    S = varargin2S(varargin, { ...
        'str',      true ...    % True if the input is string
        'fmt',      '' ...      % Format of the choice. Defaults to %s if str=true, to %d if str=false.
        'choices',  {} ...      % Allowed choices. Leave empty to allow everything.
        'default',  [] ...      % Default choice. Overrided by previous response if default_to_prev=true. Leave empty to force response.
        'default_to_prev', true ... % Automatically set default choice to previous response.
        'vertical', 'auto' ...
        });
else
    % Update existing opt
    S = varargin2S(varargin, opt{i_q});
    
    % Use previous response as default
    if S.default_to_prev
        S.default = p_res{i_q};
    end
end
% Update saved opt
opt{i_q} = S;

% Initialize response
res = [];

% Format of the choices
if S.str && isempty(S.fmt)
    S.fmt = '%s';
elseif isempty(S.fmt)
    S.fmt = '%d';
end    

% Information about allowed choices
if iscell(S.choices)
    C_choices = S.choices;
else
    C_choices = num2cell(S.choices);
end
   
if strcmp(S.vertical, 'auto')
    if sum(cellfun(@length, csprintf(S.fmt, C_choices))) > 30
        S.vertical = 'always';
    else
        S.vertical = 'never';
    end
end

if ~iscell(S.choices), S.choices = num2cell(S.choices); end
        
switch S.vertical
    case 'always'
        s_choices = sprintf(['    ' S.fmt, '\n'], S.choices{:});
    case 'never'
        s_choices = sprintf([S.fmt, '|'], S.choices{:});
end

% Information about default choice
if isempty(S.default)
    s_default = '(No default)';
else
    s_default = sprintf(['Default=' S.fmt], S.default);
end

% Get response until appropriate
while true
    % Display information about allowed choices and default
    switch S.vertical
        case 'always'
            fprintf('%s - options:\n', querry);
            cfprintf(['%2d ' S.fmt '\n'], 1:length(S.choices), S.choices);
            fprintf('%s\n', s_default);
            fprintf('%s (press ENTER for default): ', querry);
        case 'never'
            info = [' (', ...
                s_choices ... % Information about allowed choices
                s_default ... % Information about default
                '- press ENTER for default): '];
            fprintf('%s', [querry, info]);
    end
    
    % If string response,
    if S.str
        res = input('', 's');
    else
        res = input('');
    end

    % If given empty response
    if isempty(res) && ~isempty(S.default)
        res = S.default;
    end
    
    % Check if the response is allowed
    if isempty(S.choices) || any(ismember(S.choices, res))
        break;
    elseif strcmp(S.vertical, 'always') && all(ismember(str2double(res), 1:length(S.choices)))
        res = str2double(res);
        
        if length(res) <= S.maxchoices
            % Allow number response if vertical
            res = S.choices{str2double(res)}; 
            break;            
        end        
    elseif ~isnan(str2double(res))
        ix_res = str2double(res);
        
        if (floor(ix_res) == ix_res) && ...
                (1 <= ix_res) && (ix_res <= length(S.choices))
            
            res = S.choices{ix_res};
            break;
        end 
    end
end

% Current response is the default for the next
if S.default_to_prev
    S.default = res;
end

% Update querries, p_res, and opt
querries{i_q} = querry; % Only updated when querry is new.
p_res{i_q}    = res;
opt{i_q}      = S;