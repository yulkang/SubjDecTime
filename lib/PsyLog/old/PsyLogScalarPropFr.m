classdef PsyLogScalarPropFr < PsyLogProp
    % No apparent advantage over PsyLogVecPropFr in performance.
    
    properties
        tUnit = 'fr';
    end
    
    
    methods
        function me = PsyLogScalarPropFr(varargin)
            me = me@PsyLogProp(varargin{:});
        end
        
        
        function initVer(me)
            me.ver = repmat(me.defaultVer, [1 me.maxN]);
            me.updated = false;
        end
        
        
        function add(me)
            me.n = me.n + 1;
            me.t(1,me.n) = me.Scr.cFr;
            
            me.ver(1,me.n)= me.obj.(me.propToLog);
        end
        
        
        function vers = retrieve(me, verNums)
            vers = me.ver(1,verNums);
        end
    end
end