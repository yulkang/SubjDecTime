classdef PsyLogProp < PsyDeepCopy
    properties
        Scr         = [];
        
        ver         = [];
        
        obj         = []; % object whose property will be logged.
    end
    
    
    properties (Abstract)
        tUnit
        
        n           
        maxN        
        
        absSec      
        fr          
        
        updated     
        
        propToLog
        defaultVer
    end
    
    
    methods (Abstract)
        initVer(me);
        add(me);
        vers = retrieve(me, verNums);
    end
    
    
    methods
        function me = PsyLogProp(varargin)
            %% PsyDeepCopy interface
            me.rootName     = 'Scr';
            me.parentName   = 'obj';
            me.tag          = 'LogProp';

            
            %% Other properties
            if nargin > 0
                init(me, varargin{:});
            end
        end
        
        
        function init(me, obj, propToLog, maxN, defaultVer)
            if nargin > 1
                me.obj          = obj;
                me.propToLog    = propToLog;
                me.maxN         = maxN;
                
                if nargin >= 5
                    me.defaultVer = defaultVer;
                else
                    me.defaultVer = obj.(propToLog);
                end
            end
            
            initLog(me);
        end
        
        
        function initLog(me)
            me.n = 0;
            me.(me.tUnit) = zeros(1,me.maxN);
            initVer(me);
        end
    end
end