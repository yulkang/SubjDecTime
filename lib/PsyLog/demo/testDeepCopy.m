classdef testDeepCopy < PsyDeepCopy
    properties
        parent = [];
        child  = [];
    end
        
    
    methods
        function me = testDeepCopy
            me.parentName = 'parent';
            me.deepCpNames = {'child'};
        end
    end
end