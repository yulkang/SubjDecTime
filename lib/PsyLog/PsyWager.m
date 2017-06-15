classdef PsyWager < PsyPTB & PsyRStream
    properties
        % rect determines the extent
        
        crossHairColor = [100 100 100];
        
        xAns = 0.5; % 0 (always abandon rightward answer) to 1 (always keep rightward answer)
        yAns = 0.5; % 0 (always abandon 
    end
    
    properties (Transient)
        Mouse = [];
    end
    
    methods
        function Wager = PsyWager(cScr, cMouse, varargin)
            Wager.tag = 'Wager';
            Wager.updateOn = {'befDraw', 'Mouse'};
            
            if nargin >= 1, Wager.Scr   = cScr; end
            if nargin >= 2, Wager.Mouse = cMouse; end
            if nargin > 2,  init(Wager, varargin{:}); end
        end
        
        function init(Wager, rSeed, varargin)
            if isempty(Wager.Mouse)
                Wager = Wager.Scr.c.Mouse;
            end
            if nargin < 2 || isempty(rSeed)
                rSeed = 'shuffle';
            end
            
            varargin2fields(Wager, varargin);
        end
        
        function update(Wager, from)
            if Wager.visible
                switch from
                    case 'Mouse'
                    case 'befDraw'
                end
            end
        end
        
        function draw(Wager)
        end
    end
end