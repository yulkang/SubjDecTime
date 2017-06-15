classdef PsyInp < PsyLogs
    properties
        sampledAbsSec    = -inf; % last sampled time
        freq             = [];   % in Hz
        active           = false;
        
        lowFreq          = 0;
        highFreq         = 60;
        lowFreqAtAbsSec  = nan;
        highFreqAtAbsSec = nan;
        deviceFreq       = 200;
        
        maxSecAtHighFreq = 1;
        maxSecAtLowFreq  = 7;
    end
    
    
    properties (Dependent)
        maxNSample
    end
    
    
    methods (Abstract)
        inp     = get(me);
    end
    
    
    methods
        function me = PsyInp(cScr)
            me.rootName     = 'Scr';
            me.parentName   = 'Scr';
            
            if nargin > 0, me.Scr = cScr; end
        end
        
        
        function activate(me)
            me.active = true;
        end
        
        
        function deactivate(me)
            me.active = false;
        end
        
        
        function res = get.maxNSample(me)
            res = ceil(me.maxSecAtHighFreq * me.highFreq ...
                     + me.maxSecAtLowFreq  * me.lowFreq);
        end
    end
end