classdef testPostSet < handle
    properties (SetObservable)
        a
        b
        updated = struct('a', false, 'b', false);
    end
    
    methods
        function me = testPostSet
            addlistener(me, 'a',    'PostSet', @setUpdated);
            addlistener(me, 'b',    'PostSet', @setUpdated);
        end
    end 
end