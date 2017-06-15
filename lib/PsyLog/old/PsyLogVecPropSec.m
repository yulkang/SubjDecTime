classdef PsyLogVecPropSec < PsyLogProp
    properties
        tUnit = 'absSec';
    end
    
    
    methods
        function me = PsyLogVecPropSec(varargin)
            me = me@PsyLogProp(varargin{:});
        end
        
        
        function initVer(me)
            me.ver = repmat(me.defaultVer, [me.maxN 1]);
            me.updated = false;
        end
        
        
        function add(me, absSec)
            me.n = me.n + 1;
            
            if nargin < 2
                me.absSec(me.n) = GetSecs;
            else
                me.absSec(me.n) = absSec;
            end
            
            me.ver(me.n,:)= me.obj.(me.propToLog);
        end
        
        
        function vers = retrieve(me, verNums)
            vers = me.ver(verNums, :);
        end
    end
end