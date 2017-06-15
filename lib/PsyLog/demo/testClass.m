classdef testClass < handle
    properties
        a = 1
        b = ones(1,1000);
        c = [3 3];
        d = [4];
    end
    
    
    methods
        function me = testClass
            me.c = 4;
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
    
    
    methods (Static)
        function me = loadobj(me)
            me.c = 4;
        end
    end
    
    
%     methods (Static)
%         function me = loadobj(ts)
%             me = struct2obj(testClass, struct(ts));
%             me.a = struct2obj(testClass, struct(me.a));
%         end
%     end
end