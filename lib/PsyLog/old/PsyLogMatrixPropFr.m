classdef PsyLogMatrixPropFr < PsyLogProp
    properties
        tUnit = 'fr';
    end
    
    
    methods
        function me = PsyLogMatrixPropFr(varargin)
            me = me@PsyLogProp(varargin{:});
        end
                
        
        function initVer(me)
            me.ver = repmat(me.defaultVer, [1 1 me.maxN]);
            me.updated = false;
        end
        
        
        function add(me)
            me.n = me.n + 1;
            me.t(1,me.n) = me.Scr.cFr;
            
            me.ver(:,:,me.n)= me.obj.(me.propToLog);
        end
        
        
        function cVer = retrieve(unit, t)
            cVer = me.ver(:,:,me.t.(unit) == t);
        end
    end
end