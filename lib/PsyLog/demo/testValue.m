classdef testValue
    % Value class performance test.
    
    properties
        a = magic(100);
    end
    
    methods
        function me = inc(me)
            me.a = me.a + 1;
        end
    end    
end

