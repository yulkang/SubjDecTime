classdef PsyTrial < handle
    
    properties
        stSec   = nan;
        enSec   = nan;
        
        % Devices
        
        Scr     = PsyScr;   % Supersedes ScreenFlip().
        Key     = PsyKey;   % Keyboard input with logging capability.
        Mouse   = PsyMouse; % Mouse input with logging capability. Supersedes MouseHigh().
        Eye     = PsyEye;   % Eyelink input with logging capability.
        
        % Psychophysical objects
        
        V      % Struct with fields of PsyV objects, for easy lookup.
        VShown % Vector of PsyV objects, drawing order (later can occlude prior).
        
        A      % Struct with fields of PsyA objects.
    end
    
    
    methods
        function me = PsyIO(varargin)
            if nargin > 0
                me.LogInit(varargin{:});
            end
        end
        
        
        function LogInit(me, varargin)
            
        end
        
        
        function ScrInit(me)
        end
        
        
        function addV(me, vObj)
        end
        
        
        function addA(me, aObj)
        end
        
        
        function addI(me, iObj)
        end
        
        
        function showV(me, name, order)
        end
        
        
        function hideV(me, name)
        end
           
        
        function ScrFlip(me, varargin)
        end
    end
    
    
    methods (Static)
        function deg2pix()
        end
        
        
        function pix2deg()
        end
    end
end