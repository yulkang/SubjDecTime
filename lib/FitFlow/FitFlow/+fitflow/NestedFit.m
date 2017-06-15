classdef NestedFit < FitWorkspace & bml.oop.PropFileNameTree
%% Settings
properties (SetAccess=protected) % Set with init_W0(W_orig, th_group)
    % Set with W0.init_W0(W_orig, th_group)
    W_orig = FitWorkspace;
    
    % th_group{gr}: cell array of param names in group gr.
    % If there are parameters that are in no group, they are fitted in the
    % main fit.
    % Set with W0.init_W0(W_orig, th_group)
    th_group = {};
end
properties    
    % f_cost_group
    % : a method name or a cell array of method names for each group.
    % If nonempty, the specified method is called instead of get_cost
    % in the nested fit.
    % Use 'get_cost_nested' as a convention.
    % The nested cost functions may skip a time-consuming calculation
    % that does not depend on the parameters in the group.
    % Speed-up can be achieved even without making a separate method
    % by using persistent variables in pred(), e.g.:
    %
    % function pred(W)
    %     persistent th_vec_child_slow
    %     if ~isequal(W.child_slow.th_vec, th_vec_child_slow)
    %         th_vec_child_slow = W.child_slow.th_vec;
    %         W.child_slow.pred;
    %     end
    %     W.child_fast.pred;
    % end
    f_cost_group = '';
end
properties
    to_nest_fit = true;
end
%% Internal
properties
    th0_vec_orig
    th_lb_vec_orig
    th_ub_vec_orig
end
properties (Dependent)
    all_th_names_in_group
end
%% Methods
methods
    function W0 = NestedFit(varargin)
        W0.add_deep_copy({'W_orig'});
        if nargin > 0
            W0.init(varargin{:});
        end
    end
    function init(W0, varargin)
        % W0.init(W_orig, th_group, 'name1', var1, ...)
        % or
        % W0.init('W_orig', W_orig, 'th_group', th_group, ...)
        
        W_orig = W0.W_orig;
        th_group = W0.th_group;
        
        if ~ischar(varargin{1})
            W_orig = varargin{1};
            varargin = varargin(2:end);
        end
        if ~ischar(varargin{1})
            th_group = varargin{1};
            varargin = varargin(2:end);
        end
        
        S = varargin2S(varargin);
        if isfield(S, 'W_orig')
            W_orig = S.W_orig;
            S = rmfield(S, 'W_orig');
        end
        if isfield(S, 'th_group')
            th_group = S.th_group;
            S = rmfield(S, 'th_group');
        end
        
        W0.init_W0(W_orig, th_group);
    end
    function init_W0(W0, W_orig, th_group)
        if ~exist('W_orig', 'var') || isempty(W_orig)
            W_orig = W0.W_orig;
        end
        if ~exist('th_group', 'var') || isempty(th_group)
            th_group = W0.th_group;
        end
        W0.W_orig = W_orig;
        W0.th_group = th_group;
        
        % Call from within W_orig.fit().
        W = W0.W_orig;
        
        % Prepare for recovery of W_orig
        W0.th0_vec_orig = W.th0_vec;
        W0.th_lb_vec_orig = W.th_lb_vec;
        W0.th_ub_vec_orig = W.th_ub_vec;
    end
    function file = get_file(W0)
        file = fullfile('Data', class(W0), class(W0.W_orig), ...
            W0.W_orig.get_file_name);
    end
end
%% Simple interface
methods
    function [res, Fl] = fit(W0, varargin)
        % Call from within W_orig.fit().
        W = W0.W_orig;
        
        % Prepare for the nested fit
        W0.fix_th_in_group_and_recover_others( ...
            W0.all_th_names_in_group);
        
        % Prevent infinite recursion
        W.to_use_nested_fit = false; 
        
        % Nested fit
        C = varargin2C({
            'cost_fun', @W0.get_cost
            }, varargin);
        W.fit(C{:});
        
        % Recover W_orig for the last iteration
        W0.fix_th_in_group_and_recover_others({}, 'orig');
        
        % One final step to get Hessian, etc.
        S = varargin2S(varargin, {
            'opts', {}
            });
        S.opts = varargin2C(S.opts, {
            'MaxIter', 1
            }, S.opts);
        S.to_continue_fit = true;
        C = S2C(S);
        [res, Fl] = W.fit(C{:});
        
    end
    function [cost, varargout] = get_cost(W0, varargin)
        % Return cost after performing all nested fits.
        W0.fit_nested;
        
        % Note: W.pred() is already done in nested fits.
        
        W = W0.W_orig;
        [cost, varargout{1:(nargout-1)}] = W.get_cost(varargin{:});
    end
    function fit_nested(W0)
        % Call from within W0.get_cost()
        
        % Prepare for recovery
        W = W0.W_orig;
        Fl = W.Fl;
        
        % Prevent infinite recursion
        W.to_use_nested_fit = false; 
        
        % Nested fit in each group
        figure(2); % DEBUG
        for ii = 1:numel(W0.th_group)
            group = W0.th_group{ii};

            W0.recover_th_in_group_and_fix_others(group, 'th');
            
            % Run fitting with a new Fl at each time
            W.Fl = [];
            Fl = W.get_Fl;
%             Fl.remove_plotfun_all; % To avoid interfering with the main fit.
            W.fit('opts', {
                'UseParallel', 'never'            
                });
            
            W0.fix_th_in_group_and_recover_others(group, 'th');
        end
        figure(1); % DEBUG
        
        % Recover Fl
        W.Fl = Fl;
        
        % Recover params
        W0.fix_th_in_group_and_recover_others(W0.all_th_names_in_group, ...
            'th');

        % Recover W_orig
        W.to_use_nested_fit = true; 
    end
    function all_th_names_in_group = get.all_th_names_in_group(W0)
        all_th_names_in_group = {};
        for ii = 1:numel(W0.th_group)
            all_th_names_in_group = union( ...
                all_th_names_in_group, ...
                W0.th_group{ii});
        end
    end
    function recover_th_limits(W0)
        W = W0.W_orig;
        
        W.th0_vec = W0.th0_vec_orig;
        W.th_lb_vec = W0.th_lb_vec_orig;
        W.th_ub_vec = W0.th_ub_vec_orig;
    end
    function fix_th_in_group_and_recover_others(W0, th_names, varargin)
        W = W0.W_orig;
        th_names_rest = setdiff(W.th_names, th_names);
        W0.recover_th_in_group_and_fix_others(th_names_rest, varargin{:});
    end
    function recover_th_in_group_and_fix_others(W0, th_names, set_th0_to)
        % set_th0_to: 'th' or 'orig'
        if nargin < 3
            set_th0_to = 'th';
        end
        
        W = W0.W_orig;
        
        th_names0 = W.th_names;
        th_names_rest = setdiff(th_names0, th_names);
        W.fix_to_th_(th_names_rest);
        
        incl = ismember(th_names0, th_names);
        
        switch set_th0_to
            case 'th'
                W.th0_vec(incl) = W.th_vec(incl);
            case 'orig'
                W.th0_vec(incl) = W0.th0_vec_orig(incl);
        end
        
        W.th_lb_vec(incl) = W0.th_lb_vec_orig(incl);
        W.th_ub_vec(incl) = W0.th_ub_vec_orig(incl);
    end
end
end