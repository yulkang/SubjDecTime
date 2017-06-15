classdef PsyMovingHover < PsyHover & PsyMoving
    methods
        function me = PsyMovingHover(cScr, varargin)
            me.tag = 'MovingHover';
            
            if nargin > 0, me.Scr = cScr; end
            if nargin > 1
                me.init(varargin{:});
            end
        end
        
        function init(me, varargin)
            C = varargin2C(varargin, {
                'moveFromAbsSec', nan
                'moveToAbsSec', nan
                });

            init@PsyHover(me, C{:});
        end
        
        function update(me, from)
            update@PsyMoving(me, from);
            update@PsyHover(me, from);
        end
        
        function initPsyProps(me, varargin)
            initPsyProps@PsyPTB(me, varargin{:});
            
            me.n = me.nElem;
        end
        
        function initOld(me, commPsy, colorOut, colorIn, varargin) % for backward compatibility
            % initOld(me, commPsy, colorOut, colorIn, varargin)
            
            me.colorOut = colorOut;
            me.colorIn  = colorIn;
            
            S = varargin2S(varargin, {
                'xyDeg', me.xyDeg
                });
            
            initPsyProps(me, commPsy, colorOut, S.xyDeg(:), varargin{:});
            
            initHover(me);
            
            me.color = me.colorIn;
        end
    end
end