classdef FitParams < matlab.mixin.Copyable
properties
    Param = FitParam; % FitParam object(s).
    Constr = FitConstraints; % constraint object
    
    % sub:
    % With FitParams objects as fields.
    % Field names become prefixes with two underscores: "subname__paramname"
    sub = struct; 
end
methods
function Params = FitParams(prefix, Param_args, Constr_args)
    if nargin == 0
        return;
    end
    if nargin >= 1
        Params.prefix = prefix;
    end
    if nargin >= 2
        Params.Param = FitParam(Param_args);
    end
    if nargin >= 3
        Params.Constr = FitConstraints(Constr_args);
    end
end
%% Parameters
function add_params(Params, args)
    % args: {{'name1', th0_1, lb1, ub1}, {...}, ...}
    Params.Param = Params.Param.add_params(args);
end
function remove_params(Params, names)
    Params.Param = Params.Param.remove_params(names);
end
function v = get_names(Params)
    v = Params.Param.get_names;
end
function Params = merge(Params, Params2)
    has_sub = ~isempty(fieldnames(Params.sub)) || ...
              ~isempty(fieldnames(Params2.sub));
    if has_sub
        warning('Recursive merging not supported yet!');
    end
    Params.Param  = Params.Param.merge(Params2.Param);
    Params.Constr = Params.Constr.merge(Params2.Constr);
end
function Params = merge_flat(Params, Params2)
    % When Params2 has flattened field names, as those from FitGrid.    
    has_sub = ~isempty(fieldnames(Params.sub)) || ...
              ~isempty(fieldnames(Params2.sub));
    if has_sub
        warning('Recursive merging of constraints not supported yet!');
    end
    
    for prop = {'th', 'th0', 'lb', 'ub'}
        Params.set_struct_all( ...
            Params2.get_struct_all(prop{1}), prop{1});
    end
    Params.Constr = Params.Constr.merge(Params2.Constr);
end
%% Subparameters
function add_sub(Params, name, sub_Params)
    % add_sub(Params, name, sub_Params)    
    assert(ischar(name));
    assert(isa(sub_Params, class(Params)));
    Params.sub.(name) = sub_Params;
end
function remove_sub(Params, name)
    % remove_sub(Params, name)
    Params.sub = rmfield(Params.sub, name);
end

%% Vector
function v = get_vec(Params, prop)
    if nargin < 2, prop = 'th'; end
    v = Params.Param.get_vec(prop);
end
function numels = set_vec(Params, v, prop)
    if nargin < 3, prop = 'th'; end
    if isempty(v)
        numels = [];
    else
        [~,numels] = Params.Param.set_vec(v, prop);
    end
end
function v = get_vec_all(Params, prop)
    if nargin < 2, prop = 'th'; end
    v = Params.get_vec(prop);
    
    subs = fieldnames(Params.sub)';
    for sub = subs
        v2 = Params.sub.(sub{1}).get_vec_all(prop);
        v = [v(:)', v2(:)'];
    end
end
function n_el_set = set_vec_all(Params, v, prop)
    if nargin < 3, prop = 'th'; end
    numels = Params.set_vec(v, prop);
    n_el_set = sum(numels);
    
    subs = fieldnames(Params.sub)';
    for sub = subs
        c_n_el_set = Params.set_vec_all(Params.sub.(sub{1}), v((n_el_set+1):end), prop);
        n_el_set   = n_el_set + c_n_el_set;
    end
end

%% Struct
function S = get_struct_all(Params, prop)
    if nargin < 2, prop = 'th'; end
    S = Params.get_struct(prop);
    subs = fieldnames(Params.sub)';
    for sub = subs
        S = copyFields(S, ...
            Params.(sub{1}).get_struct_prefixed([sub{1}, '__']));
    end
end
function set_struct_all(Params, S, prop)
    if nargin < 2, prop = 'th'; end
    Params.set_struct(S, prop);
    subs = fieldnames(Params.sub)';
    for sub = subs
        Params.(sub{1}).set_struct_prefixed(S, [sub{1}, '__']);
    end
end
function S = get_struct(Params, prop)
    if nargin < 2, prop = 'th'; end
    S = Params.Param.get_struct(prop);
end
function set_struct(Params, S, prop)
    if nargin < 3, prop = 'th'; end
    Params.Param.set_struct(S, prop);
end
function S = get_struct_prefixed(Params, prefix, prop)
    S = Params.get_struct(prop);
    fs = fieldnames(S);
    fs = cellfun(@(s) [prefix, s], fs, 'UniformOutput', false);
    S = cell2struct(struct2cell(S), fs);
end
function set_struct_prefixed(Params, S, prefix, prop)
    % Use only the fields with the given prefix
    
    fs = fieldnames(S)';
    incl = strcmpFirst(prefix, fs, 'mark_shorter_b_different', true);
    fs = fs(incl);
    len = length(prefix);
    fs = cellfun(@(s) s((len+1):end), fs, 'UniformOutput', false);
    S2 = struct;
    for f = fs
        S2.(f{1}) = S.([prefix, f{1}]);
    end
    Params.set_struct(S2, prop);
end

%% Constraint
function c = get_cond_cell(Params)
    c = Params.Constr.get_cond_cell();
end
function c = get_cond_cell_all(Params)
    c = Params.get_cond_cell();
    
    subs = fieldnames(Params.sub)';
    for sub = subs
        c = [c, Params.sub.(sub{1}).get_cond_cell([sub{1} '__'])]; %#ok<AGROW>
    end
end
function C = get_fmincon_cond(Params)
    th_names_all = fieldnames(Params.get_struct_all());
    C = fmincon_cond(th_names_all, Params.get_cond_cell_all());
end

%% Properties
function set_Param(Params, Param)
    assert(isa(Param, 'FitParam'));
    Params.Param = Param;
end
function set_Constr(Params, Constr)
    assert(isa(Constr, 'FitConstraint'));
    Params.Constr = Constr;
end

%% Copy
function Params2 = deep_copy(Params)
    Params2 = copy(Params);
    Params2.Param = copy(Params.Param);
    Params2.Constr = copy(Params.Constr);
    for sub = fieldnames(Params.sub)'
        Params2.sub.(sub{1}) = deep_copy(Params.sub.(sub{1}));
    end
end

%% Others
function disp(Params)
    builtin('disp', Params);
    disp(repmat('-', [1, 60]));
    disp(Params.Param);
    disp(Params.Constr);
    disp(repmat('-', [1, 60]));
    fprintf('SubParams:');
    subs = fieldnames(Params.sub)';
    if isempty(subs)
        fprintf(' (None)\n');
    else
        cfprintf(' %s', subs);
        fprintf('\n');
    end
end
end
methods (Static)
function Params = demo
    Params = FitParams;
end
end
end