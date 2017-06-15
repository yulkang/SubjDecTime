classdef PsyLogVecProp < PsyLogProp
    properties
        tUnit = '';
    end
    
    methods
        function me = PsyLogVecProp(tUnit, varargin)
            me = me@PsyLogProp(varargin{:});
            
            if nargin > 0
                me.tUnit = tUnit;
            end
        end
        
        
        function initVer(me)
            me.ver = repmat(me.defaultVer, [me.maxN 1]);
            me.updated = false;
        end
        
        
        function add(me, t)
            me.n = me.n + 1;
            
            switch me.tUnit
                case 'absSec'
                    if nargin < 2
                        me.absSec(me.n) = GetSecs;
                    else
                        me.absSec(me.n) = t;
                    end
                    
                case 'fr'
                    me.fr(me.n) = me.Scr.cFr;
                    
                otherwise
                    error('Unsupported tUnit: %s', me.tUnit);
            end
            
            me.ver(me.n,:)= me.obj.(me.propToLog);
        end
        
        
        function vers = retrieve(me, verNums)
            vers = me.ver(verNums, :);
        end
    end
end