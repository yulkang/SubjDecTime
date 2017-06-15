classdef PsyTargFlick < PsyTargAns
    
    methods
        function me = PsyTargFlick(varargin)
            me = me@PsyTargAns(varargin{:});
        end
        
        function exit(~, ~, ~)
            % Do nothing. 
        end
    end
end
    