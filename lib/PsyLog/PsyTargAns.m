classdef PsyTargAns < PsyHover
    % Add answer feedback functionality to PsyHover.
    
    properties
        answer = nan;
        
        answerRDeg = 0.6;
        answerRPix = nan;
        answerColor = [255 0 0]';
        answerWidthDeg = 0.1;
        answerWidthPix = nan;
    end
    
    methods
        function me = PsyTargAns(varargin)
            me = me@PsyHover(varargin{:});
            
            me.initLogEntries('markFirst', {'showAns'}, 'absSec');
            me.initLogEntries('markFirst', {'showAnsFr'}, 'fr');
            
            me.tag = 'TargAns';
        end
        
        
        function init(me, varargin)
            init@PsyHover(me, varargin{:});
            
            me.answerRPix = me.answerRDeg * me.pixPerDeg;
            me.answerWidthPix = me.answerWidthDeg * me.pixPerDeg;
        end
        
       
        function initLogTrial(me)
            initLogTrial@PsyHover(me);
            me.answer = nan;
        end
        
        
        function showAns(me, iTarg, t)
            me.answer = iTarg;
            
            addLog(me, {'showAnsFr'}, t);
        end
        
        
        function res = draw(me, c_win)
            % res = draw(me, [c_win = 1])
            if nargin < 2, c_win = me.win; end
            
            draw@PsyHover(me, c_win);
            
            if ~isnan(me.answer)
                Screen('FrameOval', me.win, me.answerColor, ...
                    PsyPTB.xyPix2RectPix(me.xyPix(:,me.answer), ...
                        me.answerRPix), ...
                    me.answerWidthPix);
            end
            
            res = 1;
        end
    end
end