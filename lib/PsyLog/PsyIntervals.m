classdef PsyIntervals
    properties
        st = inf;
        en = -inf;
    end
    
    methods
        function me = PsyIntervals(st, en)
            if nargin > 0
                me.st = st;
                me.en = en;
            end
        end
        
        function tf = includes(me, v)
            tf = within_intervals(v, me.st, me.en);
        end
        
        function me = add_interval(me, st, en)
            if ~any((me.st == st) & (me.en == en))
                me.st(end+1) = st;
                me.en(end+1) = en;
            end
        end
        
        function tf = any_nonempty(me)
            tf = any((me.en - me.st) >= 0);
        end
        
        function v = vec(me, ix, gap)
            % ix: scalar
            % gap: defaults to 1.
            
            if ~exist('gap', 'var'), gap = 1; end
            v = me.st(ix):gap:me.en(ix);
        end
    end
end