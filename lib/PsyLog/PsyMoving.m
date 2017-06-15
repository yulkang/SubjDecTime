classdef PsyMoving < PsyPTB
    properties
        moveFromXYDeg   = nan(2,1);
        moveToXYDeg     = nan(2,1);
        
        moveFromSizeDeg = nan(2,1);
        moveToSizeDeg   = nan(2,1);
        
        moveFromXYPix   = nan(2,1);
        moveToXYPix     = nan(2,1);
        
        moveFromSizePix = nan(2,1);
        moveToSizePix   = nan(2,1);
        
        dXYPix    = nan(2,1);
        dSizePix  = nan(2,1);
        
        moveFromAbsSec  = nan;
        moveToAbsSec    = nan;
        moveDurSec      = nan;
        
        % Minimum jerk equation from Daniel Wolpert.
        % Input: relative time (0-1), Output: relative moving distance (0-1).
        relFun = @(t) -15*t^4 + 6*t^5 + 10*t^3;
    end
    
    
    methods
        function me = PsyMoving(cScr, varargin)
            me.tag = 'Moving';
            me.updateOn = unionCellStr(me.updateOn, {'befDraw'});
            
            if nargin > 0, me.Scr = cScr; end
            if nargin > 1
                me.init(varargin{:});
            end
        end
        
        
        function initMove(me, fromAbsSec, toAbsSec,...
                              toXYDeg, toSizeDeg)
                          
            me.moveFromXYDeg   = me.xyDeg;
            me.moveFromSizeDeg = me.sizeDeg;
            
            if nargin >=4 && ~isempty(toXYDeg)
                me.moveToXYDeg = toXYDeg; 
            else
                me.moveToXYDeg = me.moveFromXYDeg;
            end
            if nargin >=5 && ~isempty(toSizeDeg)
                me.moveToSizeDeg = toSizeDeg; 
            else
                me.moveToSizeDeg = me.moveFromSizeDeg;
            end
                          
            me.moveFromXYPix = me.xyDeg2Pix(me.moveFromXYDeg);
            me.moveToXYPix   = me.xyDeg2Pix(me.moveToXYDeg);
            
            me.moveFromSizePix = me.moveFromSizeDeg * me.pixPerDeg;
            me.moveToSizePix   = me.moveToSizeDeg * me.pixPerDeg;
            
            me.moveFromAbsSec = fromAbsSec;
            me.moveToAbsSec   = toAbsSec;
            me.moveDurSec     = toAbsSec - fromAbsSec;
            
            me.dXYPix   = (me.moveToXYPix - me.moveFromXYPix);
            me.dSizePix = (me.moveToSizePix - me.moveFromSizePix);
        end
        
        
        function update(me, from)
            if strcmp(from, 'befDraw') && me.visible
                elapProp = (me.Scr.frOnPredAbsSec ...
                          - me.moveFromAbsSec) / me.moveDurSec;
                
                if ~isfinite(elapProp), return; end
                      
                elapProp = min([max([elapProp 0]) 1]);
                
                me.xyPix    = me.moveFromXYPix + me.dXYPix ...
                                           * me.relFun(elapProp);
                                       
                me.sizePix  = me.moveFromSizePix + me.dSizePix ...
                                             * me.relFun(elapProp);
            end
        end
    end
end