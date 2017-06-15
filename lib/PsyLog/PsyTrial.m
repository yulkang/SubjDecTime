classdef PsyTrial < PsyDeepCopy
    % PSYTRIAL : organize, retrieve, and record trials.
    %
    % Flow of info, for both Tr and Run:
    % ==================================
    % factor -> cond
    % cond, params, distrib -> plan -> obs
    %
    % PsyTrial Methods:
    % ==================================
    % Main interface
    % ----------------------------------
    % PsyTrial      - Constructor.
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
    % PsyTrial Properties:
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
        
        %% Indices
        % Kinds are in the order of increasing size (Tr < Run).
        kinds = {'Tr', 'Run'};
        i     = struct('Tr', 0, 'Run', 0);
        i_all = struct('Tr', 0, 'Run', 0);
        
        % c_parad: 
        % If there's any observation, i.e., i_all.(kind) > 0, 
        % the last observation's parad.
        % If there's none, parad that is last added/modified.
        % Managed by parse_parad().
        c_parad = struct('Tr', '', 'Run', '');
        
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
        
        % Legacy
        G_legacy
    end
    
    methods
        %% ===== Methods =====
        %% ----- Main flow -----
        function me = PsyTrial
            % PsyDeepCopy interface
            me.tag = 'Trial';
            me.deepCpNames = {'r'};
            
            % Minimal columns
            me.add_min_('cond', 'all', ...
                'repID',    0);
            
            me.add_min_('plan', 'all', ...
                'parad',    {''}, ...
                'repID',    0, ...
                'condID',   0, ...
                'succT',    false, ...
                'aborted',  false, ...
                'cancelled',false, ...
                'attempted',false);
            
            me.add_min_('params', 'all', ...
                'auto_lengthen_plan', 1, ...
                'auto_attach_seeds', struct( ... 
                    'filt_fun', [], ...
                    'unique_factor', {{}}, ...
                    'unique_index',  {{}}, ...
                    'unique_index_max', {[]}, ...
                    'seed_cols', {{}}) ...
                );
            
            % Tr is meant to be saved all, including RandStream
            me.save_handle_ = true;
        end
        
        function cond = add_paradigm(me, kind, parad, factor_args, params_args, distrib_args)
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
            
            parad = me.parse_parad(kind, parad);
            
            if ~exist('factor_args', 'var'), factor_args = {};   else factor_args = arg2C(factor_args); end
            if ~exist('params_args', 'var'), params_args = {};   else params_args = arg2C(params_args); end
            if ~exist('distrib_args', 'var'), distrib_args = {}; end
            
            if isempty(factor_args) && isempty(distrib_args)
                error('At least one factor or one distrib is necessary!');
            end
            
            me.add_factor( kind, parad, factor_args{:});
            if nargout > 0
                cond = me.factor2cond(kind, parad);
            else
                me.factor2cond(kind, parad);
            end
            
            me.add_params(  kind, parad, params_args{:});
            
            for ii = 1:length(distrib_args)
                me.add_distrib( kind, parad, distrib_args{ii}{:});
            end
        end
        
        function set_cond_freq(me, kind, parad, filt, c_cond_freq, from)
            % SET_COND_FREQ : Refine relative frequency of conditions
            %
            % set_cond_freq(me, kind, parad, filt, c_cond_freq, [from = 'user'])
            %
            % See also: cond2plan
            
            if ~exist('from', 'var'), from = 'user'; end
            
            parad = me.parse_parad(kind, parad);
            
            % Make sure cond.(kind).(parad) exists.
            if ~isfield(me.cond.(kind), parad)
                if strcmp(from, 'user') || ~strcmp(from, 'factor2cond')
                    error('cond.%s.%s doesn''t exist!', kind, parad);
                end
            end
            
            % Set up filter
            if ~exist('filt', 'var') || isempty(filt)
                tf = true(length(me.cond.(kind).(parad)), 1);
            elseif isa(filt, 'function_handle')
                tf = filt(me.cond.(kind).(parad));
            else
                tf = filt;
            end
            
            % Assign freq
            me.cond.(kind).(parad).freq(tf,1) = c_cond_freq;
        end
        
        function cond2plan(me, kind, parad, n, n_unit, filt)
            % COND2PLAN : Take conditions into plan, in proportion to freq.
            %
            % cond2plan(me, kind, parad, n, n_unit)
            %
            % n_unit        : 'plan_per_cond' | 'min_total_plan'
            %
            % See also: set_cond_freq, set_cond
            
            parad = me.parse_parad(kind, parad);
            
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
            c_cond = me.cond.(kind).(parad);
            
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
            c_max_cond_ID = length(me.plan.(kind));
            st_max_cond_ID = c_max_cond_ID;
            
            % future length of the plan
            n_plan_will_be = c_max_cond_ID + tot_freq * n_plan_per_cond;
            
            % preallocate memory
            if n_plan_will_be == 0, return; end % No plan to add
            me.plan.(kind).succT(n_plan_will_be,1) = false; 
            
            % legacy - maximum existing repID for the current paradigm & filter
            if ~isfield(c_cond, 'repID')
                OLD_REPID = true;
                
                if isempty(filt)
                    p_max_repID = max(me.plan.(kind).repID( ...
                        strcmp(parad, me.plan.(kind).parad),1));
                else
                    p_max_repID = max(me.plan.(kind).repID( ...
                        strcmp(parad, me.plan.(kind).parad) ...
                      & filt(me.plan.(kind)), 1));
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
            me.plan.(kind) = ds_set(me.plan.(kind), cond_ID_all, ...
                'succT', false, 'cancelled', false);
            
            % attach columns from distrib
            try
                c_fields = fieldnames(me.distrib.(kind).(parad))';
            catch
                c_fields = {};
            end
            
            if ~isempty(c_fields)
                for col = c_fields
                    % Retrieve from Map
                    key     = double(me.plan.(kind)...
                                        (new_row, ...
                                         me.distrib_keys.(kind).(parad).(col{1})));
                    val     = me.distrib_Map.(kind).(parad).(col{1})(key);
                    
                    % Assign new keys if val is unassigned
                    new_key = val==0;
                    
                    val(new_key) = unique_rand_by(me.r, key(new_key,:), ...
                        me.distrib.(kind).(parad).(col{1}));
                    
                    me.distrib_Map.(kind).(parad).(col{1})(key(new_key,:)) = val(new_key);
                    
                    % Assign val
                    me.plan.(kind).(col{1})(new_row,1) = val;
                end
            end
            
            % update cond. Especially, copy increased repID
            if isempty(filt)
                me.cond.(kind).(parad) = c_cond;
            else
                me.cond.(kind).(parad) = ...
                    ds_set( me.cond.(kind).(parad), filt, c_cond);
            end
            
            % parad interface
            me.update_c_parad(kind, parad, 'cond2plan');
            
            % Add cond to plan
            function add_cond2plan(to_add, i_freq)
                p_max_cond_ID = c_max_cond_ID;
                c_max_cond_ID = c_max_cond_ID + nnz(to_add);
                cond_ID       = ((p_max_cond_ID + 1) : c_max_cond_ID)';

                c_add = p_add + nnz(to_add) - 1;
                new_row(p_add:c_add) = cond_ID;
                p_add = c_add + 1;

                me.plan.(kind) = ds_set(me.plan.(kind), cond_ID, c_cond(to_add, :));

                if OLD_REPID
                    c_repID = i_freq + p_max_repID; % legacy. Cannot vary repID within parad, or handle filt in cond2plan.
                else
                    c_cond.repID(to_add) = c_cond.repID(to_add) + 1;
                    c_repID = c_cond.repID(to_add);
                end
                
                me.plan.(kind) = ds_set(me.plan.(kind), cond_ID, ...
                    'parad', {parad}, ...
                    'repID', c_repID, ...
                    'condID', cond_ID);
            end
        end
        
        function cancel_plan(me, kind, fun)
            % Cancel the remaining plans.
            %
            % cancel_plan(me, kind, [fun=[]])
            
            if ~exist('fun', 'var')
                ix = me.filt_rem_plan(kind);
            else
                ix = me.filt_rem_plan(kind, fun);
            end
            
            me.plan.(kind).cancelled(ix,1) = true;
        end
        
        function [ix, c_plan] = next_ix_plan(me, kind, filt)
            % [ix, c_plan] = next_ix_plan(me, kind, filt)
            
            if ~exist('filt', 'var') || isempty(filt)
                ix = find(me.filt_rem_plan(kind));
            elseif islogical(filt)
                ix = find(me.filt_rem_plan(kind) & filt(:));
            elseif isnumeric(filt)
                ix = find(intersect_tf_num(me.filt_rem_plan(kind), filt));
            elseif isa(filt, 'function_handle')
                ix = find(me.filt_rem_plan(kind, filt));
            else
                error('filt should be empty, logical, numeric, or a function handle!');
            end
            
            if ~isempty(ix)
                try
                    ix = ix(randi(me.r, length(ix)));
                catch
                    ix = ix(randi(length(ix)));
                end
                
                if nargout >= 2
                    c_plan = me.plan.(kind)(ix,:);
                end
            else
                c_plan = [];
            end
        end
        
        function auto_lengthen_plan(me, kind, filt, parad, filt_cond)
            % AUTO_LENGTHEN_PLAN : lengthen plan with parad if none left with filt.
            %
            % auto_lengthen_plan(me, kind, [filt, parad, filt_cond])
            %
            % Leave parad unspecified or empty not to lengthen plan.
            %
            % See also: new_obs, lengthen_plan
            
            if ~exist('filt', 'var'), filt = []; end
            if ~exist('filt_cond', 'var'), filt_cond = []; end
            
            if ~any(me.filt_rem_plan(kind, filt)) && ~isempty(parad)
                % If no plan is available, lengthen plan.
                % When there is some plans (albeit unavailable),
                % cond and params should exist too, since they're added together
                % in add_paradigm.
                c_auto_lengthen = me.params.(kind).(me.c_parad.(kind)).auto_lengthen_plan;
                if c_auto_lengthen
                    if me.verbose
                        fprintf('PsyTrial: Auto-lengthened plan: %dx\n', c_auto_lengthen);
                    end
                    me.update_c_parad(kind, parad, 'force');
                    
                    if isa(filt_cond, 'function_handle')
                        me.lengthen_plan(kind, c_auto_lengthen, 'plan_per_cond', filt_cond); % filter cond
                    else
                        me.lengthen_plan(kind, c_auto_lengthen, 'plan_per_cond');
                    end                    
                end
            end
        end
        
        function [i_kind, i_kind_all] = inc_ix(me, kind)
            % INC_IX  Increase index of kind and reset the index of smaller kinds.
            % For example, increasing Run index increases i.Run and i_all.Run,
            % and sets i.Tr to zero.
            %
            % [i_kind, i_kind_all] = inc_ix(me, kind)
            
            % Increase index
            i_kind = me.i.(kind) + 1;
            i_kind_all = me.i_all.(kind) + 1;
            
            % Set zero the smaller indices.
            ix_kind = find(strcmp(kind, me.kinds));
            for ii_kind = 1:(ix_kind-1)
                me.i.(me.kinds{ii_kind}) = 0;
            end
            
            me.i.(kind) = i_kind;
            me.i_all.(kind) = i_kind_all;
        end
        
        function obs = new_obs(me, kind, filt, filt_cond)
            % obs = new_obs(me, kind, [filt, filt_cond])
            %
            % Consider extending cond2plan or next_ix_plan in subclasses.
            %
            % See also: new_Tr, new_Run, lengthen_obs, auto_lengthen_plan
            
            if ~exist('filt', 'var'), filt = []; end
            if ~exist('filt_cond', 'var'), filt_cond = filt; end
            
            % Lengthen obs if necessary
            if me.i_all.(kind) >= length(me.obs.(kind))
                me.lengthen_obs(kind);
            end
            
            % Get next plan
            if isempty(me.cond.(kind)) || isequal(me.cond.(kind), struct)
                % If there's no cond, maybe the intention is to go without a plan.
                ix_plan = []; 
                c_plan = copyFields(dataset, me.min_.plan);
            else
                % Otherwise, choose a plan among remaining ones.
                % This should be done before increasing index, so that
                % last_obs can return the last recorded observation,
                % not the new, blank observation.
                parad = me.c_parad.(kind);
                
                % Auto-lengthen if necessary
                me.auto_lengthen_plan(kind, filt, parad, filt_cond);
                
                % Choose among remaining plans.
                [ix_plan, c_plan] = me.next_ix_plan(kind, filt);
                
                % If plan is still lacking somehow, should issue an error.
                if isempty(ix_plan)
                    error('No plan is avaiable!');
                end
            end
            
            inc_ix(me, kind);
            
            % Short alias for current kind's index
            c_i_all = me.i_all.(kind);
            
            % Copy plan, if any.
            if ~isempty(ix_plan)
                me.obs.(kind) = ds_set(me.obs.(kind), c_i_all, c_plan);
                
                % Mark attempted.
                me.mark(kind, 'attempted', true);
            end
            
            % Log current indices
            for c_kind = me.kinds
                me.obs.(kind).(['i_'     c_kind{1}])(c_i_all,1) = me.i.(    c_kind{1});
                me.obs.(kind).(['i_all_' c_kind{1}])(c_i_all,1) = me.i_all.(c_kind{1});
            end
            
            % Log condID for all kinds: condID_Tr, Run, etc.
            % Call new_Tr AFTER new_Run to get a correct condID_Run.
            for c_kind = me.kinds
                c_last_obs = me.last_obs(c_kind{1});
                if isempty(c_last_obs)
                    c_condID = 0;
                else
                    c_condID = c_last_obs.condID;
                end
                
                if strcmp(c_kind, kind)
                    me.obs.(kind).(['condID_' c_kind{1}])(c_i_all,1) = c_condID;
                else
                    c_last_obs = me.last_obs(c_kind{1});
                    
                    if ~isempty(c_last_obs)
                        me.obs.(kind).(['condID_' c_kind{1}])(c_i_all,1) = ...
                            c_last_obs.condID;
                    else
                        me.obs.(kind).(['condID_' c_kind{1}])(c_i_all,1) = 0;
                    end
                end
            end
            
            me.update_c_parad(kind, me.obs.(kind).parad{c_i_all,1}, 'new_obs');
            
            % Return output
            if nargout > 0
                obs = me.obs.(kind)(c_i_all,:);
            end
        end
        
        function varargout = new_Tr(me, varargin)
            % Do new_Tr AFTER new_Run to get a correct condID_Run.
            
            [varargout{1:nargout}] = me.new_obs('Tr', varargin{:});
        end
        
        function varargout = new_Run(me, varargin)
            % Do new_Tr AFTER new_Run to get a correct condID_Run.
            
            [varargout{1:nargout}] = me.new_obs('Run', varargin{:});
        end
        
        function S = rec(me, kind, succT, varargin)
            % REC: Record responses.
            %
            % S = rec(me, kind, succT, varargin)
            %
            % To supply strings or other variables with variable length,
            % supply a cell, e.g., {'string'}.
            
            % Record variables.
            me.set_last_obs(kind, varargin{:});
            
            % Mark success/fail.
            if ~isempty(succT)
                me.mark(kind, 'succT', succT);
            end
            
            % Return the record
            if nargout > 0
                S = copyFields(struct, me.last_Tr);
            end
        end
        
        %% resume_Run: suspended for now. Too complicated to implement.
%         function varargout = resume_Run(me, filt)
%             % Same as new_Run, but choose the latest failed run first, if any.
%             
%             if ~exist('filt', 'var'), filt = []; end
%             
%             if me.i_all.Run > 0
%                 obRun_failed = me.obRun.condID(find(~me.obRun.succT, 1, 'last'));
%             else
%                 obRun_failed = [];
%             end
%             
%             if isempty(obRun_failed)
%                 [varargout{1:nargout}] = me.new_obs('Run', filt);
%             else
%                 [varargout{1:nargout}] = me.new_obs('Run', obRun_failed);
%             end
%         end
        
        %% ----- Finer flow -----
        function c_factor = add_factor(me, kind, parad, varargin)
            % ADD_FACTOR: add factors that are combined in a factorial fashion.
            %
            % c_factor = add_factor(me, kind, parad, 'var_name1', value1, ...)
            % c_factor = add_factor(me, kind, parad, struct)
            %
            % kind: 'Tr' or 'Run'
            %
            % See also: add_paradigm
            
            parad = me.parse_parad(kind, parad);
            
            me.factor.(kind).(parad) = varargin2S(varargin);
            me.update_c_parad(kind, parad, 'add_factor');
            
            if nargout > 0, c_factor = me.factor.(kind).(parad); end
        end
        
        function c_params = add_params(me, kind, parad, varargin)
            % ADD_PARAMS: add parameters that are constant throughout the paradigm.
            %
            % c_params = add_params(me, kind, parad, 'var_name1', value1, ...)
            % c_params = add_params(me, kind, parad, struct)
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
            
            parad = me.parse_parad(kind, parad);
            
            if ~isfield(me.params.(kind), parad)
                me.params.(kind).(parad) = me.min_.params.(kind);
            end
            me.params.(kind).(parad) = varargin2S(varargin, me.params.(kind).(parad));
            
            % Convert auto_attach_seeds to distrib
            c_param = me.params.(kind).(parad);
            
            for ii = 1:length(c_param.auto_attach_seeds)
                S = c_param.auto_attach_seeds(ii);
                    
                for jj = 1:length(S.seed_cols)
                    me.add_distrib(kind, parad, S.seed_cols{jj}, ...
                        PsyDistrib.MATLAB_SEED_ARG, ...
                        S.unique_factor, S.unique_index, S.unique_index_max);
                end
            end
            
            % c_parad interface
            me.update_c_parad(kind, parad, 'add_params');
        
            % output
            if nargout > 0, c_params = me.params.(kind).(parad); end
        end
        
        function c_distrib = add_distrib(me, kind, parad, col_name, distrib_args, ...
                                    unique_by_factor, unique_by_index, unique_index_max)
            % c_params = add_distrib(me, kind, parad, col_name, distrib_args, ...
            %                       unique_by_factor, unique_by_index, index_max)
            %
            % distrib_args: A PsyDistrib object or a cell array of arguments that
            %               feed PsyDistrib constructor.
            % unique_by_factor: A cell vector of factor names.
            % unique_by_index : A cell vector of index column names.
            % unique_index_max: Maximum index for unique_by_index.
            %
            % kind: 'Tr' or 'Run'
            %
            % See also: add_paradigm, PsyDistrib
            
            % parad interface
            parad = me.parse_parad(kind, parad);
            
            % if empty call
            if ~exist('col_name', 'var')
                me.distrib.(kind).(parad) = struct;
                
                if nargout > 0
                    c_distrib = struct;
                end
                return;
            end
            
            % distrib
            if isa(distrib_args, 'PsyDistrib')
                me.distrib.(kind).(parad).(col_name) = distrib_args;
            elseif iscell(distrib_args)
                me.distrib.(kind).(parad).(col_name) = PsyDistrib(distrib_args{:});
            else
                error('distrib_args should be either a PsyDistrib object or a cell array!');
            end
            
            if ~exist('unique_by_factor', 'var'), unique_by_factor = {}; end
            if ~exist('unique_by_index', 'var'),  unique_by_index  = {}; end
                
            % unique_by
            me.distrib_unique_by_factor.(kind).(parad).(col_name) ...
                = unique_by_factor;
            
            me.distrib_unique_by_index.(kind).(parad).(col_name) ...
                = unique_by_index;
            
            unique_by_all = [unique_by_factor, unique_by_index];
            
            me.distrib_keys.(kind).(parad).(col_name) = unique_by_all;
            
            keys = cell(1,length(unique_by_factor) + length(unique_by_index));
            for i_factor = 1:length(unique_by_factor)
                c_factor = unique_by_factor{i_factor};
                
                keys{i_factor} = me.factor.(kind).(parad).(c_factor);
            end
            
            if ~isempty(keys)
                me.distrib_Map.(kind).(parad).(col_name) ...
                    = PsyMap2(keys, unique_index_max, '', [], 'key_names', unique_by_all);
            else
                me.distrib_Map.(kind).(parad).(col_name) = [];
            end
            
            % c_parad interface
            me.update_c_parad(kind, parad, 'add_distrib');
        
            % output
            if nargout > 0, c_distrib = me.distrib.(kind).(parad).(col_name); end
        end
        
        function c_cond = factor2cond(me, kind, parad, cond_freq)
            % Combine factors factorially, and attach cond_freq = 1 (can be omitted).
            % To omit cond_freq, give an empty vector.
            %
            % parad = rep2arad(me, kind, parad, cond_freq)
            %
            % cond_freq: Default number. Typically 1 or 0. Meaningful only in the
            %         relative terms.
            %
            % See also: add_paradigm
            
            parad = me.parse_parad(kind, parad);
            
            % Factorial combination
            me.cond.(kind).(parad) = ...
                factorDS(copyFields(dataset, me.min_.cond.(kind)), ...
                         me.factor.(kind).(parad));
            
            % Always set freq as something.
            if ~exist('cond_freq', 'var')
                cond_freq = 1;
            end
            if ~isempty(cond_freq)
                me.set_cond_freq(kind, parad, [], cond_freq, 'factor2cond');
            end
            
            me.update_c_parad(kind, parad, 'factor2cond');
            
            if nargout > 0
                c_cond = me.cond.(kind).(parad);
            end
        end
           
        function set_cond(me, kind, parad, cond)
            % kind: 'Tr' or 'Run'
            parad = me.parse_parad(kind, parad);
            
            me.cond.(kind).(parad) = cond;
        end
        
        function mark(me, kind, field, val, ix)
            % Mark both obs and plan of the current trial.
            % 'succT' and 'attempted' should always be modified through this method, 
            % so that obs and plan agree.
            %
            % val: should be a scalar.
            %
            % mark(me, kind, field, val, ix)
            
            if ~exist('ix', 'var')
                ix = me.i_all.(kind);
            end
            
            me.obs.(kind).(field)(ix,1) = val;
            
            if ~isempty(me.plan.(kind)) && ds_isfield(me.obs.(kind), ['condID_' kind]) % If there exists plan for this obs,
                me.plan.(kind).(field) ...
                    (me.plan.(kind).condID == me.obs.(kind).(['condID_' kind])(ix,1),1) = val;
            end
        end
        
        function lengthen_obs(me, kind, n_to_add)
            % Lengthen obs by n_to_add or .n_obs_margin (default)
            %
            % lengthen_obs(me, [kind = 'Tr'], [n_to_add])
            if ~exist('kind', 'var'), kind = 'Tr'; end
            if ~exist('n_to_add', 'var'), n_to_add = me.n_obs_margin.(kind); end
            me.obs.(kind).succT(length(me.obs.(kind)) + n_to_add,1) = false;
        end
        
        function lengthen_plan(me, kind, n, n_unit, filt)
            % lengthen_plan(me, [kind='Tr'], [n=me.c_params.Tr.auto_lengthen_plan], [n_unit='plan_per_cond'])
            
            if ~exist('kind', 'var'), kind = 'Tr'; end
            if ~exist('n_unit', 'var'), n_unit = 'plan_per_cond'; end
            if ~exist('filt', 'var')
                filt = []; 
            elseif ~isa(filt, 'function_handle')
                error('filt, when specified, should be a function handle!');
            end
            
            % Get current parad, if any.
            parad = me.c_parad.(kind);
            
            if ~isempty(parad) 
                if ~exist('n', 'var'), 
                    n = double(me.c_params_('Tr', 'auto_lengthen_plan'));
                    n_unit = 'plan_per_cond';
                end
                me.cond2plan(kind, parad, n, n_unit, filt);
            end
            % If parad is empty, lengthening plan is unnecessary.
        end
        
        %% ----- Minimal instances -----
        function add_min_(me, prop, kind, varargin)
            % ADD_MIN_ : add to minimal instance.
            %
            % add_min_(me, prop, kind, 'col_name1', col_val1, ...)
            %
            % See also: min_
            
            % Parse kind
            if strcmp(kind, 'all')
                c_kinds = me.kinds;
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
                    me.min_.(prop).(c_kind{1}).(c_col) = c_val_min;
                    
                    if any(strcmp(prop, {'params', 'cond'}))
                        % param & cond has parad as fields.
                        
                        for parad = fieldnames(me.(prop).(c_kind{1}))'                            
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
                me.add_min_('obs', kind, varargin{:});
            end
            
            function add_prop_col(c_subs, col, val)
                S = subsS(c_subs{:});
                
                % If existing minimum field is being overwritten,
                % warn that existing instances (plan or obs) will not be
                % overwritten.
                if isfield(subsref(me, S), col)
                    warning(['min value for ' ...
                        sprintf('%s.', c_subs{:}), '%s is added, but ' ...
                        'existing columns will not be overwritten!\n' ...
                        'Changes will apply to new instances only.']);
                end
                
                if any(strcmp(prop, {'cond', 'plan', 'obs'}))
                    me = subsasgn(me, S, ds_set(subsref(me, S), ':', col, val));
                else
                    me = subsasgn(me, subsS([c_subs, {col}]), val);
                end                
            end
        end
        
        %% ----- Filtering -----
        function tf = filt(me, prop, kind, fun)
            % tf = filt(me, prop, kind, fun)
            %
            % prop: 'obs' or 'plan'
            %
            % EXAMPLE:
            % tf = me.filt('obs', 'Tr', @(d) d.task=='A')
            %
            % See also: filt, n_filt, filt_obTr, n_filt_obTr, filt_run, filt_ds, filt_rem_plan
            
            if isempty(me.(prop).(kind))
                tf = false(0,1);
            else
                tf = fun(me.(prop).(kind));
                
                % Expand if scalar, e.g., fun = %(ds) true.
                if isscalar(tf) && length(me.(prop).(kind)) > 1
                    tf = repmat(tf, [length(me.(prop).(kind)), 1]);
                end
            end
        end
        
        function n = n_filt(me, prop, kind, fun)
            % nnz(filt).
            %
            % n = n_filt(me, prop, kind, fun)
            %
            % See also: filt, n_filt, filt_obTr, n_filt_obTr, filt_run, filt_ds, filt_rem_plan
            n = nnz(me.filt(prop, kind, fun));
        end
        
        function tf = filt_obTr(me, fun)
            % FILT_OBTR : Same as filt, but finds within obTr.
            %
            % tf = filt_obTr(me, fun)
            %
            % See also: filt, n_filt, filt_obTr, n_filt_obTr, filt_run, filt_ds, filt_rem_plan
            
            if isempty(fun) || me.i_all.Tr == 0
                tf = true(me.i_all.Tr,1);
            else
                tf = fun(me.obTr);
            end
        end
        
        function n = n_filt_obTr(me, fun)
            % N_FILT_OBTR : nnz(filt_obTr).
            %
            % n = n_filt_obTr(me, fun)
            %
            % See also: filt, n_filt, filt_obTr, n_filt_obTr, filt_run, filt_ds, filt_rem_plan
            
            n = nnz(me.filt_obTr(fun));
        end
        
        function tf = filt_run(me, i_Run, fun)
            % FILT_RUN : rows of obs.Run with specified i_Run.
            %
            % tf = filt_run(me, i_Run, fun)
            %
            % See also: filt, n_filt, filt_obTr, n_filt_obTr, filt_run, filt_ds, filt_rem_plan
            
            i_Run = rel_ix(i_Run, me.i.Run);
            
            if ~exist('fun', 'var') || isempty(fun)
                tf = me.filt('obs', 'Tr', @(d) bsxEq(d.i_Run, i_Run(:)'));
            else
                tf = me.filt('obs', 'Tr', @(d) bsxEq(d.i_Run, i_Run(:)') & fun(d));
            end
        end
        
        function ds = filt_ds(me, prop, kind, fun, varargin)
            % ds = filt_ds(me, prop, kind, fun, columns)
            %
            % EXAMPLE:
            % ds = me.filt_ds('obs', 'Tr', @(d) d.task=='A')
            %
            % See also: filt, n_filt, filt_obTr, n_filt_obTr, filt_run, filt_ds, filt_rem_plan
            
            tf = me.filt(prop, kind, fun);
            ds = ds_fields(me.(prop).(kind), tf, varargin{:});
        end
        
        function tf = filt_rem_plan(me, kind, fun)
            % Indices of remaining & non-cancelled trials in cond.
            %
            % tf = filt_rem_plan(me, kind, fun)
            % fun: applies to me.plan.(kind).
            %
            % See also: filt, n_filt, filt_obTr, n_filt_obTr, filt_run, filt_ds, filt_rem_plan
            
            if ~exist('fun', 'var') || isempty(fun)
                tf = me.filt('plan', kind, @(d) ~d.succT & ~d.cancelled);
            else
                tf = me.filt_rem_plan(kind) & fun(me.plan.(kind));
            end
        end
        
        function ds = last_filt(me, prop, kind, n, fun, fields)
            % ds = last_filt(me, prop, kind, n, fun, fields)
            
            tf = me.filt(prop, kind, fun);
            ix = find(tf, n, 'last'); % maximum n entries
            
            if length(ix) < n
                warning('%d entries were querried, but only %d were filtered in.', ...
                    n, length(ix));
            end
            
            if ~exist('fields', 'var'), fields = ':'; end
            
            ds = ds_fields(me.(prop).(kind), ix, fields);
        end
        
        %% ----- Name management -----
        function parad = parse_parad(me, kind, parad)
            % If empty parad is given, return c_parad.(kind).
            % Should be called whenever parad is given as an argument.
            %
            % parad = parse_parad(me, prop, kind, parad)
            
            if isempty(parad)
                % get c_parad.(kind), 
                % which is the last observed parad (if any),
                % or last added parad for the kind.
                parad = me.c_parad.(kind);
                
                if isempty(parad) % If even that is not set, issue error.
                    error(['Empty parad is given, but no parad has added or observed! ', ...
                           'Use add_paradigm with nonempty parad to add a paradigm!']);
                end
            end
        end
        
        function update_c_parad(me, kind, new_parad, from)
            % UPDATE_C_PARAD : Change what to consider as current paradigm.
            %
            % update_c_parad(me, kind, new_parad, from)
            % 
            % Update from sources other than 'new_obs' is allowed 
            % only when there's no observation yet, unless from='force' is given.
            %
            % See also set_c_parad_
            
            if me.i_all.(kind) == 0 || any(strcmp(from, {'new_obs', 'force'}))
                me.c_parad.(kind) = new_parad;
            end
        end
        
        %% ----- Get/Set -----
        % c_factor/cond/params
        function p = c_parad_(me, prop, kind, field)
            parad = me.c_parad.(kind);
            
            if ~exist('field', 'var')
                try % if ~isempty(parad)
                    p = me.(prop).(kind).(parad);
                catch % else
                    warning('me.%s.%s.%s is referenced but doesn''t exist -- returning empty struct', ...
                        prop, kind, parad);
                    p = struct;
                end
            else
                try
                    p = me.(prop).(kind).(parad).(field);
                catch
                    warning('me.%s.%s.%s.%s is referenced but doesn''t exist -- returning []', ...
                        prop, kind, parad, field);
                    p = [];
                end
            end
        end
        
        function set_c_parad_(me, prop, kind, src)
            % set_c_parad_(me, prop, kind, src)
            %
            % See also update_c_parad
             
            parad = me.c_parad.(kind);
            me.(prop).(kind).(parad) = src;
        end
        
        function res = c_factor(me, kind)
            res = me.c_parad_('factor', kind);
        end
        
        function res = c_cond(me, kind) %#ok<REDEF>
            res = me.c_parad_('cond', kind);
        end
        
        function res = c_params(me, kind, field)
            if ~exist('field', 'var')
                res = me.c_parad_('params', kind);
            else
                res = me.c_parad_('params', kind, field);
            end
        end
        
        function res = c_distrib(me, kind, field)
            if ~exist('field', 'var')
                res = me.c_parad_('distrib', kind);
            else
                res = me.c_parad_('distrib', kind, field);
            end
        end
        
        function res = get.c_factor_Tr(me)
            res = me.c_factor('Tr');
        end
        
        function res = get.c_factor_Run(me)
            res = me.c_factor('Run');
        end
        
        function res = get.c_cond_Tr(me)
            res = me.c_parad_('cond', 'Tr');
        end
        
        function res = get.c_cond_Run(me)
            res = me.c_parad_('cond', 'Run');
        end
        
        function res = get.c_params_Tr(me)
            res = me.c_parad_('params', 'Tr');
        end
        
        function res = get.c_params_Run(me)
            res = me.c_parad_('params', 'Run');
        end
        
        function res = get.c_distrib_Tr(me)
            res = me.c_parad_('distrib', 'Tr');
        end
        
        function res = get.c_distrib_Run(me)
            res = me.c_parad_('distrib', 'Run');
        end
        
        function set.c_cond_Tr(me, src)
            me.set_c_parad_(me, 'cond', 'Tr', src);
        end
        
        function set.c_cond_Run(me, src)
            me.set_c_parad_(me, 'cond', 'Run', src);
        end
        
        function set.c_params_Tr(me, src)
            me.set_c_parad_('params', 'Tr', src);
        end
        
        function set.c_params_Run(me, src)
            me.set_c_parad_('params', 'Run', src);
        end
        
        function n = n_cond_from_factor(me, kind, parad)
            % n_cond_from_factor(me, kind, parad)
            n = prod(cellfun(@numel, struct2cell(me.factor.(kind).(parad))));
        end
        
        function n = n_cond(me, kind, parad)
            try
                n = sum(me.cond.(kind).(parad).freq);
            catch
                n = 0;
            end
        end
        
        % remTr/Run
        function ds = get.remTr(me)
            ds = me.plan.Tr(me.filt_rem_plan('Tr'), :);
        end
        
        function set.remTr(me, ds)
            me.repTr = ds_set(me.repTr, me.filt_rem_plan('Tr'), ds);
        end
        
        function ds = get.remRun(me)
            ds = me.plan.Run(me.filt_rem_plan('Run'), :);
        end
        
        function set.remRun(me, ds)
            me.repRun = ds_set(me.repRun, me.filt_rem_plan('Run'), ds);
        end
        
        % last_Tr/Run
        function ds = last_obs(me, kind, n, varargin)
            if ~exist('n', 'var'), n = 1; end
            if ~exist('kind', 'var'), kind = 'Tr'; end
            
            l  = me.i_all.(kind);
            
            if n > l
                fprintf('last_obs: %d observations are queried - more than existing!\n', n);
                fprintf('last_obs: %d observations will be returned - all that exist...\n', l);
            end
            n  = min(n, l);
            ix = (l-n+1):l;
            
            ds = ds_fields(me.obs.(kind), ix, varargin{:});
        end
        
        function set_last_obs(me, kind, varargin)
            % set_last_obs(me, kind, ds_or_name_value_pair)
            
            me.obs.(kind) = ds_set(me.obs.(kind), me.i_all.(kind), varargin{:});
        end
        
        function ds = get.last_Tr(me)
            ds = me.last_obs('Tr',1);
        end
        
        function set.last_Tr(me, ds)
            me.set_last_obs('Tr', ds);
        end
        
        function set_last_Tr(me, varargin)
            % set_last_Tr(me, 'var1', val1, ...)
            % set_last_Tr(me, struct_or_dataset)
            me.obs.Tr = ds_set(me.obs.Tr, me.i_all.Tr, varargin{:});
        end
        
        function ds = get.last_Run(me)
            ds = me.last_obs('Run', 1);
        end
        
        function set.last_Run(me, ds)
            me.set_last_obs('Run', ds);
        end
        
        function set_last_Run(me, varargin)
            % set_last_Run(me, 'var1', val1, ...)
            % set_last_Run(me, struct_or_dataset)
            me.set_last_obs('Run', varargin{:});
        end
        
        % obTr/Run
        function ds = get.obTr(me)
            if ~isempty(me.obs.Tr)
                ds = me.obs.Tr(1:me.i_all.Tr,:);
            else
                ds = dataset;
            end
        end
        
        function set.obTr(me, ds)
            me.obs.Tr = ds_set(me.obs.Tr, 1:me.i_all.Tr, ds);
        end
        
        function set_obTr(me, varargin)
            % set_obTr(me, 'var1', val1, ...)
            % set_obTr(me, dataset_or_struct)
            me.obs.Tr = me.ds_set(me.obs.Tr, 1:me.i_all.Tr, varargin{:});
        end
        
        function ds = get.obRun(me)
            if ~isempty(me.obs.Run)
                ds = me.obs.Run(1:me.i_all.Run,:);
            else
                ds = dataset;
            end
        end
        
        function res = obTr_in_Run(me, i_Tr, varargin)
            % res = obTr_in_Run(i_Tr = ':', columns=':')
            if ~exist('i_Tr', 'var')
                i_Tr_st = rel_ix(1, me.i.Tr);
                i_Tr_en = rel_ix(0, me.i.Tr);
                i_Tr = i_Tr_st:i_Tr_en;
            else
                i_Tr = rel_ix(i_Tr, me.i.Tr);
            end
            
            res = ds_fields(me.obs.Tr, me.filt_run(0), varargin{:});
            
            if exist('i_Tr', 'var') && (~ischar(i_Tr) || ~isequal(i_Tr,':'))
                res = res(i_Tr,:);
            end
        end
        
        function set.obRun(me, ds)
            me.obs.Run(1:me.i_all.Run,:) = ds;
        end
        
        function set_obRun(me, varargin)
            % set_obRun(me, 'var1', val1, ...)
            % set_obRun(me, dataset_or_struct)
            me.obs.Run = me.ds_set(me.obs.Run, 1:me.i_all.Run, varargin{:});
        end
        
        % plan
        function n = n_(me, kind, prop, parad)
            % n_(me, kind, prop, parad)
            parad = me.parse_parad(parad);
            n = length(me.(prop).(kind).(parad));
        end
        
        % sTr/Run
        function tf = is_succ(me, kind)
            tf = me.obs.(kind).succT;
        end
        
        function n = n_succ(me, kind, opt)
            if ~exist('opt', 'var')
                n = nnz(me.is_succ(kind));
            elseif ischar('opt')
                switch opt
                    case 'this_Run_cond'
                        try
                            n = nnz(me.is_succ(kind) ...
                                 & (me.obs.(kind).condID_Run == me.last_Run.condID));
                        catch c_error
                            % If nothing was recorded or no Run was planned
                            if me.i_all.(kind) == 0 ...
                                    || me.last_Run.condID == 0
                                n = 0;
                            else
                                rethrow(c_error);
                            end
                        end
                end
            end
        end
            
        function ds = get.sTr(me)
            if ~isempty(me.obsTr)
                ds = me.obs.Tr(me.is_succ('Tr'),:);
            else
                ds = dataset;
            end
        end
        
        function set.sTr(me, ds)
            me.obs.Tr = ds_set(me.obs.Tr, me.is_succ('Tr'), ds);
        end
        
        function set_sTr(me, varargin)
            me.obs.Tr = ds_set(me.obs.Tr, me.is_succ('Tr'), varargin{:});
        end
        
        function n = n_sTr(me)
            n = nnz(me.is_succ('Tr'));
        end
        
        function ds = get.sRun(me)
            ds = me.obs.Run(me.is_succ('Run'),:);
        end
        
        function set.sRun(me, ds)
            me.obs.Run(me.is_succ('Run'),:) = ds;
        end
        
        function set_sRun(me, varargin)
            me.obs.Tr = ds_set(me.obs.Tr, me.is_succ('Run'), varargin{:});
        end
        
        function n = n_sRun(me)
            n = nnz(me.is_succ('Run'));
        end
        
        function C = get.all_parads_Tr(Tr)
            C = fieldnames(Tr.params.Tr);
        end
        
        function C = get.all_parads_Run(Tr)
            C = fieldnames(Tr.params.Run);
        end
        
        %% ----- Legacy -----
        function ix = get.cTr(me)
            ix = me.i_all.Tr;
        end
        
        function ix = get.cTrial(me)
            ix = me.i.Tr;
        end
        
        function ix = get.cRun(me)
            ix = me.i_all.Run;
        end
        
        function ds = get.repTr(me)
            % If something is loaded, return it.
            if ~isempty(me.repTr) 
                ds = me.repTr;
            else
                % Otherwise, work as an alias.
                ds = me.c_cond_Tr; 
            end
        end
        
        function ds = get.obsTr(me)
            % If something is loaded, return it.
            if ~isempty(me.obsTr) 
                ds = me.obsTr;
            else
                % Otherwise, work as an alias.
                ds = me.obs.Tr; 
            end
        end
        
        function S = get.rep(me)
            % If something is loaded, return it.
            if ~isempty(me.rep)
                S = me.rep;
            else
                % Otherwise, work as an alias.
                S = me.c_factor('Tr');
            end
        end
        
        function S = get.param(me)
            % If something is loaded, return it.
            if ~isempty(me.param)
                S = me.param;
            else
                % Otherwise, work as an alias.
                S = me.c_params_Tr;
            end
        end
        
        function S = get.G_legacy(me)
            try
                S = copy_fields(me.c_params_Tr, Tr.G, 'except_existing');
            catch
                S = me.G;
            end
        end
        
        function S = get.G(me)
            try
                S = copy_fields(me.G, me.c_params_Tr, 'all');
            catch err
                warning(err_msg(err));
            end
            me.G = S;
        end
        
        %% ----- Save -----
%         function me2 = saveobj(me)
%             if me.to_save_
%                 me2 = me;
%             else
%                 me2 = [];
%             end
%         end
    end
end
