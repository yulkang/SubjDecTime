classdef PsyFr < PsyDeepCopy
    
    properties
        Scr     = [];
        
        maxN    = 1;
        
        fr      = nan;
        n       = 0;
    end
    
    
    methods
        function me = PsyFr(maxN, varargin)
            %% PsyDeepCopy interface
            me.tag      = 'Sec';
            me.rootName = 'Scr';
        
            %% Other properties
            if nargin > 0
                me.maxN = maxN;

                if ~isempty(varargin)
                    me = varargin2fields(PsyFr, varargin);
                end

                initLog(me);
            end
        end
        
        
        function initLog(me)
            me.fr = nan(1,me.maxN);
            me.n  = 0;
        end
        
        
        function add(me)
            % Only for guideline.
            % Directly incorporate into code where time is critical.
            
            me.n        = me.n + 1;
            me.fr(me.n) = me.Scr.cFr;
        end
        
        
        function added = addAftComp(me)
            % It's caller's duty to always use the same Scr
            % for an instance.
            
            if (me.n > 0) && (me.fr(me.n) ~= me.Scr.cFr)
                me.n        = me.n + 1;
                me.fr(me.n) = me.Scr.cFr;
                added = true;
            else
                added = false;
            end
        end
        
        
        function relS = relSec(me, ver)
            % It's the caller's duty to always use the same Scr
            % for an instance.
            
            relS = me.Scr.frOnAbsSec( me.fr(ver) ) - me.Scr.stAbsSec;
        end
    end
end