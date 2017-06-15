classdef PsyClockFeedback < PsyClock
    properties
        stAngleFB    = nan;
        
        stYDeg       = nan;
        radPerYDeg   = 2;
        
        answerKey    = 'space';
        undecidedKey = 'uparrow';
        didntSeeKey  = 'downarrow';
        
        allowedAnswers = {'reportedTime', 'undecided', 'didntSee'};
        
        ansAngle     = nan;
        ansColor     = [255 0 0];
        
        Clock        = [];
    end
    
    
    methods
        function me = PsyClockFeedback(cScr, varargin)
            me.tag = 'ClockFeedback';
            me.deepCpNames = {'Clock'};
            
            me.updateOn = {'befDraw', 'Mouse', 'Key'};
            
            if nargin > 0, me.Scr = cScr; end            
            if nargin > 1, init(me, varargin{:}); end
        end    


        function init(me, Clock, varargin)
            if nargin < 2, Clock = me.Src.c.Clock; end
            if nargin >=3, varargin2fields(me, varargin, true); end
            
            me.Clock = Clock;
            copyFields(me, Clock, {'updateOn', 'rStream', 'Log'}, true, true);
            
            me.initLogEntries('val2', {'resAngle'}, 'absSec', {nan});
            me.initLogEntries('markFirst', {'undecided', 'didntSee', 'reportedTime'}, 'absSec');
            
            me.stYDeg = nan;
            me.stAngleFB = Clock.stAngle;
            
            me.ansAngle = nan;
            
            init(me.Scr.c.Key, {me.answerKey, me.undecidedKey, me.didntSeeKey});
        end
        
        
        function initLogTrial(me)
            % Skip initLogTrial@PsyClock, 
            % but don't go above PsyVis, 
            % because we need to call necessary initialization 
            % including resetting show/hideAtAbsSec.
            me.initLogTrial@PsyPTB; 
        end
        
        function update(me, from) % , Obj)
            if me.visible
                switch from
                    case 'Mouse'
                        cMouse = me.Scr.c.Mouse;
                        
                        if isnan(me.stYDeg)
                            me.stYDeg = cMouse.xyDeg(2);
                        end
                        
                        me.cAngle = (cMouse.xyDeg(2) - me.stYDeg) * me.radPerYDeg ...
                                  + me.stAngleFB;
                        
                    case 'Key'
                        cKey = me.Scr.c.Key;
                        
                        if any(strcmp('reportedTime', me.allowedAnswers)) && ...
                                ~me.logged('resAngle') && cKey.logged(me.answerKey)
                            
                            addLog(me, {'resAngle'}, cKey.t_.(me.answerKey), ...
                                       {me.cAngle});
                                   
                            Clock = me.Clock;
                                   
                            addTime1(me, 'reportedTime', ...
                                Clock.absSec('on') ...
                                + angleOp('minus2', me.cAngle, me.stAngle)...
                                / Clock.dAnglePerSec);
                        
                        elseif any(strcmp('undecided', me.allowedAnswers)) && ...
                                ~me.logged('undecided') && cKey.logged(me.undecidedKey)
                            
                            addLog(me, {'undecided'}, cKey.t_.(me.undecidedKey));
                            
                        elseif any(strcmp('didntSee', me.allowedAnswers)) && ...
                                ~me.logged('didntSee') && cKey.logged(me.didntSeeKey)
                            
                            addLog(me, {'didntSee'}, cKey.t_.(me.didntSeeKey));                            
                        end
                        
                    case 'befDraw'
                        angle2pix(me);
                end
            end
        end
        
        function tf = answered(me)
            tf = any(me.logged('resAngle', 'undecided', 'didntSee'));
        end
        
        function res = tAns(me, angRad)
            if ~isempty(me.Clock)
                cClock = me.Clock;
            else
                cClock = me.Scr.c.Clock;
            end
            
            if nargin < 2
                if ~me.answered
                    res = nan; 
                    return; 
                else
                    angRad = me.v_.resAngle;
                end
            end
            
            % Simplest algorithm
            res = angleOp('minus2', angRad, cClock.stAngle) ...
                / cClock.dAnglePerSec;
        end
        
        function res = ang2t(me, angRad)
            res = tAns(me, angRad);
        end
        
        function res = t2ang(me, t)
            % angle in rad.
            
            if ~isempty(me.Clock)
                cClock = me.Clock;
            else
                cClock = me.Scr.c.Clock;
            end
            
            % Simplest algorithm
            res = cClock.stAngle + t * cClock.dAnglePerSec;
        end
        
        function draw(me)
            draw@PsyClock(me);
            
            % Draw answer hand if specified
            if ~isnan(me.ansAngle)
                xyPixAns = me.ansPix;
                Screen('DrawLines', me.win, [0 0; xyPixAns']', 1, me.ansColor, me.centerPix(:)');
            end
        end
        
        function xyAns = ansPix(me)
%             [xyAns(1,2), xyAns(2,2)] = pol2cart(me.ansAngle, me.eccenPix*0.5);
            [xyAns(1,1), xyAns(2,1)] = pol2cart(me.ansAngle, me.eccenPix);
        end
        
        function xyAns = ansDeg(me)
%             [xyAns(1,2), xyAns(2,2)] = pol2cart(me.ansAngle, me.eccenDeg*0.5);
            [xyAns(1,1), xyAns(2,1)] = pol2cart(me.ansAngle, me.eccenDeg);
        end
        
        function h = plot(me, relS)
            if (nargin < 2) || PsyVis.onnow(relS, me.relSec('on'), me.relSec('off'))
                me.visible = true;
                
                cMouse = me.Scr.c.Mouse;
                cMouse.xyDeg = cMouse.v('xyDeg', relS, relS + 1.5/me.Scr.info.refreshRate, 'relSec');
                if ~isempty(cMouse.xyDeg)
                    cMouse.xyDeg = cMouse.xyDeg(:,1);

                    me.update('Mouse');
                    me.update('befDraw');
                    me.plotPTB(relS);
                    
                    if ~isnan(me.ansAngle) && (relS >= me.relSec('resAngle'))
                        xyAns = bsxfun(@plus, me.centerDeg(:), [[0;0], me.ansDeg]);
                        if ~isempty(me.h)
                            if strcmp(get(me.h(end), 'Tag'), 'ansAngle')
                                h1 = me.h(end);
                                set(h1, 'XData', xyAns(1,:), 'YData', xyAns(2,:), ...
                                    'LineStyle', '-', 'Color', me.ansColor(:)'/255);
                            else
                                h1 = plot(xyAns(1,:), xyAns(2,:), '-', ...
                                    'Color', me.ansColor(:)'/255, 'Tag', 'ansAngle');
                                me.h(end+1) = h1;
                            end
                        end
                    end
                end
            else
                if me.visible
                    if any(isvalidhandle(me.h))
                        me.plotPTB(relS);
                    end
                    me.visible = false;
                end
            end
            
            if nargout > 0, h = me.h; end
        end
    end
end