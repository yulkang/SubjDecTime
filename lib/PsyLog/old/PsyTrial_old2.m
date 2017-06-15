classdef PsyTrial < PsyDeepCopy
    % Trial class with minimal functionality.
    
    methods
        function me = PsyTrial(varargin)
            if nargin > 0
                me.initTrials(varargin{:});
            end
        end
        
        function initTrials(me, nTr, nObsExpected, repArgs, paramArgs)
            % initTrials(me, nTr, nObsExpected, repArgs, paramArgs)
            
            if ~exist('nObsExpected', 'var'), nObsExpected = 2; end
            if ~exist('repArgs', 'var'), repArgs = {}; end
            
            me.addRep(nTr, repArgs, paramArgs);
            
            
        end

    end
end