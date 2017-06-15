classdef PsyLogProp < PsyDeepCopy
    properties
        Scr         = [];
        obj         = [];
        
        t           = struct;
        ver         = struct;
        
        nNames      = 0;
        names       = {};
        
        defaultVer  = struct;
        isProp      = struct;
        types       = struct;
        maxNVer     = struct;
        
        updated     = struct;
    end
    
    properties (Constant)
        SCALAR      = 1;
        ROWVEC      = 2;
        MATRIX      = 3;
        CELL        = 10;
    end

    methods
        function me = PsyLogProp(Scr, obj)
            me.rootName     = 'Scr';
            me.parentName   = 'obj';
            
            if nargin > 0, me.Scr = Scr; end
            if nargin > 1, me.obj = obj; end
        end
        
        function addEntry(me, name, isProp, defaultVer, type)
            if nargin < 3
                isProp = isprop(me.obj, name);
            end
            
            if nargin < 4 && isprop
                defaultVer = me.obj.(name);
            end
            
            if nargin < 5
                siz = size(defaultVer);
                
                if length(siz) == 2
                	if siz(1) == 1
                        if siz(2) == 1
                            type = PsyLogProp.SCALAR;
                        else
                            type = PsyLogProp.ROWVEC;
                        end
                    else
                        type = PsyLogProp.MATRIX;
                    end
                else
                    type = PsyLogProp.CELL;
                end
            end
            
            me.isProp.(name)    = isProp;
            me.defaultVer.(name)= defaultVer;
            me.types.(name)     = type;
            
            me.updated.(name)   = false;
            
            me.names            = fieldnames(me.types)';
            me.nNames           = length(me.names);
        end
        
        function initLog(me)
            for cName = me.names
                ccName = cName{1};
                
                switch me.types.(ccName)
                    case me.SCALAR
                        me.ver.(ccName)(1:me.maxNVer.(ccName)) = me.defaultValue.(ccName);
                        
                    case me.ROWVEC
                        me.ver.(ccName)(1:me.maxNVer.(ccName),:) = me.defaultValue.(ccName);
                        
                    case me.MATRIX
                        me.ver.(ccName)(:,:,1:me.maxNVer.(ccName)) = me.defaultValue.(ccName);
                        
                    case me.CELL
                        me.ver.(ccName)(1:me.maxNVer.(ccName)) = {me.defaultValue.(ccName)};
                end
            end
        end
            
        function log(me, varargin)
            for cName = varargin
                ccName = cName{1};
                
                me.t.(ccName) = me.t.(ccName);
                
            end
        end
    end
end