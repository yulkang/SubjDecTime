classdef testOverheadClass
    properties
    end
    
    
    methods
        function tt(me, a)
            if a, return; end
        end
    end
    
    
    methods (Static)
        function tt2(a)
            if a, return; end
        end
    end
end