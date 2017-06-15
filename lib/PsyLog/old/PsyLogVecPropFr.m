classdef PsyLogVecPropFr < PsyLogProp
    properties
        tUnit = 'fr';
    end
    
    
    methods
        function me = PsyLogVecPropFr(varargin)
            me = me@PsyLogProp(varargin{:});
        end
        
        
        function initVer(me)
            me.ver = repmat(me.defaultVer, [me.maxN 1]);
            me.updated = false;
        end
        
        
        function add(me)
            me.n = me.n + 1;
            me.t(me.n) = me.Scr.cFr;
            
            me.ver(me.n,:)= me.obj.(me.propToLog);
        end
        
        
        function vers = retrieve(me, verNums)
            vers = me.ver(verNums, :);
        end
    end
end