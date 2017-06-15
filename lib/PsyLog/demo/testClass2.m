classdef (ConstructOnLoad) testClass2 < handle
    properties (Transient)
        a = 1
    end
    
    properties
        b = [2 2];
        c = [3 3];
    end
    
    
    methods
        function me = testClass2
            me.a = 3;
        end
        
        function inc(me)
            me.b = me.b + 1;
        end
        
%         function ts = saveobj(me)
%             me.a = struct(me.a);
%             ts = struct(me);
%         end
        
        
        function res = c.get(me)
            res = me.b + 1;
        end
    end
    
    
%     methods (Static)
%         function me = loadobj(ts)
%             me = struct2obj(testClass, struct(ts));
%             me.a = struct2obj(testClass, struct(me.a));
%         end
%     end
end