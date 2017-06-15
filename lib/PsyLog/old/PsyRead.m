classdef PsyRead
    properties
        Scr
        
        log
    end
    
    
    methods
        function me = PsyRead(varargin)
            if nargin > 0
                init(me, varargin{:});
            end
        end
        
        
        function init(me, varargin)
            
            
            init@PsyLogs(me, 'mark', 'absSec', names);
        end
        
        
        function initLog(me)
            me.verdictV = cell2struct(cell(size(me.verdicts)), me.verdicts, 2);
        end
        
        
        function Key(me)
            Key = me.Scr.Inp.Key;
        end
        
        
        function Mouse(me)
            Mouse = me.Scr.Inp.Mouse;
            
            if Mouse.lastXYPix
                
            end
        end
        
        
        function Eye(me)
            Eye = me.Scr.Inp.Eye;
        end
        
        
        function flip(me)
        end
    end
end