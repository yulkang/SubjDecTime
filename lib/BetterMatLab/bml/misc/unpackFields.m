function v = unpackFields(v, varargin)
% Flatten nested fields. Useful for dsfile, etc.
%
% v = unpackFields(v, varargin)
% 
% OPTIONS
% -------
% 'toDepth',          3
% 'fields',           nan
% 'excl',             true
% 'fieldsGlobal',     nan
% 'exclGlobal',       true
% 'prefix',           ''
% 'struct2cell',      true % Replace leftover structs, datasets, and tables with cell arrays.
% 'handle2',          'empty' % Replace handle objects with empty|struct|leavealone
% 'func2str',         true % Replace functions with str
%
% See also: unpackCopy, dsfile
%
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'toDepth',          5
    'fields',           nan
    'excl',             false
    'fieldsGlobal',     nan
    'exclGlobal',       false
    'prefix',           ''
    ... 'class2'  empty|struct|cellstruct=structcell|cell|leavealone.
    'dataset2',         'dsfields' % Replace datasets/tables.
    'handle2',          'struct' % Replace handle objects.
    'object2',          'struct' % Replace value objects.
    ... 'cell|struct2'  empty|struct|cellstruct=structcell|cell|leavealone. empty ensures safe saving.
    'cell2',            'leavealone' % Replace leftover cell arrays.
    'struct2',          'leavealone' % Replace leftover structs.
    'func2str',         true % Replace functions with str
    'self2empty',       true % In case of a handle object, replace self with empty, to avoid infinite recurrence.
    });

if isequal_nan(S.prefix, nan)
    S.prefix = inputname(1);
end

%% Unpack
for depth = 1:S.toDepth
    fs = fieldnames(v)';
    nf = length(fs);
    
%     disp(fs(:)); % DEBUG
    
    for ii = 1:nf
        f  = fs{ii};
        
%         % DEBUG
%         if strcmp(f, 'res_history')
%             keyboard;
%         end
        
        % Filter fields
        if depth == 1 && ~isequal_nan(S.fields, nan)
            if S.excl && ismember(f, S.fields)
                v = rmfield(v, f);
                continue;
            elseif ~S.excl && ~ismember(f, S.fields)
                v = rmfield(v, f);
                continue;
            end
        end
        
        % Skip fields referring to self
        if S.self2empty && isequal(v.(f), v)
            v.(f) = [];
            continue;
        end
        
        % Replace non-struct container objects
        v.(f) = replaces(v.(f), S);
        
        % Add prefix if any
        if depth == 1 && ~isempty(S.prefix)
            v.(str_con(S.prefix, f)) = v.(f);
            v = rmfield(v, f);
            
            f = str_con(S.prefix, f);
        end
        
        % Replace S.f1 with S.f1_f11, S.f1_f12, and so on.
        if isstruct(v.(f))
%             if strcmp(f, 'A_A'), keyboard; end % DEBUG
            
            v = unpackCopy(v, v.(f), f, 'fields', S.fieldsGlobal, 'excl', S.exclGlobal);
            v = rmfield(v, f);
        end
    end
end

%% replace fields
fs = fieldnames(v)';
nf = length(fs);
for ii = 1:nf
    f = fs{ii};
    
    % Replace non-struct container objects
    v.(f) = replaces(v.(f), S);
        
    % Replace cell arrays
    v.(f) = replace2(v.(f), 'cell', S.cell2);
    
    % Replace structs
    v.(f) = replace2(v.(f), 'struct', S.struct2);

    % func2str
    if S.func2str
        if isa(v.(f), 'function_handle')
            v.(f) = func2str(v.(f));
        elseif iscell(v.(f))
            try
                v.(f) = func2str_C(v.(f));
            catch
            end
        end
    end
end
end

function h = replaces(h, S)
% Replace handle objects
h = replace2(h, 'handle', S.handle2);

% Replace datasets
h = replace2(h, 'dataset', S.dataset2);

% Replace tables
h = replace2(h, 'table', S.dataset2);

% Replace value objects
h = replace2(h, 'object', S.object2);
end

function h = replace2(h, cl, op)
if strcmp(cl, 'object') % value class
    if ~(isobject(h) && ~isa(h, 'handle')), return; end
elseif ~isa(h, cl)
    return;
end

switch op
    case 'empty'
        h = [];
    case 'struct'
        h = struct(h);
    case {'cellstruct', 'structcell'}
        h = {struct(h)};
    case 'cell'
        h = {h};
    case 'dsfields'
        h = copyFields(struct('Properties', h.Properties), ds2struct(h));
end
end
