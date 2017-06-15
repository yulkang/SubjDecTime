classdef PsySec < PsyDeepCopy;
    properties
        Scr     = [];
        
        maxN    = 1;
        
        absSec  = nan;
        n       = 0;
    end
    
    
    methods
        function me = PsySec(varargin)
            %% PsyDeepCopy interface
            me.tag     = 'Sec';
            me.rootName        = 'Scr';
        
            %% Other properties
            if nargin > 0
                me  = varargin2fields(me, varargin);
                
                me.initLog;
            end
        end
        
        
        function me = initLog(me)
            me.absSec = nan(1,me.maxN);
            me.n      = 0;
        end
        
        
        function me = add(me, absSec) 
            % Only for guideline.
            % Directly incorporate into code where time is critical.
            
            me.n            = me.n + 1;
            
            if nargin < 2
                me.absSec(me.n) = GetSecs;
            else
                me.absSec(me.n) = absSec;
            end
        end
        
        
        function relS = relSec(me, ver)
            
            relS = me.absSec(ver) - me.Scr.stAbsSec;
        end
    end
end