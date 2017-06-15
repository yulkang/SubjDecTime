classdef PsyCursor < PsyPTB
    properties
        inpMode = 'Mouse';
    end
    
    properties (Transient)
        Mouse
    end
    
    
    methods
        function Cursor = PsyCursor(cScr, color, radiusDeg, inpMode)
            Cursor = Cursor@PsyPTB;
            
            Cursor.tag = 'Cursor';
            Cursor.tempNames = {'Mouse'};
            
            if nargin > 0
                Cursor.Scr = cScr; 
                
                if ~exist('color', 'var') || isempty(color)
                    color = [255 0 0];
                end
                if ~exist('radiusDeg', 'var') || isempty(radiusDeg), 
                    radiusDeg = 0.1;
                end
                if exist('inpMode', 'var') && ~isempty(inpMode)
                    Cursor.inpMode = inpMode;
                end

                init(Cursor, 'FillCircle', color, [0; 0], radiusDeg);
            end
        
            % Only position will change.
            initLogEntries(Cursor, 'prop2', {'xyPix'}, 'fr'); 
            
            % Used by Scr. Should match 'from' in update(Cursor, from).
            Cursor.updateOn = {'befDraw'}; 
        end
        
        function initLogTrial(Cursor)
            Cursor.Mouse = Cursor.Scr.c.(Cursor.inpMode);
            
            initLogTrial@PsyPTB(Cursor);
        end
        
        function update(Cursor, ~)
            Cursor.xyPix = Cursor.Mouse.xyPix(:);
        end
        
        function plot(Cursor, relS)
            Cursor.xyDeg = Cursor.Mouse.v('xyDeg', relS, relS+1/Cursor.Scr.info.refreshRate, 'relSec');
            if ~isempty(Cursor.xyDeg)
                Cursor.xyDeg = Cursor.xyDeg(:,1);
            end
            plot@PsyPTB(Cursor, relS);
        end
    end
end