classdef PsyClock < PsyPTB & PsyRStream
    properties
        stAngle     = 0;
        cAngle      = [];
        dAnglePerSec= pi;
        dAngle      = [];
        
        eccenDeg    = 4;
        eccenPix    = [];
        
        frameColor  = [100 100 100]';
        frameRectPix = [];
        
        tickLenDeg  = 0.2;
        tickAngle   = 0;
        
        tickXYPix   = [];
        tickColor   = [100 100 100]';
    end
    
    
    methods
        function Clock = PsyClock(cScr, varargin)
            Clock.tag = 'Clock';
            
            if nargin > 0, Clock.Scr = cScr; end
            
            % Default values
            Clock.commPsy = 'FillCircle';
            Clock.commPsy2PTB;
            
            Clock.cAngle = Clock.stAngle - Clock.dAngle;
            
            Clock.centerDeg = [0 0]';
            Clock.sizeDeg   = 0.1;
            Clock.color     = [255 255 255]';
            
            Clock.updateOn = {'befDraw'};
            
            if nargin > 1, init(Clock, varargin{:}); end
        end
        
        function init(Clock, rSeed, varargin)
            % init(Clock, rSeed, ['propName1', prop1, ...])
            %
            % rSeed: 'shuffle', 'reset', specific number, or NaN
            
            Clock.init@PsyPTB;
            
            if nargin < 2, rSeed = []; end
                        
            initRStream(Clock, rSeed);
            Clock.stAngle = rand(Clock.rStream) * pi * 2;

            varargin2fields(Clock, varargin); % stAngle can be overridden here.
            
            Clock.dAngle  = Clock.dAnglePerSec / Clock.Scr.info.refreshRate;
            Clock.cAngle  = Clock.stAngle - Clock.dAngle;
            
            Clock.sizePix      = Clock.sizeDeg * Clock.Scr.info.pixPerDeg;
            Clock.centerPix    = Clock.Scr.deg2pix(Clock.centerDeg);
            Clock.eccenPix     = Clock.eccenDeg * Clock.Scr.info.pixPerDeg;
            Clock.frameRectPix = PsyPTB.xyPix2RectPix(Clock.centerPix, Clock.eccenPix);
            
            angle2pix(Clock);
            tickAngle2XYPix(Clock);
            
            initTrial(Clock);
        end

        function initLogTrial(Clock)
            Clock.initLogEntries('prop2', {'cAngle'}, 'fr', nan, 2*pi/Clock.dAngle);
            
            Clock.initLogTrial@PsyPTB;
        end
        
        function update(Clock, from)
            if strcmp(from, 'befDraw') && Clock.visible
                Clock.cAngle = Clock.cAngle + Clock.dAngle;        
                
%                 angle2pix(Clock); % debug
                xyPix = zeros(2,1);
                [xyPix(1) xyPix(2)] = pol2cart(Clock.cAngle, Clock.eccenPix);

                Clock.xyPix = xyPix + Clock.centerPix;
                
                addLog(Clock, {'cAngle'}, Clock.Scr.cFr);
            end
        end
        
        function angle2pix(Clock)
            xyPix = zeros(2,1);
            [xyPix(1), xyPix(2)] = pol2cart(Clock.cAngle, Clock.eccenPix);
            
            Clock.xyPix = xyPix + Clock.centerPix;
        end
        
        function tickAngle2XYPix(Clock)
            cTickAngle = Clock.tickAngle + Clock.stAngle;
            nTick      = length(cTickAngle);
            
            cEccenPix  = Clock.eccenPix * ones(1, nTick);
            
            [Clock.tickXYPix(1,[1:2:(nTick*2), 2:2:(nTick*2)]), ...
             Clock.tickXYPix(2,[1:2:(nTick*2), 2:2:(nTick*2)])] ...
                = pol2cart([cTickAngle, cTickAngle], ...
                           [cEccenPix,  cEccenPix - Clock.tickLenDeg * Clock.pixPerDeg]);
        end
        
        function draw(Clock)
            % Draw frame
            Screen('FrameOval', Clock.win, Clock.frameColor, Clock.frameRectPix);
            
            % Draw tickmarks
            Screen('DrawLines', Clock.win, Clock.tickXYPix, 1, Clock.tickColor, Clock.centerPix(:)');
            
            % Draw Clock hand
            Screen('DrawLines', Clock.win, [0 0; (Clock.xyPix - Clock.centerPix)']', 1, Clock.color, Clock.centerPix(:)');
%             draw@PsyPTB(Clock);
% 
%             % Draw FP
%             Screen('FillOval', Clock.win, Clock.frameColor, [Clock.centerPix-2; Clock.centerPix+2]);
        end
        
        function h = plot(Clock, relS)
            Clock.cAngle = Clock.v('cAngle', relS, relS + 1.5/Clock.Scr.info.refreshRate, 'relSec');
            if ~isempty(Clock.cAngle)
                Clock.cAngle = Clock.cAngle(1);
            end
            
            Clock.plotPTB(relS);
            
            if nargout > 0, h = Clock.h; end
        end
        
        function plotPTB(Clock, relS)
            if ~PsyVis.onnow(relS, Clock.relSec('on'), Clock.relSec('off'))
                try
                    delete(Clock.h);
                catch
                end
                Clock.h = [];
                return;
            end
            if isempty(Clock.h), Clock.h = ghandles(1, 3); end
            
            onePixDeg = 1 / Clock.pixPerDeg;
            
            Clock.h(1) = plotcircle(Clock.h(1), Clock.centerDeg(:)', Clock.eccenDeg, ...
                Clock.frameColor/255, 'frame', onePixDeg);
            
            tickXYDeg = Clock.tickXYPix / Clock.pixPerDeg;
            
            Clock.h(2) = plotPTB(Clock.h(2), 'DrawLines', tickXYDeg, onePixDeg, ...
                Clock.tickColor, Clock.centerDeg);
            
            if isempty(Clock.cAngle)
                try
                    delete(Clock.h(3));
                catch 
                end
                Clock.h(3) = ghandles;
            else
                Clock.angle2pix;
                Clock.h(3) = plotPTB(Clock.h(3), 'DrawLines', ...
                    [0 0; (Clock.xyPix - Clock.centerPix)']' / Clock.pixPerDeg, ...
                    onePixDeg, Clock.color, Clock.centerDeg);
            end 
        end
    end
end