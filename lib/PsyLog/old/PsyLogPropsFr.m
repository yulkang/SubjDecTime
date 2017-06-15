classdef PsyLogPropsFr < PsyLogProp
    % Much faster when logging multiple properties at once,
    % than calling PsyLogScalarPropFr.add multiple times.
    %
    % Even faster is to have a struct having all the properties to log at once,
    % and call PsyLogScalarPropFr.add for that property, but it will be inflexible.
    % (e.g., when I decide to log properties other than I was logging,
    %  I have to include that property into the struct, 
    %  and change the way I refer to that property in every program.)
    
    properties
        tUnit = 'fr';
    end
    
    
    methods
        function me = PsyLogPropsFr(varargin)
            if nargin > 0
                init(me, varargin{:});
            end
        end
        
        
        function init(me, propToLog, maxN, defaultVer)
            % init(LogPropsFr, 
            
            if nargin > 1
                if ~iscell(propToLog)
                    error('propToLog should be a cell array of property names!');
                end
                
                me.propToLog    = propToLog;
                me.maxN         = maxN;
                
                if nargin >= 6
                    me.defaultVer = cell2struct(defaultVer, propToLog, 2);
                else
                    for cProp = propToLog
                        me.defaultVer.(cProp{1}) = obj.(cProp{1});
                    end
                end
            end
            
            initLog(me);
        end
        
        % initLog is defined in the superclass PsyLogProp.
        
        function initVer(me)
            me.ver = repmat(me.defaultVer, [1 me.maxN]);
            me.updated = false;
        end
        
        
        function add(me, propToLog)
            if nargin < 2
                for cProp = me.propToLog
                    ccProp = cProp{1};
                    
                    me.n.(ccProp) = me.n.(ccProp) + 1;
                    me.t.(ccProp)(1,me.n) = me.Scr.cFr;
                        
                    me.ver(me.n.(ccProp)).(ccProp) = me.obj.(ccProp);
                end
            else
                for cProp = propToLog
                    ccProp = cProp{1};
                    
                    me.n.(ccProp) = me.n.(ccProp) + 1;
                    me.t.(ccProp)(1,me.n) = me.Scr.cFr;
                    me.ver(me.n.(ccProp)).(ccProp) = me.obj.(ccProp);
                end                
            end
        end
        
        
        function cVer = retrieve(unit, t)
            cVer = me.ver(me.t.(unit) == t);
        end
    end
end