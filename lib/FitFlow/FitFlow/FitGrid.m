classdef FitGrid < matlab.mixin.Copyable
% Make grids of th0, lb, and ub.
%
% 2015 (c) Yul Kang. yul dot kang dot on at gmail dot com.
properties
    ParamsUnits = {}; % Cell array of FitParams
end
methods
    function add_factors(Grid, factors)
        n = numel(factors);
        for ii = 1:n
            Grid.add_factor(factors{ii});
        end
    end
    function add_factor(Grid, spec)
        % spec: 
        % (1) {'varName', vector}
        % (2) {'varName1',       'varName2', ...
        %     {th0_1, lb1, ub1}, {th0_2, lb2, ub2}, ...}
        % (3) {FitParams1, FitParams2, ...}
        
        ParamsUnits1 = Grid.ParamsUnits;
        ParamsUnits2 = Grid.spec2ParamsUnits(spec);
        
        if isempty(ParamsUnits1)
            Grid.ParamsUnits = ParamsUnits2;
            return;
        end
        
        n1 = numel(ParamsUnits1);
        n2 = numel(ParamsUnits2);
        n12 = n1 * n2;
        ParamsUnits = cell(n12, 1);
        
        i12 = 0;
        for i1 = 1:n1
            for i2 = 1:n2
                i12 = i12 + 1;
                ParamsUnits{i12} = deep_copy( ...
                    ParamsUnits1{i1}.merge(ParamsUnits2{i2}));
            end
        end
        Grid.ParamsUnits = ParamsUnits;
    end
    function ParamsUnits = spec2ParamsUnits(Grid, spec)
        % spec: 
        % (1) {'varName', vector}
        % (2) {'varName1',       'varName2', ...
        %     {th0_1, lb1, ub1}, {th0_2, lb2, ub2}, ...}
        % (3) {FitParams1, FitParams2, ...} % ParamsUnits
        
        % If empty
        if isempty(spec)
            ParamsUnits = {};
            return;
        end
        
        % Otherwise
        assert(iscell(spec));
        
        % (3) ParamsUnits
        if isa(spec{1}, 'FitParams')
            ParamsUnits = spec;
            return;
        end
        % (1) spec_vector
        if size(spec,1) == 1
            spec = Grid.spec_vector2cell(spec);
        end
        % (2) spec_cell
        n_var  = size(spec, 2);
        n_comb = size(spec, 1) - 1;
        
        % Enforce ParamsUnits format
        ParamsUnits = cell(n_comb, 1);
        for i_comb = 1:n_comb
            Params = FitParams;
            for i_var = 1:n_var
                Params.add_params({[spec(1, i_var), spec{i_comb+1, i_var}]});
            end
            ParamsUnits{i_comb} = Params;
        end
    end
    function spec_c = spec_vector2cell(Grid, spec_v)
        assert(iscell(spec_v) ...
            && ischar(spec_v{1}) ...
            && isnumeric(spec_v{2}) && isvector(spec_v{2}));
        name = spec_v{1};
        vec  = spec_v{2};
        n    = length(vec) - 1;
        
        spec_c = cell(n + 1, 1);
        spec_c{1} = name;
        for ii = 1:n
            spec_c{ii+1} = {mean(vec([ii, ii+1])), vec(ii), vec(ii+1)};
        end
    end
    function v = isempty_(Grid)
        v = isempty(Grid.ParamsUnits);
    end
    function disp(Grid)
        builtin('disp', Grid);
        disp(repmat('-', [1, 60]));
        fprintf('Params:\n');
        disp(Grid.grid2ds);
%         for ii = 1:numel(Grid.ParamsUnits)
%             fprintf('Unit %d:\n', ii);
%             disp(Grid.ParamsUnits{ii}.Param);
%         end
        disp(repmat('-', [1, 60]));
        fprintf('Constr:\n');
        for ii = 1:numel(Grid.ParamsUnits)
            fprintf('Unit %d:', ii);
            Constr = Grid.ParamsUnits{ii}.Constr;
            if isempty_(Constr)
                fprintf(' (none)\n');
            else
                fprintf('\n');
                disp(Constr);
            end
        end
    end
    function ds = grid2ds(Grid)
        ds = dataset;
        n = numel(Grid.ParamsUnits);
        for ii = n:-1:1
            S.th0 = Grid.ParamsUnits{ii}.get_struct_recursive('th0');
            S.lb  = Grid.ParamsUnits{ii}.get_struct_recursive('lb');
            S.ub  = Grid.ParamsUnits{ii}.get_struct_recursive('ub');
            names = fieldnames(S.th0)';
            n_field = length(names);
            
            for jj = 1:n_field
                for kk = {'th0', 'lb', 'ub'}
                    ds.([names{jj}, '_' kk{1}]){ii,1} = S.(kk{1}).(names{jj});
                end
            end
        end
    end
end
methods (Static)
function [grid_spec, grid_opt] = grid_setup_static(spec, fit_opt, grid_opt, Fl)
    % grid_setup : wrapper for grid_setup_static
    %
    % grid_setup : grid gives specifications to run fits
    %
    % [grid_spec, grid_opt] = grid_setup(Fl, spec, fit_opt, grid_opt, [Fl])
    %
    % spec: 
    %   {} % Use default th0, th_lb, th_ub
    %
    %   {'var1', val1, ...} % Use all combinations
    %
    %   {'var1', 'var2', ..., 'varK'
    %     [x0_var1_1, lb_var1_1, ub_var1_1], [x0_var2_1, ...], ..., [x0_varK_1, ...]
    %     [x0_var1_2, lb_var1_2, ub_var1_2], ...
    %     ...
    %     [x0_var1_NCOMB, lb_var1_NCOMB, ub_var1_NCOMB], ...
    %   }} % Use given combinations. Allowed only when number of variables > 1.
    %      % Use {'var1', {[x0_1, lb_1, ub_1], ...}} in case of one variable.
    % 
    % val : vector: evaluate within [val(1), val(2)], with an initial value of (val(1)+val(2))/2, then [val(2), val(3)], ...
    %       scalar: equivalent to giving linspace(lb, ub, val)
    %       cell  : evaluate within [val{1}(2), val{1}(3)], with an initial value of val{1}(1), then [val{2}(1), val{2}(2)], ...
    %       cell with a scalar numeric: fix value to val{1}(1). Equivalent to repmat(val{1}(1), [1, 3]).
    %       give NaN to use the value of Fl.th0, th_lb, th_ub.
    %
    % grid_spec{k}: a struct with fields of th0, th_lb, th_ub, fit_opt.
    % grid_opt    : a struct.
    % .restrict   : restrict th_lb and th_ub around th0.
    % .parallel   : use parfor
    %
    % See also: grid_factorize

    if nargin < 2, fit_opt = {}; end
    if nargin < 3, grid_opt = {}; end
    grid_opt = varargin2S(grid_opt, {
        'restrict', true
        'parallel', false
        });

    % Parse spec
    if ~isempty(spec) && iscell(spec) && isstruct(spec{1})
        grid_spec = spec;
        ncomb = length(grid_spec);
    else
        % Parse spec - get spec_nam, nspec, comb, ncomb
        if size(spec,1) > 1 && ~ischar(spec{2,1})
            % First row contains variable names
            spec_nam   = spec(1,:);
            comb       = spec(2:end,:);
            ncomb      = size(comb, 1);
        else
            % Name-value pair
            spec_nam   = spec(1:2:end);
            spec_range = spec(2:2:end);
            nspec      = length(spec_nam);

            for ispec = 1:nspec
                spec_range{ispec} = parse_spec(spec_nam{ispec}, spec_range{ispec});
            end

            [comb, ncomb] = factorize(spec_range);
        end

        % Output
        grid_spec = cell(ncomb,1);
        for ii = 1:ncomb
            nspec = length(spec_nam);
            for jj = 1:nspec
                cspec = comb{ii,jj};

                nam = spec_nam{jj};
                if isnan(cspec(1)) % Clamp to th0
                    grid_spec{ii}.th0.(nam) = Fl.th0.(nam);
                else
                    grid_spec{ii}.th0.(nam) = cspec(1);
                end
                if length(cspec) == 1
                    % Fix to one value.
                    grid_spec{ii}.th_lb.(nam) = grid_spec{ii}.th0.(nam);
                    grid_spec{ii}.th_ub.(nam) = grid_spec{ii}.th0.(nam);
                else % Give NaN for lb and ub to preserve its original value
                    if length(cspec) >= 2 && ~isnan(cspec(2)), grid_spec{ii}.th_lb.(nam) = cspec(2); end
                    if length(cspec) >= 3 && ~isnan(cspec(3)), grid_spec{ii}.th_ub.(nam) = cspec(3); end
                end
            end
        end
    end
    if ncomb == 1, grid_opt.parallel = false; end

    % Modify fit_opt
    for ii = 1:ncomb
        if grid_opt.parallel
            if length(fit_opt) < 3
                fit_opt{3} = {};
            end
            fit_opt{3} = varargin2C(fit_opt{3}, {
                'PlotFcns', {} % Cannot plot if parallel
                });
        end
        grid_spec{ii}.fit_opt = fit_opt;
    end

    function cspec = parse_spec(nam, cspec)
        % Coerce into a cell form
        if isnumeric(cspec)
            if isscalar(cspec)
                cspec = parse_spec(nam, ...
                    linspace(Fl.th_lb.(nam), Fl.th_ub.(nam), cspec + 1));
            else
                vec   = cspec;
                nvec  = length(vec) - 1;
                cspec = cell(1, nvec);
                for kk = 1:nvec
                    cspec{kk} = [(vec(kk) + vec(kk+1))/2, vec(kk), vec(kk+1)];
                end
            end
        end
    end

    %             grid_spec = packStruct(comb, spec_nam, grid_opt, fit_opt); % Old format. Deprecated.
end

function [res, res_all] = grid_gather_static(res_all, grid_spec, grid_opt)
    % [res, res_all] = grid_gather_static(res_all, grid_spec, grid_opt)

    % Fetch output if a job
    nres = numel(res_all);
    finished = true(1,nres);
    for ii = 1:nres
        if ~isstruct(res_all{ii})
            if strcmp(res_all{ii}.State, 'finished')
                res_all{ii} = fetchOutputs(res_all{ii});
            else
                finished(ii) = false;
            end
        end
    end

    % Find minimum
    res      = struct;
    res_all  = res_all(finished);

    if any(finished)
        fval_min = inf;
        for ii = 1:nres
            % Find minimum
            if res_all{ii}.out.fval < fval_min
                res = res_all{ii};
                fval_min = res_all{ii}.out.fval;
            end
        end
        % Output
        res.grid = packStruct(res_all, grid_spec, grid_opt);
    else
        res = struct;
    end
end
function [Grid, ds] = demo
    Grid = FitGrid;
    disp('-----');
    disp('Add first factor.');
    Grid.add_factors({
    {'a', 1:2:5}
    });
    disp(Grid);
    disp('-----');
    disp('Add another factor.');
    Grid.add_factors({
    {'b', 10:20:50}
    });
    disp(Grid);
    disp('-----');
    disp('Add covarying factors. Also b overrides previous grid.');
    Grid.add_factors({{
        'b',            'c'
        {0,100,200}     {1,2,3}
        {200,400,800},  {3,6,9}
    }});
    disp(Grid);
    disp('Summarize into a dataset');
    ds = Grid.grid2ds;
    disp(ds);
end
end
end