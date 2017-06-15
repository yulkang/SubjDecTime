classdef FitConstraints < matlab.mixin.Copyable
% Wrapper for fmincon_cond
    
properties
    kind = ''; % 'A', 'Aeq', 'c', 'ceq'
    th_names = {};
    args = {};
    th_names_all = {};
end
properties (Dependent)
    cond_cell
end
methods
function Constr = FitConstraints(varargin)
    if nargin > 0
        if iscell(varargin{1})
            n = numel(varargin{1});
            for ii = n:-1:1
                Constr(ii) = FitConstraints(varargin{1}{ii}{:});
            end
        else
            Constr = set_cond_cell(Constr, varargin{:});
        end
    end
end
function Constr = add_constraint(Constr, kind, th_names, args)    
    if iscell(kind)
        % Only {{kind1, th_names1, args1}, {kind2, ...}} is allowed.
        n = numel(Constr);
        n2 = numel(kind);
        
        for ii = n2:-1:1
            Constr(n+ii) = FitConstraints(kind{ii}{:});
        end
        return;
    end
    
    if isempty_(Constr)
        assert(ismember(kind, {'A', 'Aeq', 'c', 'ceq'}));
        
        Constr.kind = kind;
        Constr.th_names = th_names;
        Constr.args = args;
    else
        % Append one
        % Since MATLAB gives the handle by value, 
        % output variable is necessary.
        assert(nargout > 0, 'Specify output argument to modify!');
        
        n = numel(Constr);
        Constr(n+1) = FitConstraints(kind, th_names, args);
    end
end
function Constr = merge(Constr, Constr2)
    if isempty_(Constr2), return; end
    % Merge constraints
    for i2 = 1:numel(Constr2)
        Constr = Constr.add_constraint( ...
            Constr2(i2).kind, Constr2(i2).th_names, Constr2(i2).args);
    end
    % Merge th_names_all
    Constr.set_th_names_all(union(Constr.get_th_names_all, ...
                                  Constr2.get_th_names_all, 'stable'));
end
function disp(Constr)
    view_constraints(Constr);
    fprintf('%s\n', repmat('-', [1, 59]));
    builtin('disp', Constr);
end
function view_constraints(Constr, c)
    if nargin < 2
        c = Constr.get_cond_cell;
    end
    n = numel(c);
    
    for ii = 1:n
        [kind, th_names] = deal(c{ii}{1:2});
        args = c{ii}(3:end);
        
        switch kind
            case 'A'
                fprintf('%10g %10s + %10g %10s <= %10g\n', ...
                    args{1}(1), th_names{1}, ...
                    args{1}(2), th_names{2}, ...
                    args{2}(1));
                
            case 'Aeq'
                fprintf('%10g %10s + %10g %10s == %10g\n', ...
                    args{1}(1), th_names{1}, ...
                    args{1}(2), th_names{2}, ...
                    args{2}(1));
                
            case 'c'
                fprintf('(%10s, %10s) %29s <= 0\n', ...
                    th_names{1}, ...
                    th_names{2}, ...
                    char(args{1}));
                
            case 'ceq'
                fprintf('(%10s, %10s) %29s == 0\n', ...
                    th_names{1}, ...
                    th_names{2}, ...
                    char(args{1}));
                
        end
    end
    
%     % Dataset approach doesn't show contents of cell.
%
%     ds = dataset;
%     ds.kind = cell(n,1);
%     ds.th_names = cell(n,2);
%     ds.args = cell(n,2);
%     
%     for ii = 1:n
%         ds.kind{ii,1} = Constr(ii).kind;
%         
%         th_names = Constr(ii).th_names;
%         ds.th_names(ii,1:numel(th_names)) = th_names(:)';
%         
%         args = Constr(ii).args;
%         ds.args(ii,1:numel(args)) = args(:)';
%     end
%     disp(ds);
end
function Constr = remove_th(Constr, th_names)
    % Remove contraints that involve th_name(s).
    % Since MATLAB gives the handle by value, 
    % Must receive the object array back as an output argument.    
    assert(nargout > 0, 'Specify output argument to modify!');
        
    n = numel(Constr);
    incl = true(size(Constr));
    for ii = 1:n
        incl(ii) = ~any(ismember(th_names, Constr(ii).th_names));
    end
    Constr = Constr(incl);
end
function Constr = remove_constraint(Constr, constr)
    % Remove the specified constraint, if any.
    %
    % Constr = remove_constraint(Constr, {kind, th_names, args})
    % Since MATLAB gives the handle by value, 
    % Must receive the object array back as an output argument.    
    assert(nargout > 0, 'Specify output argument to modify!');
    
    if iscell(constr{1}) 
        n = numel(constr);
        for ii = 1:n
            Constr = remove_constraint(Constr, constr{ii});
        end
        return;
    end
    
    constr = [constr(1:2), constr{3:end}];
    
    n = numel(Constr);
    c = Constr.get_cond_cell;
    incl = true(1, n);
    for ii = 1:n
        incl(ii) = ~isequaln(c{ii}, constr);
    end
    Constr = Constr(incl);
end
function C = get_fmincon_cond(Constr, th_names_all)
    % C = get_fmincon_cond(Constr, th_names_all)
    
    if nargin < 2
        if isempty(Constr(1).th_names_all)
            error(['Give th_names_all as an argument or as Constr(1).th_names_all, ' ...
                   'since the order is important!']);
%             warning('Using union of all th_names. Give explicitly to avoid errors!');
%             
%             th_names_all = {};
%             for ii = 1:numel(Constr)
%                 th_names_all = union(th_names_All, Constr.th_names(:), 'stable');
%             end
        else
            th_names_all = Constr(1).th_names_all;
        end
    end
    
    C = fmincon_cond(th_names_all, get_cond_cell(Constr));
end
function c = get.cond_cell(Constr)
    c = get_cond_cell(Constr);
end
function c = get_cond_cell(Constr, prefix)
    if nargin < 2, prefix = ''; end
    
    n = numel(Constr);
    c = cell(size(Constr));
    incl = true(size(Constr));
    for ii = 1:n
        th_names = Constr(ii).th_names;
        if isempty(th_names)
            % Ignore empty Constr.
            incl(ii) = false;
            continue; 
        end
        if ~isempty(prefix)
            th_names = cellfun(@(s) [prefix s], th_names, 'UniformOutput', false);
        end
        c{ii} = [{Constr(ii).kind, th_names}, Constr(ii).args(:)'];
    end
    c = c(incl);
end
function Constr = set_cond_cell(Constr, varargin)
    if ischar(varargin{1}) 
        % kind, th_names, args
        Constr = add_constraint(Constr, varargin{:});
    elseif iscell(varargin{1})
        if iscell(varargin{1}{1})
            % {{kind1, th_names1, args1}, {kind2, th_names2, args2}, ...}
            % Replace existing.
            n = numel(varargin{1});
            for ii = n:-1:1
                Constr(ii) = set_cond_cell(Constr(ii), varargin{1}{ii}{:});
            end
            Constr = Constr(1:n);
        else
            % {kind, th_names, args}
            Constr = set_cond_cell(Constr, varargin{1}{:});
        end
    else
        error('Unknown input!');
    end
end
function c = parse_cond_cell(~, varargin)
    % Enforce the form {{kind1, th_names1, args1}, {kind2, ...}}
    
    if ischar(varargin{1}) 
        % kind, th_names, args
        c = {varargin(1:3)};
    elseif iscell(varargin{1})
        if iscell(varargin{1}{1})
            % {{kind1, th_names1, args1}, {kind2, th_names2, args2}, ...}
            c = varargin;
        elseif ischar(varargin{1}{1})
            % {kind, th_names, args}
            c = {varargin};
        else
            error('Unknown input!');
        end
    else
        error('Unknown input!');
    end
end
function v = get_th_names_all(Constr)
    v = Constr(1).th_names_all;
end
function set_th_names_all(Constr, th_names_all)
    for ii = 1:numel(Constr)
        % Set all so that a subset of Constr() array can work consistently.
        % (fmincon_cond uses Constr(1)).
        Constr(ii).th_names_all = th_names_all;
    end
end
function add_th_names_all(Constr, th_names)
    set_th_names_all(Constr, union(Constr(1).th_names, th_names, 'stable'));
end
function remove_th_names_all(Constr, th_names)
    set_th_names_all(Constr, setdiff(Constr(1).th_names, th_names, 'stable'));
end
function th_names_attach(Constr, prefix, postfix)
    if nargin < 3, postfix = ''; end
    
    f = @(C) cellfun(@(s) [prefix, s, postfix], C, 'UniformOutput', false);
    for ii = 1:numel(Constr)
        Constr(ii).th_names     = f(Constr(ii).th_names);
        Constr(ii).th_names_all = f(Constr(ii).th_names_all);
    end
end
function th_names_strrep(Constr, src, dst)
    for ii = 1:numel(Constr)
        Constr(ii).th_names     = strrep(Constr(ii).th_names,     src, dst);
        Constr(ii).th_names_all = strrep(Constr(ii).th_names_all, src, dst);
    end
end
function v = isempty_(Constr)
    v = isscalar(Constr) && isempty(Constr.kind);
end
end
methods (Static)
function Constr = demo
    %% Construction
    % th1 <= th2
    Constr = FitConstraints('A', {'th1', 'th2'}, {[1, -1], 0});
    disp(Constr);
    
    %% Construction - batch
    % th1 <= th2
    Constr = FitConstraints({
        {'A', {'th1', 'th2'}, {[1, -1], 0}}
        {'A', {'th2', 'th3'}, {[1, -1], 0}}
        });
    disp(Constr);
    
    %% Adding
    % th2 <= th3
    Constr = Constr.add_constraint('Aeq', {'th3', 'th4'}, {[1, -1], 0});
    disp(Constr);
    
    %% Adding many
    % th3 == th4
    % th4 == th5
    % th1 *  th5 <= 2
    % th2 *  th3 == 5
    Constr = Constr.add_constraint({
        {'Aeq', {'th4', 'th5'}, {[1, -1], 0}}
        {'c',   {'th1', 'th5'}, {@(v) v(1) * v(2) - 2}}
        {'ceq', {'th2', 'th3'}, {@(v) v(1) * v(3) - 5}}
        });
    disp(Constr);
    
    %% Removing constraint(s)
    % Remove th3 == th4
    Constr = Constr.remove_constraint({
        {'Aeq', {'th3', 'th4'}, {[1, -1], 0}}
        });
    disp(Constr);

    %% Removing paramter(s)
    % Remove everything that involves th5
    Constr = Constr.remove_th({'th5'});
    disp(Constr);
   
    %% Add prefix and postfix to the parameter names
    Constr.th_names_attach('pre_', '_post');
    disp(Constr);
    
    %% Modify parameter names
    Constr.th_names_strrep('pre_', '');
    Constr.th_names_strrep('_post', '');
    disp(Constr);
    
    %% Get a constraint vector to feed to fmincon
    c = Constr.get_fmincon_cond({'th1', 'th2', 'th3', 'th4', 'th5'});
    celldisp(c);
end
end
end
