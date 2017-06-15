classdef PsyExperiment < PsyDeepCopy
    % PSYEXPERIMENT : organize, retrieve, and record trials.
    %
    % Naming
    % ======
    % Expr  : a PsyExperiment object
    % dsRun : a Run
    % dsTr  : a Tr
    %
    % Flow of info, for both Tr and Run:
    % ==================================
    % factor -> cond
    % cond, params, distrib -> plan -> obs
    %
    % PsyExperiment Methods:
    % ==================================
    % Main interface
    % ----------------------------------
    % PsyExperiment      - Constructor.
    % add_paradigm  - Add factor (& cond), params, and distrib for a paradigm.
    % set_cond_freq - Fine tune frequency that condition goes to plan.
    % cond2plan     - Put conditions into plan.
    % new_Tr        - New trial.
    % new_Run       - New run.
    % rec           - Record response.
    % 
    % Filtering
    % ----------------------------------
    % filt          - General filtering function
    % n_filt        - 
    % filt_obTr     - 
    % n_filt_obTr   - 
    % filt_run      - 
    % filt_ds       -
    % last_obs      -
    %
    % PsyExperiment Properties:
    % ==================================
    % obTr          - 
    % sTr           -
    % obRun         -
    % sRun          -
    % remTr         -
    % remRun        -
    
    properties
        %% ===== Properties =====
        %% Core variables
        % factor.(kind).(parad):
        % A struct containing fields
        % that are cell or numerical vectors of elements,
        % combined in a factorial fashion into parad.
        factor = struct('Tr', struct, 'Run', struct);
        
        % cond.(kind).(parad):
        % A dataset containing the combination of factors as columns
        % as well as the relative proportion of the combinations in cond_freq.
        %
        % factor.(parad) can be an inaccurate description of the task
        % because the joint distribution can be modified
        % and saved by set_factors, such as omitting some
        % combination. Those distributions are, in general, cannot be
        % coded in a simpler form than cond, which is a full dataset
        % with a row (thus cond_freq) for each combination.
        cond    = struct('Tr', struct, 'Run', struct);
        
        % params.(kind).(parad): constant throughout repetitions
        params  = struct('Tr', struct, 'Run', struct);
        
        %% distrib-related
        % distrib.(kind).(parad).(column):
        % A PsyDistrib object containing a distribution to draw column from.
        distrib = struct('Tr', struct, 'Run', struct);
        
        distrib_keys = struct('Tr', struct, 'Run', struct);
        
        % distrib_unique_by_factor.(kind).(parad).(column) = {'col1', 'col2', ...}:
        % A cell vector containing column names to enforce unique values of column by.
        distrib_unique_by_factor = struct('Tr', struct, 'Run', struct);
        
        % distrib_unique_by_index.(kind).(parad).(column) = 'index_name'
        distrib_unique_by_index  = struct('Tr', struct, 'Run', struct);
        
        % distrib_Map.(kind).(parad).(column):
        % A PsyMap (legacy) or PsyMap2 object that gets columns listed in distrib_unique_by
        % and returns the value drawn from distrib.
        distrib_Map = struct('Tr', struct, 'Run', struct);
    
        %% Plan & Observation
        % plan.(kind): 
        % A dataset with a set of conditions that will be presented until 
        % finished without being cancelled (cancelled = true)
        % or issuing errors such as timing violation (succT = false).
        plan    = struct('Tr', dataset, 'Run', dataset);

        % obs.(kind): 
        % A dataset with a set of conditions that are actually presented,
        % in the order of presentation. In case succT = false happens,
        % obs will contain duplicate rows of plan, but with different
        % measurements of the subject's performance.
        obs     = struct('Tr', dataset, 'Run', dataset);
        
        % col_added_at.(kind).(col):
        % A scalar integer indicating i_all.(kind) where the column was
        % first recorded.
        col_added_at = struct('Tr', struct, 'Run', struct);
        
        %% Indices
        % Kinds are in the order of increasing size (Tr < Run).
        kinds = {'Tr', 'Run'};
        i     = struct('Tr', 0, 'Run', 0);
        i_all = struct('Tr', 0, 'Run', 0);
        
        %% c_parad
        % If there's any observation, i.e., i_all.(kind) > 0, 
        % the last observation's parad.
        % If there's none, parad that is last added/modified.
        % Managed by parse_parad().
        c_parad = struct('Tr', '', 'Run', '');
        
        %% sets
        % A set is a struct of structs (subsets) with related parameters.
        % In P, sets override Tr.G, but is overridden by Run.
        sets = struct;
        
        % c_subset is a struct of the name of the active subset within each set.
        % Leave the name blank to inactivate the set.
        % For example, if 
        % c_subset = struct('parad_time', 'RT', 'mouse', '', 'monitor', 'MBA')
        % then Tr.G is overwritten sequentially in determining P by
        % sets.parad_time.RT and sets.monitor.MBA.
        %
        % The order of fields in c_sets determines the order of overwriting.
        c_subset = struct;
        
        %% Misc
        n_obs_margin = struct('Tr', 500, 'Run',50);
        r = RandStream('mt19937ar', 'Seed', 'shuffle');
        seed_alg = 'random'; % 'index'|'random' % 'index' may introduce correlation between color & motion
        verbose = 1; % 0: Silent. 1: Normal mode. 2: Debugging mode.
        
        %% Minimal instances
        % MIN_.PLAN/OBS/COND:
        % dataset with required columns for plan and obs.
        %
        % MIN_.PARAMS : minimal set of parameters attached to every paradigm.
        %
        % .auto_lengthen_plan
        % : If >0, evokes .lengthen_plan() from .new_obs().
        %
        % .auto_attach_seeds
        %     .filt_fun
        %     .unique_factor
        %     .unique_index
        %     .unique_index_max
        %     .seed_cols
        % : If seed_cols is nonempty, evokes .attach_seed_to_plan() from .cond2plan().
        %   Use a struct array to use multiple combinations of
        %   filt_fun, unique_factor, unique_index, and seed_cols.
        %
        % See also: min_, add_min_, add_distrib
        min_ = struct(...
            'plan',   struct('Tr', struct, 'Run', struct), ...
            'obs',    struct('Tr', struct, 'Run', struct), ...
            'cond',   struct('Tr', struct, 'Run', struct), ...
            'params', struct('Tr', struct, 'Run', struct));
        
        %% Legacy
        rep
        param
        
        repTr
        obsTr
        
        cTr
        cRun
        cTrial        
        
        % General parameter that applies throughout the experiment.
        % Replaced by Tr.c_params_Tr.
        G = struct; 
        
        to_save_ = false; % Save only when explicitly required
    end

    properties (Dependent)
        c_factor_Tr
        c_cond_Tr
        c_params_Tr
        c_distrib_Tr
        
        c_factor_Run
        c_cond_Run
        c_params_Run
        c_distrib_Run
        
        % Sets
        c_sets
        set_names
        
        all_parads_Tr
        all_parads_Run
        
        last_Tr % last observed Tr.
        last_Run
        
        obTr % observed trials up to cTr.
        obRun
        
        sTr  % succeded trials
        sRun
        
        remTr % remaining trials from repTr. Those that not marked succT=true yet.
        remRun
        
        % P: Struct of inherited parameters. Read-only.
        % Precedence: last_Tr > c_params_Tr > last_Run > c_params_Run > G
        P 
        
        planned_cols_Tr  % columns of plan.Tr
        planned_cols_Run % columns of plan.Run
        
        % Legacy
        G_legacy
    end
    
    methods
        %% ===== Methods =====
        %% ----- Main flow -----
        function Expr = PsyExperiment
            % PsyDeepCopy interface
            Expr.tag = 'Trial';
            Expr.deepCpNames = {'r'};
            
            % Minimal columns
            Expr.add_min_('cond', 'all', ...
                'repID',    0);
            
            Expr.add_min_('plan', 'all', ...
                'parad',    {''}, ...
                'repID',    0, ...
                'condID',   0, ...
                'succT',    false, ...
                'aborted',  false, ...
                'cancelled',false, ...
                'attempted',false);
            
            Expr.add_min_('params', 'all', ...
                'auto_lengthen_plan', 1, ...
                'auto_attach_seeds', struct( ... 
                    'filt_fun', [], ...
                    'unique_factor', {{}}, ...
                    'unique_index',  {{}}, ...
                    'unique_index_max', {[]}, ...
                    'seed_cols', {{}}) ...
                );
            
            % Expr is meant to be saved all, including RandStream
            Expr.save_handle_ = true;
        end
        
        function cond = add_paradigm(Expr, kind, parad, factor_args, params_args, distrib_args)
            % ADD_PARADIGM : Adds factor, derive cond from it.
            %
            % factor_args and params_args can be name-value pairs, struct, or N x 2 cell array.
            %
            % distrib_args = {{distrib1}, {distrib2}, ...}
            %
            % distrib: {col_name, distrib_opt, unique_by_factor, unique_by_index, unique_index_max}
            %
            %     col_name: Column to store the drawn values.
            %     distrib_opt: A PsyDistrib object or a cell array of arguments that
            %                  feed PsyDistrib constructor.
            %     unique_by_factor: A cell vector of factor names.
            %     unique_by_index : A cell vector of index column names.
            %     unique_index_max: Maximum index for unique_by_index.
            %
            % See also: add_factor, factor2cond, add_params, add_distrib
            
            parad = Expr.parse_parad(kind, parad);
            
            if ~exist('factor_args', 'var'), factor_args = {};   else factor_args = arg2C(factor_args); end
            if ~exist('params_args', 'var'), params_args = {};   else params_args = arg2C(params_args); end
            if ~exist('distrib_args', 'var'), distrib_args = {}; end
            
            if isempty(factor_args) && isempty(distrib_args)
                error('At least one factor or one distrib is necessary!');
            end
            
            Expr.add_factor( kind, parad, factor_args{:});
            if nargout > 0
                cond = Expr.factor2cond(kind, parad);
            else
                Expr.factor2cond(kind, parad);
            end
            
            Expr.add_params(  kind, parad, params_args{:});
            
            for ii = 1:length(distrib_args)
                Expr.add_distrib( kind, parad, distrib_args{ii}{:});
            end
        end
        
        function set_cond_freq(Expr, kind, parad, filt, c_cond_freq, from)
            % SET_COND_FREQ : Refine relative frequency of conditions
            %
            % set_cond_freq(Expr, kind, parad, filt, c_cond_freq, [from = 'user'])
            %
            % See also: cond2plan
            
            if ~exist('from', 'var'), from = 'user'; end
            
            parad = Expr.parse_parad(kind, parad);
            
            % Make sure cond.(kind).(parad) exists.
            if ~isfield(Expr.cond.(kind), parad)
                if strcmp(from, 'user') || ~strcmp(from, 'factor2cond')
                    error('cond.%s.%s doesn''t exist!', kind, parad);
                end
            end
            
            % Set up filter
            if ~exist('filt', 'var') || isempty(filt)
                tf = true(length(Expr.cond.(kind).(parad)), 1);
            elseif isa(filt, 'function_handle')
                tf = filt(Expr.cond.(kind).(parad));
            else
                tf = filt;
            end
            
            % Assign freq
            Expr.cond.(kind).(parad).freq(tf,1) = c_cond_freq;
        end
        
        function cond2plan(Expr, kind, parad, n, n_unit, filt)
            % COND2PLAN : Take conditions into plan, in proportion to freq.
            %
            % cond2plan(Expr, kind, parad, n, n_unit)
            %
            % n_unit        : 'plan_per_cond' | 'min_total_plan'
            %
            % See also: set_cond_freq, set_cond
            
            parad = Expr.parse_parad(kind, parad);
            
            if ~exist('n', 'var')
                n = 1;
            end
            if ~exist('n_unit', 'var')
                n_unit = 'plan_per_cond';
            end    
            if ~exist('filt', 'var') || isempty(filt)
                filt = [];
            elseif ~isa(filt, 'function_handle')
                error('filt, when specified, should be a function handle!');
            end
            
            % Current condition
            c_cond = Expr.cond.(kind).(parad);
            
            % Filter if specified.
            if ~isempty(filt)
                c_cond = c_cond(filt(c_cond), :);
            end
            
            % Calculate total number of rows to be added to the plan
            try
                tot_freq = sum(c_cond.freq);
            catch
                error('cond.%s.%s.freq doesn''t exist!', kind, parad);
            end
            
            % Calculate n_plan_per_cond
            switch n_unit
                case 'min_total_plan'
                    n_plan_per_cond = ceil(n / tot_freq);
                case 'plan_per_cond'
                    n_plan_per_cond = n;
                otherwise
                    error('Unrecognized n_unit!');
            end
            
            % current length of the plan
            c_max_cond_ID = length(Expr.plan.(kind));
            st_max_cond_ID = c_max_cond_ID;
            
            % future length of the plan
            n_plan_will_be = c_max_cond_ID + tot_freq * n_plan_per_cond;
            
            % preallocate memory
            if n_plan_will_be == 0, return; end % No plan to add
            Expr.plan.(kind).succT(n_plan_will_be,1) = false; 
            
            % legacy - maximum existing repID for the current paradigm & filter
            if ~isfield(c_cond, 'repID')
                OLD_REPID = true;
                
                if isempty(filt)
                    p_max_repID = max(Expr.plan.(kind).repID( ...
                        strcmp(parad, Expr.plan.(kind).parad),1));
                else
                    p_max_repID = max(Expr.plan.(kind).repID( ...
                        strcmp(parad, Expr.plan.(kind).parad) ...
                      & filt(Expr.plan.(kind)), 1));
                end

                if isempty(p_max_repID)
                    p_max_repID = 0;
                end
            end
            
            % add according to the given frequency
            n_cond    = length(c_cond);
            n_new_row = round(n_plan_per_cond * sum(c_cond.freq));
            new_row   = zeros(n_new_row, 1);
            p_add     = 1;
            
            % current repID
            if max(c_cond.freq) < 1 && (abs(sum(c_cond.freq) - 1) < 0.01)
                
                to_add = false(n_cond, 1);
                to_add(randsample(n_cond, n_new_row, true, c_cond.freq)) = true;
                
                add_cond2plan(to_add, 1);
                
            else
                for i_freq  = 1:(max(c_cond.freq)*n_plan_per_cond)
                    to_add  = c_cond.freq * n_plan_per_cond >= i_freq;

                    add_cond2plan(to_add, i_freq);
                end
            end
            new_row(p_add:end) = [];
            
            % required columns
            cond_ID_all = ((st_max_cond_ID+1) : c_max_cond_ID)';
            Expr.plan.(kind) = ds_set(Expr.plan.(kind), cond_ID_all, ...
                'succT', false, 'cancelled', false);
            
            % attach columns from distrib
            try
                c_fields = fieldnames(Expr.distrib.(kind).(parad))';
            catch
                c_fields = {};
            end
            
            if ~isempty(c_fields)
                for col = c_fields
                    % Retrieve from Map
                    key     = double(Expr.plan.(kind)...
                                        (new_row, ...
                                         Expr.distrib_keys.(kind).(parad).(col{1})));
                    val     = Expr.distrib_Map.(kind).(parad).(col{1})(key);
                    
                    % Assign new keys if val is unassigned
                    new_key = val==0;
                    
                    val(new_key) = unique_rand_by(Expr.r, key(new_key,:), ...
                        Expr.distrib.(kind).(parad).(col{1}));
                    
                    Expr.distrib_Map.(kind).(parad).(col{1})(key(new_key,:)) = val(new_key);
                    
                    % Assign val
                    Expr.plan.(kind).(col{1})(new_row,1) = full(val); % Now not sparse
                end
            end
            
            % update cond. Especially, copy increased repID
            if isempty(filt)
                Expr.cond.(kind).(parad) = c_cond;
            else
                Expr.cond.(kind).(parad) = ...
                    ds_set( Expr.cond.(kind).(parad), filt, c_cond);
            end
            
            % parad interface
            Expr.update_c_parad(kind, parad, 'cond2plan');
            
            % Add cond to plan
            function add_cond2plan(to_add, i_freq)
                p_max_cond_ID = c_max_cond_ID;
                c_max_cond_ID = c_max_cond_ID + nnz(to_add);
                cond_ID       = ((p_max_cond_ID + 1) : c_max_cond_ID)';

                c_add = p_add + nnz(to_add) - 1;
                new_row(p_add:c_add) = cond_ID;
                p_add = c_add + 1;

                Expr.plan.(kind) = ds_set(Expr.plan.(kind), cond_ID, c_cond(to_add, :));

                if OLD_REPID
                    c_repID = i_freq + p_max_repID; % legacy. Cannot vary repID within parad, or handle filt in cond2plan.
                else
                    c_cond.repID(to_add) = c_cond.repID(to_add) + 1;
                    c_repID = c_cond.repID(to_add);
                end
                
                Expr.plan.(kind) = ds_set(Expr.plan.(kind), cond_ID, ...
                    'parad', {parad}, ...
                    'repID', c_repID, ...
                    'condID', cond_ID);
            end
        end
        
        function cancel_plan(Expr, kind, fun)
            % Cancel the remaining plans.
            %
            % cancel_plan(Expr, kind, [fun=[]])
            
            if ~exist('fun', 'var')
                ix = Expr.filt_rem_plan(kind);
            else
                ix = Expr.filt_rem_plan(kind, fun);
            end
            
            Expr.plan.(kind).cancelled(ix,1) = true;
        end
        
        function [ix, c_plan] = next_ix_plan(Expr, kind, filt)
            % [ix, c_plan] = next_ix_plan(Expr, kind, filt)
            
            if ~exist('filt', 'var') || isempty(filt)
                ix = find(Expr.filt_rem_plan(kind));
            elseif islogical(filt)
                ix = find(Expr.filt_rem_plan(kind) & filt(:));
            elseif isnumeric(filt)
                ix = find(intersect_tf_num(Expr.filt_rem_plan(kind), filt));
            elseif isa(filt, 'function_handle')
                ix = find(Expr.filt_rem_plan(kind, filt));
            else
                error('filt should be empty, logical, numeric, or a function handle!');
            end
            
            if ~isempty(ix)
                try
                    ix = ix(randi(Expr.r, length(ix)));
                catch
                    ix = ix(randi(length(ix)));
                end
                
                if nargout >= 2
                    c_plan = Expr.plan.(kind)(ix,:);
                end
            else
                c_plan = [];
            end
        end
        
        function auto_lengthen_plan(Expr, kind, filt, parad, filt_cond)
            % AUTO_LENGTHEN_PLAN : lengthen plan with parad if none left with filt.
            %
            % auto_lengthen_plan(Expr, kind, [filt, parad, filt_cond])
            %
            % Leave parad unspecified or empty not to lengthen plan.
            %
            % See also: new_obs, lengthen_plan
            
            if ~exist('filt', 'var'), filt = []; end
            if ~exist('filt_cond', 'var'), filt_cond = []; end
            
            if ~any(filt_rem_plan(Expr, kind, filt)) && ~isempty(parad)
                % If no plan is available, lengthen plan.
                % When there is some plans (albeit unavailable),
                % cond and params should exist too, since they're added together
                % in add_paradigm.
                c_auto_lengthen = Expr.params.(kind).(Expr.c_parad.(kind)).auto_lengthen_plan;
                if c_auto_lengthen
                    if Expr.verbose
                        fprintf('PsyExperiment: Auto-lengthened plan: %dx\n', c_auto_lengthen);
                    end
                    Expr.update_c_parad(kind, parad, 'force');
                    
                    if isa(filt_cond, 'function_handle')
                        Expr.lengthen_plan(kind, c_auto_lengthen, 'plan_per_cond', filt_cond); % filter cond
                    else
                        Expr.lengthen_plan(kind, c_auto_lengthen, 'plan_per_cond');
                    end                    
                end
            end
        end
        
        function [i_kind, i_kind_all] = inc_ix(Expr, kind)
            % INC_IX  Increase index of kind and reset the index of smaller kinds.
            % For example, increasing Run index increases i.Run and i_all.Run,
            % and sets i.Tr to zero.
            %
            % [i_kind, i_kind_all] = inc_ix(Expr, kind)
            
            % Increase index
            i_kind = Expr.i.(kind) + 1;
            i_kind_all = Expr.i_all.(kind) + 1;
            
            % Set zero the smaller indices.
            ix_kind = find(strcmp(kind, Expr.kinds));
            for ii_kind = 1:(ix_kind-1)
                Expr.i.(Expr.kinds{ii_kind}) = 0;
            end
            
            Expr.i.(kind) = i_kind;
            Expr.i_all.(kind) = i_kind_all;
        end
        
        function obs = new_obs(Expr, kind, filt, filt_cond)
            % obs = new_obs(Expr, kind, [filt, filt_cond])
            %
            % Consider extending cond2plan or next_ix_plan in subclasses.
            %
            % See also: new_Tr, new_Run, lengthen_obs, auto_lengthen_plan
            
            if ~exist('filt', 'var'), filt = []; end
            if ~exist('filt_cond', 'var'), filt_cond = filt; end
            
            % Lengthen obs if necessary
            if Expr.i_all.(kind) >= length(Expr.obs.(kind))
                Expr.lengthen_obs(kind);
            end
            
            % Get next plan
            if isempty(Expr.cond.(kind)) || isequal(Expr.cond.(kind), struct)
                % If there's no cond, maybe the intention is to go without a plan.
                ix_plan = []; 
                c_plan = copyFields(dataset, Expr.min_.plan);
            else
                % Otherwise, choose a plan among remaining ones.
                % This should be done before increasing index, so that
                % last_obs can return the last recorded observation,
                % not the new, blank observation.
                parad = Expr.c_parad.(kind);
                
                % Auto-lengthen if necessary
                auto_lengthen_plan(Expr, kind, filt, parad, filt_cond);
                
                % Choose among remaining plans.
                [ix_plan, c_plan] = Expr.next_ix_plan(kind, filt);
                
                % If plan is still lacking somehow, should issue an error.
                if isempty(ix_plan)
                    error('No plan is avaiable!');
                end
            end
            
            inc_ix(Expr, kind);
            
            % Short alias for current kind's index
            c_i_all = Expr.i_all.(kind);
            
            % Copy plan, if any.
            if ~isempty(ix_plan)
                Expr.obs.(kind) = ds_set(Expr.obs.(kind), c_i_all, c_plan);
                
                % Mark attempted.
                Expr.mark(kind, 'attempted', true);
            end
            
            % Log current indices
            for c_kind = Expr.kinds
                Expr.obs.(kind).(['i_'     c_kind{1}])(c_i_all,1) = Expr.i.(    c_kind{1});
                Expr.obs.(kind).(['i_all_' c_kind{1}])(c_i_all,1) = Expr.i_all.(c_kind{1});
            end
            
            % Log condID for all kinds: condID_Tr, Run, etc.
            % Call new_Tr AFTER new_Run to get a correct condID_Run.
            for c_kind = Expr.kinds
                c_last_obs = Expr.last_obs(c_kind{1});
                if isempty(c_last_obs)
                    c_condID = 0;
                else
                    c_condID = c_last_obs.condID;
                end
                
                if strcmp(c_kind, kind)
                    Expr.obs.(kind).(['condID_' c_kind{1}])(c_i_all,1) = c_condID;
                else
                    c_last_obs = Expr.last_obs(c_kind{1});
                    
                    if ~isempty(c_last_obs)
                        Expr.obs.(kind).(['condID_' c_kind{1}])(c_i_all,1) = ...
                            c_last_obs.condID;
                    else
                        Expr.obs.(kind).(['condID_' c_kind{1}])(c_i_all,1) = 0;
                    end
                end
            end
            
            Expr.update_c_parad(kind, Expr.obs.(kind).parad{c_i_all,1}, 'new_obs');
            
            % Return output
            if nargout > 0
                obs = Expr.obs.(kind)(c_i_all,:);
            end
        end
        
        function varargout = new_Tr(Expr, varargin)
            % The same as new_obs(Expr, 'Tr', ...)
            % 
            % Do new_Tr AFTER new_Run to get a correct condID_Run.
            %
            % See also: new_obs
            
            [varargout{1:nargout}] = Expr.new_obs('Tr', varargin{:});
            
            sync_c_subset(Expr);
        end
        
        function varargout = new_Run(Expr, varargin)
            % The same as new_obs(Expr, 'Tr', ...)
            % 
            % Do new_Tr AFTER new_Run to get a correct condID_Run.
            %
            % See also: new_obs
            
            [varargout{1:nargout}] = Expr.new_obs('Run', varargin{:});
        end
        
        function S = rec(Expr, kind, succT, varargin)
            % REC: Record responses.
            %
            % S = rec(Expr, kind, succT, varargin)
            %
            % To supply strings or other variables with variable length,
            % supply a cell, e.g., {'string'}.
            
            % Record variables.
            set_last_obs(Expr, kind, varargin{:});
            
            % Mark success/fail.
            if ~isempty(succT)
                mark(Expr, kind, 'succT', succT);
            end
            
            % Return the record
            if nargout > 0
                S = copyFields(struct, Expr.last_Tr);
            end
        end
        
        function S = rec_P(Expr, kind, P, P_orig, fields)
            % S = rec_P(Expr, kind, P, P_orig, fields)
            %
            % Record fields that are changed from P_orig to P.
            %
            % fields: Fields to add even if unchanged.
            %         Unplanned fields are always added.
            
            if nargin < 5
                fields = {};
            end
            fields = union(fields, ...
                        setdiff(fieldnames(P), ...
                            union( ...
                                Expr.planned_cols_Tr, ...
                                Expr.planned_cols_Run) ...
                            ) ...
                        );
            
            if nargin < 4
                P_orig = Expr.P;
            end
            
            S = neq_fields(P, P_orig, fields);
            
            if isfield(S, 'succT')
                rec(Expr, kind, S.succT, S);
            else
                rec(Expr, kind, [], S);
            end
        end
        
        %% resume_Run: suspended for now. Too complicated to implement.
%         function varargout = resume_Run(Expr, filt)
%             % Same as new_Run, but choose the latest failed run first, if any.
%             
%             if ~exist('filt', 'var'), filt = []; end
%             
%             if Expr.i_all.Run > 0
%                 obRun_failed = Expr.obRun.condID(find(~Expr.obRun.succT, 1, 'last'));
%             else
%                 obRun_failed = [];
%             end
%             
%             if isempty(obRun_failed)
%                 [varargout{1:nargout}] = Expr.new_obs('Run', filt);
%             else
%                 [varargout{1:nargout}] = Expr.new_obs('Run', obRun_failed);
%             end
%         end
        
        %% ----- Finer flow -----
        function c_factor = add_factor(Expr, kind, parad, varargin)
            % ADD_FACTOR: add factors that are combined in a factorial fashion.
            %
            % c_factor = add_factor(Expr, kind, parad, 'var_name1', value1, ...)
            % c_factor = add_factor(Expr, kind, parad, struct)
            %
            % kind: 'Tr' or 'Run'
            %
            % See also: add_paradigm
            
            parad = Expr.parse_parad(kind, parad);
            
            Expr.factor.(kind).(parad) = varargin2S(varargin);
            Expr.update_c_parad(kind, parad, 'add_factor');
            
            if nargout > 0, c_factor = Expr.factor.(kind).(parad); end
        end
        
        function c_params = add_params(Expr, kind, parad, varargin)
            % ADD_PARAMS: add parameters that are constant throughout the paradigm.
            %
            % c_params = add_params(Expr, kind, parad, 'var_name1', value1, ...)
            % c_params = add_params(Expr, kind, parad, struct)
            %
            % kind: 'Tr' or 'Run'
            %
            % options:
            % 'auto_lengthen_plan'
            % : If >0, evokes .lengthen_plan() from .new_obs().
            %
            % 'auto_attach_seeds'
            % : A struct (array) containing
            %     .filt_fun
            %     .unique_factor
            %     .unique_index
            %     .unique_index_max
            %     .seed_cols
            % : If seed_cols is nonempty, evokes .attach_seed_to_plan() from .cond2plan().
            %   Use a struct array to use multiple combinations of
            %   filt_fun, unique_factor, unique_index, and seed_cols.
            %
            % See also: min_, add_paradigm, add_distrib
            
            parad = Expr.parse_parad(kind, parad);
            
            if ~isfield(Expr.params.(kind), parad)
                Expr.params.(kind).(parad) = Expr.min_.params.(kind);
            end
            Expr.params.(kind).(parad) = varargin2S(varargin, Expr.params.(kind).(parad));
            
            % Convert auto_attach_seeds to distrib
            c_param = Expr.params.(kind).(parad);
            
            for ii = 1:length(c_param.auto_attach_seeds)
                S = c_param.auto_attach_seeds(ii);
                    
                for jj = 1:length(S.seed_cols)
                    Expr.add_distrib(kind, parad, S.seed_cols{jj}, ...
                        PsyDistrib.MATLAB_SEED_ARG, ...
                        S.unique_factor, S.unique_index, S.unique_index_max);
                end
            end
            
            % c_parad interface
            Expr.update_c_parad(kind, parad, 'add_params');
        
            % output
            if nargout > 0, c_params = Expr.params.(kind).(parad); end
        end
        
        function c_distrib = add_distrib(Expr, kind, parad, col_name, distrib_args, ...
                                    unique_by_factor, unique_by_index, unique_index_max)
            % c_params = add_distrib(Expr, kind, parad, col_name, distrib_args, ...
            %                       unique_by_factor, unique_by_index, index_max)
            %
            % distrib_args: - a PsyDistrib object or 
            %               - a cell array of arguments for PsyDistrib().
            % unique_by_factor: A cell vector of factor names.
            % unique_by_index : A cell vector of index column names.
            % unique_index_max: Maximum index for unique_by_index.
            %
            % kind: 'Tr' or 'Run'
            %
            % See also: add_paradigm, PsyDistrib
            
            % parad interface
            parad = Expr.parse_parad(kind, parad);
            
            % if empty call
            if ~exist('col_name', 'var')
                Expr.distrib.(kind).(parad) = struct;
                
                if nargout > 0
                    c_distrib = struct;
                end
                return;
            end
            
            % distrib
            if isa(distrib_args, 'PsyDistrib')
                Expr.distrib.(kind).(parad).(col_name) = distrib_args;
            elseif iscell(distrib_args)
                Expr.distrib.(kind).(parad).(col_name) = PsyDistrib(distrib_args{:});
            else
                error('distrib_args should be either a PsyDistrib object or a cell array!');
            end
            
            if ~exist('unique_by_factor', 'var'), unique_by_factor = {}; end
            if ~exist('unique_by_index', 'var'),  unique_by_index  = {}; end
                
            % unique_by
            Expr.distrib_unique_by_factor.(kind).(parad).(col_name) ...
                = unique_by_factor;
            
            Expr.distrib_unique_by_index.(kind).(parad).(col_name) ...
                = unique_by_index;
            
            unique_by_all = [unique_by_factor, unique_by_index];
            
            Expr.distrib_keys.(kind).(parad).(col_name) = unique_by_all;
            
            keys = cell(1,length(unique_by_factor) + length(unique_by_index));
            for i_factor = 1:length(unique_by_factor)
                c_factor = unique_by_factor{i_factor};
                
                keys{i_factor} = Expr.factor.(kind).(parad).(c_factor);
            end
            
            if ~isempty(keys)
                Expr.distrib_Map.(kind).(parad).(col_name) ...
                    = PsyMap2(keys, unique_index_max, '', [], 'key_names', unique_by_all);
            else
                Expr.distrib_Map.(kind).(parad).(col_name) = [];
            end
            
            % c_parad interface
            Expr.update_c_parad(kind, parad, 'add_distrib');
        
            % output
            if nargout > 0, c_distrib = Expr.distrib.(kind).(parad).(col_name); end
        end
        
        function c_cond = factor2cond(Expr, kind, parad, cond_freq)
            % Combine factors factorially, and attach cond_freq = 1 (can be omitted).
            % To omit cond_freq, give an empty vector.
            %
            % parad = rep2arad(Expr, kind, parad, cond_freq)
            %
            % cond_freq: Default number. Typically 1 or 0. Meaningful only in the
            %         relative terms.
            %
            % See also: add_paradigm
            
            parad = Expr.parse_parad(kind, parad);
            
            % Factorial combination
            Expr.cond.(kind).(parad) = ...
                factorDS(copyFields(dataset, Expr.min_.cond.(kind)), ...
                         Expr.factor.(kind).(parad));
            
            % Always set freq as something.
            if ~exist('cond_freq', 'var')
                cond_freq = 1;
            end
            if ~isempty(cond_freq)
                Expr.set_cond_freq(kind, parad, [], cond_freq, 'factor2cond');
            end
            
            Expr.update_c_parad(kind, parad, 'factor2cond');
            
            if nargout > 0
                c_cond = Expr.cond.(kind).(parad);
            end
        end
           
        function set_cond(Expr, kind, parad, cond)
            % kind: 'Tr' or 'Run'
            parad = Expr.parse_parad(kind, parad);
            
            Expr.cond.(kind).(parad) = cond;
        end
        
        function mark(Expr, kind, field, val, ix)
            % Mark both obs and plan of the current trial.
            % 'succT' and 'attempted' should always be modified through this method, 
            % so that obs and plan agree.
            %
            % val: should be a scalar.
            %
            % mark(Expr, kind, field, val, ix)
            
            if ~exist('ix', 'var')
                ix = Expr.i_all.(kind);
            end
            
            Expr.obs.(kind).(field)(ix,1) = val;
            
            if ~isempty(Expr.plan.(kind)) && ds_isfield(Expr.obs.(kind), ['condID_' kind]) % If there exists plan for this obs,
                Expr.plan.(kind).(field) ...
                    (Expr.plan.(kind).condID == Expr.obs.(kind).(['condID_' kind])(ix,1),1) = val;
            end
        end
        
        function lengthen_obs(Expr, kind, n_to_add)
            % Lengthen obs by n_to_add or .n_obs_margin (default)
            %
            % lengthen_obs(Expr, [kind = 'Tr'], [n_to_add])
            if ~exist('kind', 'var'), kind = 'Tr'; end
            if ~exist('n_to_add', 'var'), n_to_add = Expr.n_obs_margin.(kind); end
            Expr.obs.(kind).succT(length(Expr.obs.(kind)) + n_to_add,1) = false;
        end
        
        function lengthen_plan(Expr, kind, n, n_unit, filt)
            % lengthen_plan(Expr, [kind='Tr'], [n=Expr.c_params.Tr.auto_lengthen_plan], [n_unit='plan_per_cond'])
            
            if ~exist('kind', 'var'), kind = 'Tr'; end
            if ~exist('n_unit', 'var'), n_unit = 'plan_per_cond'; end
            if ~exist('filt', 'var')
                filt = []; 
            elseif ~isa(filt, 'function_handle')
                error('filt, when specified, should be a function handle!');
            end
            
            % Get current parad, if any.
            parad = Expr.c_parad.(kind);
            
            if ~isempty(parad) 
                if ~exist('n', 'var'), 
                    n = double(Expr.c_params_('Tr', 'auto_lengthen_plan'));
                    n_unit = 'plan_per_cond';
                end
                Expr.cond2plan(kind, parad, n, n_unit, filt);
            end
            % If parad is empty, lengthening plan is unnecessary.
        end
        
        %% ----- Minimal instances -----
        function add_min_(Expr, prop, kind, varargin)
            % ADD_MIN_ : add to minimal instance.
            %
            % add_min_(Expr, prop, kind, 'col_name1', col_val1, ...)
            %
            % See also: min_
            
            % Parse kind
            if strcmp(kind, 'all')
                c_kinds = Expr.kinds;
            else
                c_kinds = {kind};
            end
            
            % Parse varargin
            cols = varargin(1:2:end);
            vals = varargin(2:2:end);

            % Copy fields
            for c_kind = c_kinds
                for i_col = 1:length(cols)
                    c_col = cols{i_col};
                    c_val = vals{i_col};

                    if any(strcmp(prop, {'cond', 'plan', 'obs'}))
                        % For datasets, enforce size of first dimension to be 0.
                        c_val_min = repmat(c_val, [0 1]);
                    else
                        % Just copy if struct.
                        c_val_min = c_val;
                    end
                    Expr.min_.(prop).(c_kind{1}).(c_col) = c_val_min;
                    
                    if any(strcmp(prop, {'params', 'cond'}))
                        % param & cond has parad as fields.
                        
                        for parad = fieldnames(Expr.(prop).(c_kind{1}))'                            
                            add_prop_col({prop, c_kind{1}, parad{1}}, c_col, c_val_min);
                        end
                    else
                        % plan & obs is a single dataset.
                        add_prop_col({prop, c_kind{1}}, c_col, c_val_min);
                    end
                end
            end          

            % Something added to plan should be added to obs, too.
            if strcmp(prop, 'plan')
                Expr.add_min_('obs', kind, varargin{:});
            end
            
            function add_prop_col(c_subs, col, val)
                S = subsS(c_subs{:});
                
                % If existing minimum field is being overwritten,
                % warn that existing instances (plan or obs) will not be
                % overwritten.
                if isfield(subsref(Expr, S), col)
                    warning(['min value for ' ...
                        sprintf('%s.', c_subs{:}), '%s is added, but ' ...
                        'existing columns will not be overwritten!\n' ...
                        'Changes will apply to new instances only.']);
                end
                
                if any(strcmp(prop, {'cond', 'plan', 'obs'}))
                    Expr = subsasgn(Expr, S, ds_set(subsref(Expr, S), ':', col, val));
                else
                    Expr = subsasgn(Expr, subsS([c_subs, {col}]), val);
                end                
            end
        end
        
        %% Sets
        function add_subset(Expr, set_name, subset_name, subset)
            % Add or modify a subset
            %
            % add_subset(Expr, set_name, subset_name, subset)
            
            Expr.sets.(set_name).(subset_name) = subset;
        end
        
        function choose_subset(Expr, set_name, subset_name)
            % choose_subset(Expr, set_name, subset_name)
            
            assert(isfield(Expr.sets.(set_name), subset_name), ...
                '%s is not a subset of the set %s', subset_name, set_name);
            
            Expr.c_subset.(set_name) = subset_name;
        end
        
        %% ----- Filtering -----
        function tf = filt(Expr, prop, kind, fun)
            % tf = filt(Expr, prop, kind, fun)
            %
            % prop: 'obs' or 'plan'
            %
            % EXAMPLE:
            % tf = Expr.filt('obs', 'Tr', @(d) d.task=='A')
            %
            % See also: filt, n_filt, filt_obTr, n_filt_obTr, filt_run, filt_ds, filt_rem_plan
            
            if isempty(Expr.(prop).(kind))
                tf = false(0,1);
            else
                tf = fun(Expr.(prop).(kind));
                
                % Expand if scalar, e.g., fun = %(ds) true.
                if isscalar(tf) && length(Expr.(prop).(kind)) > 1
                    tf = repmat(tf, [length(Expr.(prop).(kind)), 1]);
                end
            end
        end
        
        function n = n_filt(Expr, prop, kind, fun)
            % nnz(filt).
            %
            % n = n_filt(Expr, prop, kind, fun)
            %
            % See also: filt, n_filt, filt_obTr, n_filt_obTr, filt_run, filt_ds, filt_rem_plan
            n = nnz(Expr.filt(prop, kind, fun));
        end
        
        function tf = filt_obTr(Expr, fun)
            % FILT_OBTR : Same as filt, but finds within obTr.
            %
            % tf = filt_obTr(Expr, fun)
            %
            % See also: filt, n_filt, filt_obTr, n_filt_obTr, filt_run, filt_ds, filt_rem_plan
            
            if isempty(fun) || Expr.i_all.Tr == 0
                tf = true(Expr.i_all.Tr,1);
            else
                tf = fun(Expr.obTr);
            end
        end
        
        function n = n_filt_obTr(Expr, fun)
            % N_FILT_OBTR : nnz(filt_obTr).
            %
            % n = n_filt_obTr(Expr, fun)
            %
            % See also: filt, n_filt, filt_obTr, n_filt_obTr, filt_run, filt_ds, filt_rem_plan
            
            n = nnz(Expr.filt_obTr(fun));
        end
        
        function tf = filt_run(Expr, i_Run, fun)
            % FILT_RUN : rows of obs.Run with specified i_Run.
            %
            % tf = filt_run(Expr, i_Run, fun)
            %
            % See also: filt, n_filt, filt_obTr, n_filt_obTr, filt_run, filt_ds, filt_rem_plan
            
            i_Run = rel_ix(i_Run, Expr.i.Run);
            
            if ~exist('fun', 'var') || isempty(fun)
                tf = Expr.filt('obs', 'Tr', @(d) bsxEq(d.i_Run, i_Run(:)'));
            else
                tf = Expr.filt('obs', 'Tr', @(d) bsxEq(d.i_Run, i_Run(:)') & fun(d));
            end
        end
        
        function ds = filt_ds(Expr, prop, kind, fun, varargin)
            % ds = filt_ds(Expr, prop, kind, fun, columns)
            %
            % EXAMPLE:
            % ds = Expr.filt_ds('obs', 'Tr', @(d) d.task=='A')
            %
            % See also: filt, n_filt, filt_obTr, n_filt_obTr, filt_run, filt_ds, filt_rem_plan
            
            tf = Expr.filt(prop, kind, fun);
            ds = ds_fields(Expr.(prop).(kind), tf, varargin{:});
        end
        
        function tf = filt_rem_plan(Expr, kind, fun)
            % Indices of remaining & non-cancelled trials in cond.
            %
            % tf = filt_rem_plan(Expr, kind, fun)
            % fun: applies to Expr.plan.(kind).
            %
            % See also: filt, n_filt, filt_obTr, n_filt_obTr, filt_run, filt_ds, filt_rem_plan
            
            if ~exist('fun', 'var') || isempty(fun)
                tf = filt(Expr, 'plan', kind, @(d) ~d.succT & ~d.cancelled);
            else
                tf = filt_rem_plan(Expr, kind) & fun(Expr.plan.(kind));
            end
        end
        
        function ds = last_filt(Expr, prop, kind, n, fun, fields)
            % ds = last_filt(Expr, prop, kind, n, fun, fields)
            
            tf = Expr.filt(prop, kind, fun);
            ix = find(tf, n, 'last'); % maximum n entries
            
            if length(ix) < n
                warning('%d entries were querried, but only %d were filtered in.', ...
                    n, length(ix));
            end
            
            if ~exist('fields', 'var'), fields = ':'; end
            
            ds = ds_fields(Expr.(prop).(kind), ix, fields);
        end
        
        %% ----- Name management -----
        function parad = parse_parad(Expr, kind, parad)
            % If empty parad is given, return c_parad.(kind).
            % Should be called whenever parad is given as an argument.
            %
            % parad = parse_parad(Expr, prop, kind, parad)
            
            if isempty(parad)
                % get c_parad.(kind), 
                % which is the last observed parad (if any),
                % or last added parad for the kind.
                parad = Expr.c_parad.(kind);
                
                if isempty(parad) % If even that is not set, issue error.
                    error(['Empty parad is given, but no parad has added or observed! ', ...
                           'Use add_paradigm with nonempty parad to add a paradigm!']);
                end
            end
        end
        
        function update_c_parad(Expr, kind, new_parad, from)
            % UPDATE_C_PARAD : Change what to consider as current paradigm.
            %
            % update_c_parad(Expr, kind, new_parad, from)
            % 
            % Update from sources other than 'new_obs' is allowed 
            % only when there's no observation yet, unless from='force' is given.
            %
            % See also set_c_parad_
            
            if Expr.i_all.(kind) == 0 || any(strcmp(from, {'new_obs', 'force'}))
                Expr.c_parad.(kind) = new_parad;
            end
        end
        
        %% ----- Get/Set -----
        % P: A central property that has all parameters. 
        function P = get.P(Expr)
            % P: Struct of inherited parameters. Read-only.
            % Precedence: last_Tr > c_params_Tr > last_Run > c_params_Run > c_sets (in the order of its fields) > G
        
            P = Expr.G;
            
            cc_sets = Expr.c_sets;
            for f = fieldnames(cc_sets)'
                P = copyFields(P, cc_sets.(f{1}));
            end
            
            P = copyFields(P, Expr.c_params_Run);
            c = Expr.last_Run;
            if ~isempty(c)
                P = copyFields(P, c);
            end
            
            P = copyFields(P, Expr.c_params_Tr);
            c = Expr.last_Tr;
            if ~isempty(c)
                P = copyFields(P, c);
            end
        end
        
        function cP = P_Tr(Expr, i_all_Tr)
            % cP = P_Tr(Expr, i_all_Tr)
            %
            % P at the time of i_all_Tr.
            
            cP = Expr.G;
            
            cc_sets = c_sets_Tr(Expr, i_all_Tr);
            for f = fieldnames(cc_sets)'
                cP = copyFields(cP, cc_sets.(f{1}), true);
            end
            
            % Consider parad at the time of i_all_Tr.
            cc_parad = Expr.obs.Tr.parad{i_all_Tr};
            c_i_Run  = Expr.obs.Tr.i_all_Run(i_all_Tr);
            
            % In obs.Run and Tr, copy variables added before i_all_Tr.
            col_existed_Run = Expr.col_existed_at('Run', c_i_Run);
            col_existed_Tr  = Expr.col_existed_at('Tr',  i_all_Tr);
            
            cP = copyFields(cP, Expr.params.Run.(cc_parad));
            cP = copyFields(cP, Expr.obs.Run(c_i_Run,:), col_existed_Run);
            cP = copyFields(cP, Expr.params.Tr.(cc_parad));
            cP = copyFields(cP, Expr.obs.Tr(i_all_Tr,:), col_existed_Tr);
        end
        
        % col_added_at
        function cols = col_existed_at(Expr, kind, ix)
            % cols = col_existed_at(Expr, kind, ix)
            
            S = Expr.col_added_at.(kind);
            added_at = cell2mat(struct2cell(S)');
            cols     = fieldnames(S)';
            
            cols = cols(added_at <= ix);
        end
        
        % sets/subsets
        function res = get.c_sets(Expr)
            % Chosen subsets of the set
            res = struct;
            cc_subset = Expr.c_subset;
            
            for f = fieldnames(cc_subset)'
                try
                    res.(f{1}) = Expr.sets.(f{1}).(cc_subset.(f{1}));
                catch
                    % If cc_subset.(f{1}) is not a valid subset name,
                    % return empty struct.
                    %
                    % This will leave P unaffected by sets with 
                    % invalid subset names.
                    res.(f{1}) = struct;
                end
            end
        end
        
        function cc_sets = c_sets_Tr(Expr, i_all_Tr)
            % c_sets at the time of i_all_Tr
            %
            % cc_sets = c_sets_Tr(Expr, i_all_Tr)
            
            % Copy properties to save time
            temp_sets = Expr.sets;
            temp_cTr  = copyFields(struct, Expr.obs.Tr(i_all_Tr,:), {'Properties'});
            
            % Initialize output
            cc_sets = struct;
            
            % For each set,
            for f = Expr.set_names
                try
                    % Copy the subset name from the i_all_Tr-th trial
                    c_subset_Tr = temp_cTr.(['set__' f{1}]);
                
                    % Copy the sets value
                    cc_sets.(f{1}) = temp_sets.(f{1}).(c_subset_Tr);
                catch
                end
            end
        end
        
        function res = get.set_names(Expr)
            res = fieldnames(Expr.c_subset)';
        end
        
        function sync_c_subset(Expr, i_all_Tr)
            % Copy 'set__' fields from obs.Tr to c_subset if possible.
            % Otherwise, copy c_subset back to 'set__' fields in obs.
            
            if nargin < 2, i_all_Tr = Expr.i_all.Tr; end
            
            cc_subset = Expr.c_subset;
            ccTr      = Expr.obs.Tr(i_all_Tr,:);
            
            for f = fieldnames(cc_subset)'
                try
                    cc_subset.(f{1}) = ccTr.(f{1});
                catch
                    ccTr.(f{1}) = cc_subset.(f{1});
                end
            end
        end
                
        % c_factor/cond/params/set
        function p = c_parad_(Expr, prop, kind, field)
            parad = Expr.c_parad.(kind);
            
            if ~exist('field', 'var')
                if ~isempty(parad)
                    p = Expr.(prop).(kind).(parad);
                else
                    warning('Expr.%s.%s.%s is referenced but doesn''t exist -- returning empty struct', ...
                        prop, kind, parad);
                    p = struct;
                end
            else
                try
                    p = Expr.(prop).(kind).(parad).(field);
                catch
                    warning('Expr.%s.%s.%s.%s is referenced but doesn''t exist -- returning []', ...
                        prop, kind, parad, field);
                    p = [];
                end
            end
        end
        
        function set_c_parad_(Expr, prop, kind, src)
            % set_c_parad_(Expr, prop, kind, src)
            %
            % See also update_c_parad
             
            parad = Expr.c_parad.(kind);
            Expr.(prop).(kind).(parad) = src;
        end
        
        function res = c_factor(Expr, kind)
            res = Expr.c_parad_('factor', kind);
        end
        
        function res = c_cond(Expr, kind) %#ok<REDEF>
            res = Expr.c_parad_('cond', kind);
        end
        
        function res = c_params(Expr, kind, field)
            if ~exist('field', 'var')
                res = Expr.c_parad_('params', kind);
            else
                res = Expr.c_parad_('params', kind, field);
            end
        end
        
        function res = c_distrib(Expr, kind, field)
            if ~exist('field', 'var')
                res = Expr.c_parad_('distrib', kind);
            else
                res = Expr.c_parad_('distrib', kind, field);
            end
        end
        
        function res = get.c_factor_Tr(Expr)
            res = Expr.c_factor('Tr');
        end
        
        function res = get.c_factor_Run(Expr)
            res = Expr.c_factor('Run');
        end
        
        function res = get.c_cond_Tr(Expr)
            res = Expr.c_parad_('cond', 'Tr');
        end
        
        function res = get.c_cond_Run(Expr)
            res = Expr.c_parad_('cond', 'Run');
        end
        
        function res = get.c_params_Tr(Expr)
            res = Expr.c_parad_('params', 'Tr');
        end
        
        function res = get.c_params_Run(Expr)
            res = Expr.c_parad_('params', 'Run');
        end
        
        function res = get.c_distrib_Tr(Expr)
            res = Expr.c_parad_('distrib', 'Tr');
        end
        
        function res = get.c_distrib_Run(Expr)
            res = Expr.c_parad_('distrib', 'Run');
        end
        
        function res = get.planned_cols_Tr(Expr)
            res = union(Expr.plan.Tr.Properties.VarNames, fieldnames(Expr.c_params_Tr));
        end
        
        function res = get.planned_cols_Run(Expr)
            res = union(Expr.plan.Run.Properties.VarNames, fieldnames(Expr.c_params_Run));
        end
        
        function set.c_cond_Tr(Expr, src)
            Expr.set_c_parad_(Expr, 'cond', 'Tr', src);
        end
        
        function set.c_cond_Run(Expr, src)
            Expr.set_c_parad_(Expr, 'cond', 'Run', src);
        end
        
        function set.c_params_Tr(Expr, src)
            Expr.set_c_parad_('params', 'Tr', src);
        end
        
        function set.c_params_Run(Expr, src)
            Expr.set_c_parad_('params', 'Run', src);
        end
        
        function n = n_cond_from_factor(Expr, kind, parad)
            % n_cond_from_factor(Expr, kind, parad)
            n = prod(cellfun(@numel, struct2cell(Expr.factor.(kind).(parad))));
        end
        
        function n = n_cond(Expr, kind, parad)
            try
                n = sum(Expr.cond.(kind).(parad).freq);
            catch
                n = 0;
            end
        end
        
        % remTr/Run
        function ds = get.remTr(Expr)
            ds = Expr.plan.Tr(Expr.filt_rem_plan('Tr'), :);
        end
        
        function set.remTr(Expr, ds)
            Expr.repTr = ds_set(Expr.repTr, Expr.filt_rem_plan('Tr'), ds);
        end
        
        function ds = get.remRun(Expr)
            ds = Expr.plan.Run(Expr.filt_rem_plan('Run'), :);
        end
        
        function set.remRun(Expr, ds)
            Expr.repRun = ds_set(Expr.repRun, Expr.filt_rem_plan('Run'), ds);
        end
        
        % last_Tr/Run
        function ds = last_obs(Expr, kind, ix, varargin)
            % ds = last_obs(Expr, kind, ix_from_last, varargin)
            %
            % ix_from_last : 1 is current.
            
            if nargin < 3, ix = 1; end
            if nargin < 2, kind = 'Tr'; end
            
            len  = min(Expr.i_all.(kind), length(Expr.obs.(kind)));
            
            if max(ix) > len
                fprintf('last_obs: %d-to-last observation is queried - more than existing!\n', max(ix));
                fprintf('last_obs: %d-to-last observation will be returned - all that exist...\n', len);
            end
            
            ix  = ix(ix <= len);
            ix = len + 1 - ix;
            
            ds = ds_fields(Expr.obs.(kind), ix, varargin{:});
        end
        
        function set_last_obs(Expr, kind, varargin)
            % set_last_obs(Expr, kind, ds_or_name_value_pair)
            
            [Expr.obs.(kind), added_cols] = ds_set(Expr.obs.(kind), Expr.i_all.(kind), varargin{:});
            
            if ~isempty(added_cols)
                for f = added_cols
                    Expr.col_added_at.(kind).(f{1}) = Expr.i_all.(kind);
                end
            end
        end
        
        function ds = get.last_Tr(Expr)
            ds = Expr.last_obs('Tr',1);
        end
        
        function set.last_Tr(Expr, ds)
            Expr.set_last_obs('Tr', ds);
        end
        
        function set_last_Tr(Expr, varargin)
            % set_last_Tr(Expr, 'var1', val1, ...)
            % set_last_Tr(Expr, struct_or_dataset)
            Expr.obs.Tr = ds_set(Expr.obs.Tr, Expr.i_all.Tr, varargin{:});
        end
        
        function ds = get.last_Run(Expr)
            ds = Expr.last_obs('Run', 1);
        end
        
        function set.last_Run(Expr, ds)
            Expr.set_last_obs('Run', ds);
        end
        
        function set_last_Run(Expr, varargin)
            % set_last_Run(Expr, 'var1', val1, ...)
            % set_last_Run(Expr, struct_or_dataset)
            Expr.set_last_obs('Run', varargin{:});
        end
        
        % obTr/Run
        function ds = get.obTr(Expr)
            if ~isempty(Expr.obs.Tr)
                ds = Expr.obs.Tr(1:Expr.i_all.Tr,:);
            else
                ds = dataset;
            end
        end
        
        function set.obTr(Expr, ds)
            Expr.obs.Tr = ds_set(Expr.obs.Tr, 1:Expr.i_all.Tr, ds);
        end
        
        function set_obTr(Expr, varargin)
            % set_obTr(Expr, 'var1', val1, ...)
            % set_obTr(Expr, dataset_or_struct)
            Expr.obs.Tr = Expr.ds_set(Expr.obs.Tr, 1:Expr.i_all.Tr, varargin{:});
        end
        
        function ds = get.obRun(Expr)
            if ~isempty(Expr.obs.Run)
                ds = Expr.obs.Run(1:Expr.i_all.Run,:);
            else
                ds = dataset;
            end
        end
        
        function res = obTr_in_Run(Expr, i_Tr, varargin)
            % res = obTr_in_Run(i_Tr = ':', columns=':')
            if ~exist('i_Tr', 'var')
                i_Tr_st = rel_ix(1, Expr.i.Tr);
                i_Tr_en = rel_ix(0, Expr.i.Tr);
                i_Tr = i_Tr_st:i_Tr_en;
            else
                i_Tr = rel_ix(i_Tr, Expr.i.Tr);
            end
            
            res = ds_fields(Expr.obs.Tr, Expr.filt_run(0), varargin{:});
            
            if exist('i_Tr', 'var') && (~ischar(i_Tr) || ~isequal(i_Tr,':'))
                res = res(i_Tr,:);
            end
        end
        
        function set.obRun(Expr, ds)
            Expr.obs.Run(1:Expr.i_all.Run,:) = ds;
        end
        
        function set_obRun(Expr, varargin)
            % set_obRun(Expr, 'var1', val1, ...)
            % set_obRun(Expr, dataset_or_struct)
            Expr.obs.Run = Expr.ds_set(Expr.obs.Run, 1:Expr.i_all.Run, varargin{:});
        end
        
        % plan
        function n = n_(Expr, kind, prop, parad)
            % n_(Expr, kind, prop, parad)
            parad = Expr.parse_parad(parad);
            n = length(Expr.(prop).(kind).(parad));
        end
        
        % sTr/Run
        function tf = is_succ(Expr, kind)
            tf = Expr.obs.(kind).succT;
        end
        
        function n = n_succ(Expr, kind, opt)
            if ~exist('opt', 'var')
                n = nnz(Expr.is_succ(kind));
            elseif ischar('opt')
                switch opt
                    case 'this_Run_cond'
                        try
                            n = nnz(Expr.is_succ(kind) ...
                                 & (Expr.obs.(kind).condID_Run == Expr.last_Run.condID));
                        catch c_error
                            % If nothing was recorded or no Run was planned
                            if Expr.i_all.(kind) == 0 ...
                                    || Expr.last_Run.condID == 0
                                n = 0;
                            else
                                rethrow(c_error);
                            end
                        end
                end
            end
        end
            
        function ds = get.sTr(Expr)
            if ~isempty(Expr.obsTr)
                ds = Expr.obs.Tr(Expr.is_succ('Tr'),:);
            else
                ds = dataset;
            end
        end
        
        function set.sTr(Expr, ds)
            Expr.obs.Tr = ds_set(Expr.obs.Tr, Expr.is_succ('Tr'), ds);
        end
        
        function set_sTr(Expr, varargin)
            Expr.obs.Tr = ds_set(Expr.obs.Tr, Expr.is_succ('Tr'), varargin{:});
        end
        
        function n = n_sTr(Expr)
            n = nnz(Expr.is_succ('Tr'));
        end
        
        function ds = get.sRun(Expr)
            ds = Expr.obs.Run(Expr.is_succ('Run'),:);
        end
        
        function set.sRun(Expr, ds)
            Expr.obs.Run(Expr.is_succ('Run'),:) = ds;
        end
        
        function set_sRun(Expr, varargin)
            Expr.obs.Tr = ds_set(Expr.obs.Tr, Expr.is_succ('Run'), varargin{:});
        end
        
        function n = n_sRun(Expr)
            n = nnz(Expr.is_succ('Run'));
        end
        
        function C = get.all_parads_Tr(Tr)
            C = fieldnames(Tr.params.Tr);
        end
        
        function C = get.all_parads_Run(Tr)
            C = fieldnames(Tr.params.Run);
        end
        
        %% ----- Legacy -----
        function ix = get.cTr(Expr)
            ix = Expr.i_all.Tr;
        end
        
        function ix = get.cTrial(Expr)
            ix = Expr.i.Tr;
        end
        
        function ix = get.cRun(Expr)
            ix = Expr.i_all.Run;
        end
        
        function ds = get.repTr(Expr)
            % If something is loaded, return it.
            if ~isempty(Expr.repTr) 
                ds = Expr.repTr;
            else
                % Otherwise, work as an alias.
                ds = Expr.c_cond_Tr; 
            end
        end
        
        function ds = get.obsTr(Expr)
            % If something is loaded, return it.
            if ~isempty(Expr.obsTr) 
                ds = Expr.obsTr;
            else
                % Otherwise, work as an alias.
                ds = Expr.obs.Tr; 
            end
        end
        
        function S = get.rep(Expr)
            % If something is loaded, return it.
            if ~isempty(Expr.rep)
                S = Expr.rep;
            else
                % Otherwise, work as an alias.
                S = Expr.c_factor('Tr');
            end
        end
        
        function S = get.param(Expr)
            % If something is loaded, return it.
            if ~isempty(Expr.param)
                S = Expr.param;
            else
                % Otherwise, work as an alias.
                S = Expr.c_params_Tr;
            end
        end
        
        function S = get.G_legacy(Expr)
            try
                S = copy_fields(Expr.c_params_Tr, Tr.G, 'except_existing');
            catch
                S = Expr.G;
            end
        end
        
        function S = get.G(Expr)
            try
                S = copy_fields(Expr.G, Expr.c_params_Tr, 'all');
            catch err
                warning(err_msg(err));
            end
            Expr.G = S;
        end
        
        %% ----- Save -----
%         function me2 = saveobj(Expr)
%             if Expr.to_save_
%                 me2 = Expr;
%             else
%                 me2 = [];
%             end
%         end
    end
end
