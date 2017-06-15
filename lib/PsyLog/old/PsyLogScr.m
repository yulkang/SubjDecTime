classdef PsyLogScr < PsyDeepCopy
    properties
        Scr     = [];
        ver     = struct;
        
        objC        = {}; % Object names in Scr.c, to record.
        
        % Properties to record.
        % If propToLogC.RandDot = {'col', 'pos'}, 
        % Scr.c.RandDot.col and Scr.c.RandDot.pos are logged.
        propToLogC  = struct; 
        
        tUnitC  = struct;
        
        nC      = struct;
        maxNC   = struct;
        
        absSecC = struct;
        frC     = struct;
        
        % Update always happens on the object level (e.g. Scr.c.RandDot.)
        % All designated properties of the objects
        updatedC= struct;
        
        
        %% PsyDeepCopy interface
        tag               = 'LogVal';
        rootName          = 'Scr';
        parentName        = 'obj';
        deepCpNames       = {};
        deepCpCellNames   = {};
        deepCpStructNames = {};
    end
    
    
    methods
        function me = PsyLogScr(varargin)
            if nargin > 0
                init(me, varargin{:});
            end
        end
        
        
        function init(me, objC, propToLogC, maxNC, defaultVer, tUnit, appendDim)
            
        end
    end
end