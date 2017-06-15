classdef PsyDiscreteCond < PsyRStream
    % Yang/Kira style sampling.
    
    properties
        %% Evidence-related
        % Dimension names.
        feat_names = {};
        
        % n_lev.(feat) = Number of stimulus levels in each feat
        n_lev = struct
        
        % prob.(feat)(lev, cond) = probability of each level within cond.
        prob = struct;
        
        % lev.(feat)(i_pres) = level of each feat at each presentation.
        lev = struct;
        
        % cond.(feat) = Condition of each feat.
        cond = struct;
        
        % stim_spec.(feat){lev} = stimulus specification at each level.
        stim_spec = struct; 
        
        %% Temporal parameter
        t_freq  = 5; % Hz
        maxSec  = 5; % sec
        
        %% Separate randstreams for each feat
        RStream = struct;
    end
    
    properties (Dependent)
        n_feat  % Number of features
        
        maxN   % Maximum number of presentations
        
        ev_mom % ev_mom.(feat)(i_pres) = logit at i-th presentation.
        ev_cum % ev_cum.(feat)(i_pres) = cumulative logit at i-th presentation.
        ev_sum % ev_sum.(feat) = logit summed across all presentations.
        
        % logits.(feat)(lev, cond) = logit of the stimulus. Calculated from p.
        logits
    end
    
    methods
        %% Interface - Experiment
        function me = PsyDiscreteCond(varargin)
            if nargin > 0
                varargin2fields(me, varargin{:});
            end
        end        
        
        function init(me, conds, rSeeds, varargin)
            % Set high-level parameters that vary across trials
            %
            % init(me, {cond_feat1, cond_feat2, ...}, {rSeed_gen, rSeed1, ...}, varargin)
            
            me.cond = cell2struct(conds(:)', me.feat_names(:)', 2);
            initRStream(me, rSeeds);
            
            varargin2fields(me, varargin{:});
        end
        
        function initLogTrial(me)
            % Use high-level parameters and precompute
            %
            % initLogTrial(me)
            
            sample_lev(me);
        end
        
        %% Interface - Analysis
        function plot_lev(me)
        end
        
        function plot_ev(me)
        end
        
        %% Subfunctions
        function initRStream(me, rSeeds)
            % initRStream(me, rSeeds)
            
            % Check input.
            assert(iscell(rSeeds), 'Provide {seed_general, seed_for_feat1, ...}!');

            % Initialize general seed.
            me.initRStream@PsyRStream(rSeeds{1});

            % Always generate n_feat numbers.
            seeds = rand2seed(rand(me.rStream, 1, me.n_feat));

            % Use the general randStream to generate seeds for
            % the other randStreams, when there seeds are 'shuffle'.
            %
            % Since we always generate n_feat numbers, given the same
            % general seed, the other stream(s) with 'shuffle' gives
            % same results.
            for i_feat = 1:me.n_feat
                if strcmp(rSeeds{i_feat+1}, 'shuffle')
                    rSeeds{i_feat+1} = seeds(i_feat); 
                end
            end

            % Initialize seed for each feat.
            for i_feat = 1:me.n_feat
                c_feat = me.feat_names{i_feat};
                
                initRStream(me.RStream.(c_feat), rSeeds{i_feat + 1});
            end
        end
        
        function sample_lev(me)
            % For each presentation, sample a momentary evidence from logit.
            for cc_feat = me.feat_names(:)'
                c_feat = cc_feat{1};
                
                me.lev.(c_feat) = randsample(me.RStream.(c_feat).rStream, ...
                    me.n_lev.(c_feat), me.maxN, true, ...
                    me.prob.(c_feat)(:, me.cond.(c_feat)));
            end
        end
        
        function set_common(me, prop, v)
            % Set common value to feats.
            %
            % set_common(me, prop, v)
            
            for c_feat = me.feat_names
                me.(prop).(c_feat{1}) = v;
            end
        end
        
        %% Get/Set
        function v = get.ev_cum(me)
            for c_feat = me.feat_names(:)'
                v.(c_feat{1}) = cumsum(me.ev_mom.(c_feat{1}));
            end
        end
        
        function v = get.ev_sum(me)
            for c_feat = me.feat_names(:)'
                v.(c_feat{1}) = sum(me.ev_mom.(c_feat{1}));
            end
        end
        
        function v = get.n_feat(me)
            v = length(me.feat_names);
        end
        
        function v = get.maxN(me)
            v = ceil(me.t_freq * me.maxSec);
        end
        
        function v = get.logits(me)
            v = struct;
            
            for cc_feat = me.feat_names(:)'
                c_feat = cc_feat{1};
                
                p = me.prob.(c_feat);
                
                v.(c_feat) = log(p) - log(1 - p);
            end
        end
    end
end