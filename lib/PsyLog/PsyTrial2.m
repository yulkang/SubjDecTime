classdef PsyTrial2 < handle
    properties
        % May have more hierarchy, e.g., Day.
        % Parameters higher in the hierarchy is copied to the lower ones.
        kinds = {'Tr', 'Run'}; 
        
        % plan.Tr:
        % A dataset whose one random row is copied to obs.Tr before every trial.
        % The used row is automatically marked for deletion.
        % Parameters inherited from upper hierarchy is overwritten by
        % plans.
        plan  = struct('Tr', dataset, 'Run', dataset);
        
        % obs.Tr: 
        % A dataset that is recorded every trial.
        obs   = struct('Tr', dataset, 'Run', dataset);
        
        % c_parad.(parad_kind):
        %
        % e.g., c_parad.time = 'VD'
        % Name of the current paradigm.
        % Before every trial, c_parad.(parad_kind) is copied to 
        % obs.(['parad_' parad_kind])
        c_parad = struct;
        
        % params.(parad_kind).(c_parad.(parad_kind))
        %
        % e.g., params.time.VD
        % A struct with variables that are not copied to obs.Tr.
        % One should not overwrite existing params once it is used.
        params = struct;
        
        %% Indices
        i     = struct('Tr', 0, 'Run', 0);
        i_all = struct('Tr', 0, 'Run', 0);
    end
    
    properties (Dependent)
        obTr
        obRun
        sTr
        sRun
        
        last_Tr
        last_Run
    end
    
    methods
        %% Before experiment
        function add_plan(me, kind, ds)
            % Append plan with ds.
            % To replace the plan, simply set Tr.plan.(kind) = ds.
        end
        
        %% During experiment
        function new(me, kind, filt)
            % Increase index
            
            % Copy from the kind a step higher than the current kind.
            
            % Copy from a plan and mark used
            
        end
        
        function rec(me, kind, varargin)
            % Record fields
            
            ds_set
        end
        
        %% Get functions
        function ds = get.obTr(me)
            ds = me.obs.Tr(1:me.i_all.Tr, :);
        end
                
        function ds = get.obRun
            ds = me.obs.Run(1:me.i_all.Run, :);
        end
        
        function ds = get.sTr
            ds = me.obs.Tr(1:me.i_all.Run, :);
        end
        
        function ds = get.sRun
        end 
        
        function ds = get.last_Tr
        end
        
        function ds = get.last_Run
        end
        
        %% Set functions
    end
end