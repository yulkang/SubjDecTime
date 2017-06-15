classdef Fit_flow_analyzer < Fit_flow
properties
    monitor_prop = {'th', 'dat', 'S'};
    
    rec_ = struct;
end    
    
methods
    function me = Fit_flow_analyzer(varargin)
        me = me@Fit_flow(varargin{:});
    end
    
    function varargout = analyze(me, init_args, cost_args) 
        % analyze(me, init_args, cost_args)
        
        if ~exist('init_args', 'var'), init_args = {}; end
        if ~exist('cost_args', 'var'), cost_args = {}; end
        
        % Initialize record
        me.rec_ = struct;
        
        % Run init and cost
        me.init(init_args{:});
        [varargout{1:nargout}] = me.cost(cost_args{:});
        
        % Pretty-print record.
        me.print_rec_;
    end
    
    function print_rec_(me)
        for cc_kind = {'init', 'pred', 'cost'}
            c_kind = cc_kind{1};
            
            funs = fieldnames(me.rec_.(c_kind))';
            
            fprintf('%%===== %s functions =====\n', c_kind);
            
            for cc_fun = funs
                c_fun = cc_fun{1};

                fprintf('%%----- help for %s -----\n', c_fun);
                fprintf('%% Input/output (in the order of the first reference)\n');
                
                for in_out = {'in', 'out'}
                    c_io = in_out{1};
                    
                    fprintf('%% %s:\n%%', upper(c_io));
                    fprintf(' %s', me.rec_.(c_kind).(c_fun).in{:});
                    fprintf('\n%%\n');
                end
            end
        end
    end
    
    function varargout = subsref(me, S)
        % Log th, dat, S
        prop = S(1).subs;
        
        if strcmp(S(1).type, '.') && any(strcmp(prop, me.monitor_prop))
            str = Fit_flow_analyzer.dot_S(S);
            kind = me.running_kind;
            fun  = me.running_fun;
            
            if ~isempty(kind) && ~isempty(fun)
                try
                    me.rec_.(kind).(fun).in = ...
                        unique(me.rec_.(kind).(fun).in, {str}, 'stable');
                catch
                    me.rec_.(kind).(fun).in = {str};
                end
            end
        end
        
        % Perform the original function.
        [varargout{1:nargout}] = builtin('subsref', me, S);
    end
    
    function me = subsasgn(me, S, v)
        % Log th, dat, S
        prop = S(1).subs;
        
        if strcmp(S(1).type, '.') && any(strcmp(prop, me.monitor_prop))
            str  = Fit_flow_analyzer.dot_S(S);
            kind = me.running_kind;
            fun  = me.running_fun;
            
            try
                me.rec_.(kind).(fun).out = ...
                    unique(me.rec_.(kind).(fun).out, {str}, 'stable');
            catch
                if ~isempty(kind) && ~isempty(fun)
                    me.rec_.(kind).(fun).out = {str};
                else
                    fprintf('%s %s\n', prop, str); % DEBUG
                end
            end
        end
        
        % Perform the original function.
        me = builtin('subsasgn', me, S, v);
    end
end

methods (Static)
    function [str, S_dot] = dot_S(S)
        % DOT_S  Convert first successive dot references into string.
        
        % Find first successive dot references
        types  = {S.type};
        is_dot = cellfun(@(s) strcmp(s, '.'), types);
        if any(~is_dot)
            first_dots = is_dot(1:(find(~is_dot, 1, 'first')-1));
        else
            first_dots = is_dot;
        end
        S_dot = S(first_dots);
        
        % Connect the field names with dots
        str    = sprintf('.%s', S_dot.subs);
    end
end
end