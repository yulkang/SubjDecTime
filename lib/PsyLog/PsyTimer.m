classdef PsyTimer < PsyLogs
    properties
        schedStAbsSec   = nan;
        schedEnAbsSec   = nan;
        
        ticStAngle        = nan;
    end
    
    
    properties (Dependent)
        rootAngle
        ticAngle
    end
    
    
    methods
        function me = PsyTimer(cScr, varargin)
            
        end
        
        
        function setTimer(stAbsSec, durSec, rootAngle, ticStAngle)
            
        end
       
        
        function update(me, from)
            if strcmp(from, 'befDraw')
                me.arcAngle = ...
                    (me.schedEnAbsSec - me.Scr.frOnPredAbsSec) ...
                  / (me.schedEnAbsSec - me.schedStAbsSec) ...
                  * (me.
            end
        end
        
        
        function set.ticStAngle(me, ang)
            
        end
        
        
        function set.rootAngle(me, ang)
            
        end
    end
end