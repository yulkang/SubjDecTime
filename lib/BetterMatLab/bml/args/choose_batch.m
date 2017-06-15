function [bat, ix, n] = choose_batch(bat, def, varargin)
% [bat, ix, n] = choose_batch({{arg1_1, arg1_2, ...}, {...}}, default_ix, options)
%
% DEFAULT_IX:
%   Numeric, string expression or a function handle that gets n (number of batches).
%   Give empty (default) or ':' to choose all on empty answer.
%   Give nan to enforce nonempty answer.
%
% Enter %STRING for escape strings. 
%
% OPTIONS:
% 'querry',             ''
% 'default_to_prev',    true
% 'nvpair',             true % Infer name-value pair format from R x 2 cell arrays.

persistent pbat pch

S = varargin2S(varargin, {
    'querry',           'Which batch to run'
    'default_to_prev',  true
    'nvpair',           true % Infer name-value pair format from R x 2 cell arrays.
    'maxchoice',        inf
    'minchoice',        0
    });

%% Enforce cell-in-cell for bat
if ~iscell(bat{1}) 
    % Enforce {{}; ...{}} format (Cell-in-cell vector)
    bat = mat2cell(bat, ones(1, size(bat, 1)));
end
n       = length(bat);

%% Enforce row cell vector, if it is {'name1', value1; 'name1', value2; ...} format.
if S.nvpair
    for ii = 1:n
        if size(bat{ii},2) == 2 && size(bat{ii},1) > 1
            bat{ii} = vVec(bat{ii}');
        end
    end
end

%% Show batch
for ii = 1:n
    fprintf('Batch %d: ', ii);
    fprintf(savejson('', bat{ii}));
end

%% Detect identical batch querried before, to define default
pbat_ix    = nan;
found_pbat = false;
for ii = 1:length(pbat)
    if isequal(pbat{ii}, bat)
        pbat_ix = ii;
        found_pbat = true;
        break;
    end
end
if isnan(pbat_ix)
    pbat = [pbat, {bat}];
    pch  = [pch,  {''}];
    pbat_ix = length(pbat);
end

%% Override default with previous choice if requested
if S.default_to_prev && found_pbat
    def = pch{pbat_ix};
elseif nargin < 2 || isempty(def)
    def = ':';
elseif isnumeric(def)
    def = ['[' num2str(def(:)') ']'];    
end 

%% Parse choice
ix = nan;
fprintf('Default (empty means all):\n%s\n', def);
while any(isnan(ix)) || (length(ix) < S.minchoice) || (length(ix) > S.maxchoice)
    ix_str = input(sprintf('%s (ENTER for default, '':'' for all): ', S.querry), 's');
    
    %% Parse ix_str
    if isempty(ix_str)
        if isempty(def) || strcmp(def, ':')
            ix = 1:n;
            ix_str = ':';
        else
            ix = eval(def); 
            ix_str = def;
        end
    elseif ischar(ix_str)
        if ix_str(1) == '%' % escape character, for choose_batches
            ix  = ix_str(2:end);
            bat = {};
            n   = 0;
            return;
        elseif strcmp(ix_str, ':')
            ix = 1:n;
        else
            try
                ix = eval(ix_str);
            catch err
                warning(err_msg(err));
                ix = nan;
            end
        end
    end
end
% Remember current choice
if S.default_to_prev && ~isempty(ix_str)
    pch{pbat_ix} = ix_str;
end

bat = bat(ix);
n   = length(bat);
end